# Gait Explorer Shiny app
# Run with:
# - Directly: shiny::runApp("inst/app") from the project root, or
# - Via helper: cosineR::run_app()

library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(readr)
library(DT)

# -----------------------------------------------------------------------------
# Helpers to locate project root (so app can find outputs/ and datasets/)
# -----------------------------------------------------------------------------
locate_root <- function() {
  candidates <- c(".", "..", "../..", "../../..", "../../../..")
  for (c in candidates) {
    if (dir.exists(file.path(c, "outputs")) || dir.exists(file.path(c, "datasets"))) {
      return(normalizePath(c, winslash = "/", mustWork = FALSE))
    }
  }
  normalizePath(".", winslash = "/", mustWork = FALSE)
}

ROOT_DIR <- locate_root()
OUTPUTS_DIR <- file.path(ROOT_DIR, "outputs")
DATASETS_DIR <- file.path(ROOT_DIR, "datasets")

resolve_path <- function(p) {
  if (is.null(p) || is.na(p) || !nzchar(p)) return(NA_character_)
  if (file.exists(p)) return(p)
  alt <- file.path(ROOT_DIR, p)
  if (file.exists(alt)) return(alt)
  return(p)
}

# -----------------------------------------------------------------------------
# Event detection and trial readers
# -----------------------------------------------------------------------------
detect_events <- function(time, total_force, thrN = NULL) {
  if (is.null(thrN) || !is.finite(thrN) || thrN <= 0) {
    thrN <- max(50, 0.05 * max(total_force, na.rm = TRUE))
  }
  st <- total_force > thrN
  d <- diff(as.integer(st))
  hs_idx <- which(d == 1L) + 1L  # heel strike
  to_idx <- which(d == -1L) + 1L # toe off
  list(
    hs_time = time[hs_idx],
    to_time = time[to_idx],
    hs_idx = hs_idx,
    to_idx = to_idx,
    thr = thrN
  )
}

stride_stats <- function(hs_time) {
  if (length(hs_time) < 2) {
    return(list(n = 0L, mean = NA_real_, sd = NA_real_, cv = NA_real_))
  }
  st <- diff(hs_time)
  m <- mean(st, na.rm = TRUE)
  s <- sd(st, na.rm = TRUE)
  list(n = length(st), mean = m, sd = s, cv = ifelse(m > 0, 100 * s / m, NA_real_))
}

read_gaitpdb_trial <- function(path) {
  dat <- suppressWarnings(readr::read_tsv(path, col_names = FALSE, show_col_types = FALSE, progress = FALSE))
  if (ncol(dat) < 3) return(NULL)
  time <- dat[[1]]
  left_total  <- if (ncol(dat) >= 18) dat[[18]] else rowSums(dat[, 2:9, drop = FALSE])
  right_total <- if (ncol(dat) >= 19) dat[[19]] else rowSums(dat[, 10:17, drop = FALSE])
  data.frame(time = time, left = left_total, right = right_total, check.names = FALSE)
}

read_summary <- function(dataset) {
  if (identical(dataset, "gaitpdb")) {
    path <- file.path(OUTPUTS_DIR, "gaitpdb", "characterization_trials.csv")
  } else {
    path <- file.path(OUTPUTS_DIR, "gaitndd", "characterization_records.csv")
  }
  if (!file.exists(path)) return(NULL)
  suppressWarnings(readr::read_csv(path, show_col_types = FALSE))
}

# -----------------------------------------------------------------------------
# UI
# -----------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Gait Explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "Dataset", choices = c("gaitpdb", "gaitndd"), selected = "gaitpdb"),
      uiOutput("metric_ui"),
      uiOutput("group_ui"),
      sliderInput("bins", "Histogram bins", min = 10, max = 100, value = 30, step = 1),
      tags$hr(),
      conditionalPanel(
        condition = "input.dataset == 'gaitpdb'",
        h4("Raw trial (gaitpdb)"),
        uiOutput("trial_ui"),
        sliderInput("thr", "Event threshold (N) for HS/TO", min = 10, max = 400, value = 50, step = 5),
        helpText("Tip: If the threshold is too low or high, adjust to align markers with visible gait cycles.")
      ),
      width = 3
    ),
    mainPanel(
      tabsetPanel(
        id = "tabs",
        tabPanel(
          "Distribution",
          plotlyOutput("dist_plot", height = "420px"),
          br(),
          textOutput("dist_info")
        ),
        tabPanel(
          "Trial browser",
          DT::DTOutput("trial_table")
        ),
        tabPanel(
          "Raw trial (gaitpdb)",
          conditionalPanel(
            condition = "input.dataset == 'gaitpdb'",
            plotlyOutput("raw_plot", height = "420px"),
            br(),
            tableOutput("raw_summary")
          ),
          conditionalPanel(
            condition = "input.dataset != 'gaitpdb'",
            tags$p("Raw trial viewer is available for gaitpdb only. Switch to 'gaitpdb' to activate.")
          )
        )
      ),
      width = 9
    )
  )
)

