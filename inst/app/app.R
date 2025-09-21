# Minimal Shiny app bundled with the package
# Run with: cosineR::run_app() after installing the package,
# or directly with: shiny::runApp("inst/app")

library(shiny)
library(ggplot2)

numeric_vars <- names(iris)[vapply(iris, is.numeric, logical(1))]

ui <- fluidPage(
  titlePanel("Iris Explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput("x", "X variable", choices = numeric_vars, selected = "Sepal.Length"),
      selectInput("y", "Y variable", choices = numeric_vars, selected = "Sepal.Width"),
      checkboxInput("smooth", "Add smoothing line", TRUE)
    ),
    mainPanel(
      plotOutput("scatter"),
      tableOutput("summary")
    )
  )
)

server <- function(input, output, session) {
  output$scatter <- renderPlot({
    p <- ggplot(iris, aes(.data[[input$x]], .data[[input$y]], color = Species)) +
      geom_point(alpha = 0.8) +
      theme_minimal()
    if (isTRUE(input$smooth)) {
      p <- p + geom_smooth(se = FALSE, method = "loess")
    }
    p
  })

  output$summary <- renderTable({
    num_vars <- vapply(iris, is.numeric, logical(1))
    data.frame(
      variable = names(iris)[num_vars],
      mean = vapply(iris[, num_vars, drop = FALSE], mean, numeric(1)),
      sd = vapply(iris[, num_vars, drop = FALSE], sd, numeric(1)),
      row.names = NULL,
      check.names = FALSE
    )
  })
}

shinyApp(ui, server)