# -----------------------------------------------------------------------------
# Server
# -----------------------------------------------------------------------------
server <- function(input, output, session) {
  # Load summary data for the selected dataset
  dsum <- reactive({
    ds <- input$dataset
    dat <- read_summary(ds)
    if (is.null(dat)) return(NULL)
    if ("group" %in% names(dat)) {
      dat$group <- as.factor(dat$group)
    }
    dat
  })

  # Dynamic metric choices: numeric columns, excluding thresholds
  output$metric_ui <- renderUI({
    dat <- dsum()
    if (is.null(dat)) {
      return(selectInput("metric", "Metric", choices = character(0)))
    }
    num_cols <- names(dat)[vapply(dat, is.numeric, logical(1))]
    exclude <- intersect(num_cols, c("left_thr_N", "right_thr_N"))
    choices <- setdiff(num_cols, exclude)
    default <- if (identical(input$dataset, "gaitpdb")) {
      intersect(c("left_stride_mean_s", "right_stride_mean_s", "duration_s"), choices)[1]
    } else {
      intersect(c("l_stride_mean_s", "r_stride_mean_s", "duration_s"), choices)[1]
    }
    selectInput("metric", "Metric", choices = choices, selected = default)
  })

  # Group filter (if present)
  output$group_ui <- renderUI({
    dat <- dsum()
    if (is.null(dat) || !("group" %in% names(dat))) {
      return(NULL)
    }
    groups <- sort(unique(dat$group))
    checkboxGroupInput("groups", "Groups", choices = groups, selected = groups, inline = TRUE)
  })

  # Distribution plot (ggplotly histogram)
  output$dist_plot <- renderPlotly({
    dat <- dsum()
    req(dat)
    metric <- input$metric
    req(metric, metric %in% names(dat))

    if (!is.null(input$groups) && "group" %in% names(dat)) {
      dat <- dplyr::filter(dat, .data$group %in% input$groups)
    }

    validate(need(sum(!is.na(dat[[metric]])) > 0, "No data for the chosen metric."))

    p <- ggplot(dat, aes(x = .data[[metric]], fill = if ("group" %in% names(dat)) .data$group else NULL)) +
      geom_histogram(
        position = if ("group" %in% names(dat)) "identity" else "stack",
        alpha = if ("group" %in% names(dat)) 0.6 else 0.8,
        bins = input$bins, color = "white"
      ) +
      labs(x = metric, y = "Count", fill = if ("group" %in% names(dat)) "Group" else NULL) +
      theme_minimal()

    ggplotly(p, tooltip = if ("group" %in% names(dat)) c("x", "fill") else "x")
  })

  output$dist_info <- renderText({
    dat <- dsum()
    if (is.null(dat) || is.null(input$metric) || !(input$metric %in% names(dat))) return("")
    n_all <- sum(!is.na(dat[[input$metric]]))
    n_shown <- if (!is.null(input$groups) && "group" %in% names(dat)) {
      tmp <- dat[dat$group %in% input$groups, , drop = FALSE]
      sum(!is.na(tmp[[input$metric]]))
    } else {
      n_all
    }
    paste0("Observations: ", n_shown, if (n_shown < n_all) paste0(" (filtered from ", n_all, ")") else "")
  })

  # Trial browser table
  output$trial_table <- DT::renderDT({
    dat <- dsum()
    req(dat)
    preferred <- c(
      "file", "base", "group", "duration_s",
      "left_stride_mean_s", "right_stride_mean_s",
      "left_stride_cv_pct", "right_stride_cv_pct",
      "l_stride_mean_s", "r_stride_mean_s",
      "l_stride_cv_pct", "r_stride_cv_pct",
      "ds_mean_pct"
    )
    keep <- intersect(preferred, names(dat))
    tbl <- dat[, keep, drop = FALSE]
    if ("file" %in% names(tbl)) {
      tbl$file_name <- basename(tbl$file)
      tbl <- dplyr::relocate(tbl, .data$file_name, .before = 1)
    }
    DT::datatable(
      tbl,
      selection = "single",
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })

  # Selecting a row in the table sets the trial in the raw viewer (gaitpdb)
  observeEvent(input$trial_table_rows_selected, {
    idx <- input$trial_table_rows_selected
    dat <- dsum()
    if (length(idx) == 1 && !is.null(dat) && "file" %in% names(dat) && identical(input$dataset, "gaitpdb")) {
      file_vec <- dat$file
      if (idx <= length(file_vec)) {
        updateSelectInput(session, "trial_select", selected = file_vec[[idx]])
      }
    }
  })

  # Trial selector (gaitpdb only)
  output$trial_ui <- renderUI({
    if (!identical(input$dataset, "gaitpdb")) return(NULL)
    dat <- dsum()
    if (is.null(dat) || !("file" %in% names(dat))) {
      return(selectInput("trial_select", "Trial file", choices = character(0)))
    }
    labels <- if ("base" %in% names(dat)) {
      paste0(dat$base, if ("group" %in% names(dat)) paste0(" (", dat$group, ")") else "")
    } else {
      basename(dat$file)
    }
    choices <- stats::setNames(as.character(dat$file), labels)
    selectInput("trial_select", "Trial file", choices = choices, selected = choices[[1]])
  })

  # Raw trial data (gaitpdb)
  raw_trial <- reactive({
    req(identical(input$dataset, "gaitpdb"))
    f <- resolve_path(input$trial_select)
    validate(need(!is.null(f) && file.exists(f), "Select a trial (the file path could not be found)."))
    read_gaitpdb_trial(f)
  })

  # Raw trial plot with HS markers and threshold line
  output$raw_plot <- renderPlotly({
    dat <- raw_trial()
    req(dat)
    thr <- input$thr
    le <- detect_events(dat$time, dat$left, thr)
    re <- detect_events(dat$time, dat$right, thr)

    long <- data.frame(
      time = c(dat$time, dat$time),
      foot = factor(rep(c("left", "right"), each = nrow(dat)), levels = c("left", "right")),
      force = c(dat$left, dat$right),
      check.names = FALSE
    )

    ev_left <- data.frame(time = dat$time[le$hs_idx], force = dat$left[le$hs_idx], foot = "left", type = "HS")
    ev_right <- data.frame(time = dat$time[re$hs_idx], force = dat$right[re$hs_idx], foot = "right", type = "HS")
    ev <- dplyr::bind_rows(ev_left, ev_right)

    p <- ggplot(long, aes(x = .data$time, y = .data$force, color = .data$foot)) +
      geom_line(alpha = 0.9) +
      geom_point(data = ev, aes(x = .data$time, y = .data$force, color = .data$foot),
                 inherit.aes = FALSE, size = 1.8, alpha = 0.9) +
      geom_hline(yintercept = thr, linetype = "dashed", color = "gray50") +
      labs(x = "Time (s)", y = "Total force (N)", color = "Foot",
           title = "gaitpdb: Total force with heel-strike markers") +
      theme_minimal()

    ggplotly(p, tooltip = c("x", "y", "color"))
  })

  # Summary table for the selected trial
  output$raw_summary <- renderTable({
    dat <- raw_trial()
    req(dat)
    thr <- input$thr
    le <- detect_events(dat$time, dat$left, thr)
    re <- detect_events(dat$time, dat$right, thr)
    lss <- stride_stats(le$hs_time)
    rss <- stride_stats(re$hs_time)
    duration <- if (length(dat$time) > 1) max(dat$time, na.rm = TRUE) - min(dat$time, na.rm = TRUE) else NA_real_
    data.frame(
      metric = c("duration_s", "left_n_strides", "left_stride_mean_s", "left_stride_sd_s", "left_stride_cv_pct",
                 "right_n_strides", "right_stride_mean_s", "right_stride_sd_s", "right_stride_cv_pct",
                 "threshold_N"),
      value = c(
        round(duration, 3),
        lss$n, round(lss$mean, 3), round(lss$sd, 3), round(lss$cv, 2),
        rss$n, round(rss$mean, 3), round(rss$sd, 3), round(rss$cv, 2),
        round(le$thr, 1)
      ),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }, striped = TRUE, bordered = TRUE, hover = TRUE, spacing = "xs")
}

shinyApp(ui, server)