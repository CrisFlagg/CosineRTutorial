#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
})

# Characterize PhysioNet "Gait in Parkinson's Disease" (gaitpdb)
# - Summarizes per-trial duration and stride statistics derived from per-foot total force.
# - Outputs CSV summaries and a few overview plots into outputs/gaitpdb/.
#
# Assumptions:
# - Data were downloaded via scripts/download_gait_datasets.R
# - Files are under datasets/gaitpdb/gaitpdb-1.0.0/
# - Sampling rate = 100 Hz
#
# References:
# - https://physionet.org/content/gaitpdb/1.0.0/
# - format.txt describes the 19-column layout
#
# Columns per row (tab-separated):
# 1: time (s)
# 2–9: left foot sensors (N), 10–17: right foot sensors (N)
# 18: total left force (N), 19: total right force (N)

dataset_base <- file.path("datasets", "gaitpdb")
sampling_rate <- 100

# Resolve extracted directory (gaitpdb-1.0.0) if present
resolve_dataset_dir <- function(base_dir) {
  if (!dir.exists(base_dir)) return(NA_character_)
  subdirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
  cand <- subdirs[grepl("gaitpdb", basename(subdirs), ignore.case = TRUE)]
  if (length(cand) > 0) return(cand[[1]])
  return(base_dir)
}

ds_dir <- resolve_dataset_dir(dataset_base)
if (is.na(ds_dir) || !dir.exists(ds_dir)) {
  stop("Dataset folder not found. Run: Rscript scripts/download_gait_datasets.R")
}

# Output folders
out_dir <- file.path("outputs", "gaitpdb")
plot_dir <- file.path(out_dir, "plots")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(plot_dir, recursive = TRUE, showWarnings = FALSE)

# Identify data files (exclude non-trial text files)
all_txt <- list.files(ds_dir, pattern = "\\.txt$", full.names = TRUE)
trial_files <- all_txt[grepl("_[0-9]+\\.txt$", basename(all_txt)) &
                         !grepl("SHA256|demo|format|readme|README", basename(all_txt), ignore.case = TRUE)]

if (length(trial_files) == 0) {
  stop("No gaitpdb trial files found. Check that data were extracted into datasets/gaitpdb/ ...")
}

# Helper: parse group/subject/trial from filename
parse_id <- function(fname) {
  b <- tools::file_path_sans_ext(basename(fname))
  tibble(
    file = fname,
    base = b,
    group = case_when(
      grepl("Co", b) ~ "control",
      grepl("Pt", b) ~ "pd",
      TRUE ~ "unknown"
    ),
    study = substr(b, 1, 2),
    subj_num = {
      m <- regmatches(b, regexpr("(Co|Pt)([0-9]+)", b))
      sub("^.*(Co|Pt)([0-9]+).*$", "\\2", m)
    },
    walk_id = {
      m <- regmatches(b, regexpr("_(\\d+)$", b))
      sub("^_+", "", sub("^.*_(\\d+)$", "\\1", m))
    }
  )
}

# Helper: detect heel-strike and toe-off from total force using threshold + hysteresis
detect_events <- function(time, total_force, thrN = NULL) {
  # dynamic threshold if not supplied
  if (is.null(thrN)) {
    # Use max(50 N, 5% of max force)
    thrN <- max(50, 0.05 * max(total_force, na.rm = TRUE))
  }
  st <- total_force > thrN
  d <- diff(as.integer(st))
  hs_idx <- which(d == 1L) + 1L  # rising edge: heel strike
  to_idx <- which(d == -1L) + 1L # falling edge: toe off
  list(
    hs_time = time[hs_idx],
    to_time = time[to_idx],
    hs_idx = hs_idx,
    to_idx = to_idx,
    thr = thrN
  )
}

# Helper: stride times from successive heel strikes
stride_stats <- function(hs_time) {
  if (length(hs_time) < 2) {
    return(tibble(
      n_strides = 0L,
      stride_mean = NA_real_,
      stride_sd = NA_real_,
      stride_cv = NA_real_
    ))
  }
  st <- diff(hs_time)
  tibble(
    n_strides = length(st),
    stride_mean = mean(st, na.rm = TRUE),
    stride_sd = sd(st, na.rm = TRUE),
    stride_cv = ifelse(mean(st, na.rm = TRUE) > 0, 100 * sd(st, na.rm = TRUE) / mean(st, na.rm = TRUE), NA_real_)
  )
}

# Read one trial, compute summary
summarize_trial <- function(f) {
  dat <- suppressWarnings(readr::read_tsv(
    f, col_names = FALSE, progress = FALSE, show_col_types = FALSE
  ))
  # Expect at least 19 columns
  if (ncol(dat) < 19) {
    return(NULL)
  }
  time <- dat[[1]]
  # Prefer provided totals in cols 18/19; fallback to sums
  left_total  <- if (ncol(dat) >= 18) dat[[18]] else rowSums(dat[, 2:9, drop = FALSE])
  right_total <- if (ncol(dat) >= 19) dat[[19]] else rowSums(dat[, 10:17, drop = FALSE])

  # Events
  le <- detect_events(time, left_total)
  re <- detect_events(time, right_total)

  # Stride stats
  lss <- stride_stats(le$hs_time)
  rss <- stride_stats(re$hs_time)

  duration_s <- if (!is.null(time) && length(time) > 1) {
    max(time, na.rm = TRUE) - min(time, na.rm = TRUE)
  } else {
    length(time) / sampling_rate
  }

  tibble(
    file = f,
    duration_s = duration_s,
    left_thr_N = le$thr,
    right_thr_N = re$thr,
    left_n_strides = lss$n_strides,
    left_stride_mean_s = lss$stride_mean,
    left_stride_sd_s = lss$stride_sd,
    left_stride_cv_pct = lss$stride_cv,
    right_n_strides = rss$n_strides,
    right_stride_mean_s = rss$stride_mean,
    right_stride_sd_s = rss$stride_sd,
    right_stride_cv_pct = rss$stride_cv
  )
}

message("Scanning gaitpdb trial files ...")
ids <- map_dfr(trial_files, parse_id)
summ <- map_dfr(trial_files, summarize_trial)

# Merge IDs with summaries
summary_trials <- ids %>%
  select(file, base, study, group, subj_num, walk_id) %>%
  left_join(summ, by = "file") %>%
  relocate(study, group, subj_num, walk_id, .after = base)

# Write per-trial summary
out_csv <- file.path(out_dir, "characterization_trials.csv")
readr::write_csv(summary_trials, out_csv)
message("Wrote: ", out_csv)

# Aggregate overview by group
overview <- summary_trials %>%
  mutate(dataset = "gaitpdb") %>%
  group_by(group) %>%
  summarise(
    n_trials = n(),
    mean_duration_s = mean(duration_s, na.rm = TRUE),
    median_left_stride_s = median(left_stride_mean_s, na.rm = TRUE),
    median_right_stride_s = median(right_stride_mean_s, na.rm = TRUE),
    median_left_cv_pct = median(left_stride_cv_pct, na.rm = TRUE),
    median_right_cv_pct = median(right_stride_cv_pct, na.rm = TRUE),
    .groups = "drop"
  )

out_overview <- file.path(out_dir, "characterization_overview.csv")
readr::write_csv(overview, out_overview)
message("Wrote: ", out_overview)

# Plots: distribution of stride mean by group
p1 <- summary_trials %>%
  filter(!is.na(left_stride_mean_s), group %in% c("pd", "control")) %>%
  ggplot(aes(x = left_stride_mean_s, fill = group)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 30) +
  labs(
    title = "gaitpdb: Left stride mean (s) by group",
    x = "Left stride mean (s)", y = "Count"
  ) +
  theme_minimal()

p2 <- summary_trials %>%
  filter(!is.na(right_stride_mean_s), group %in% c("pd", "control")) %>%
  ggplot(aes(x = right_stride_mean_s, fill = group)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 30) +
  labs(
    title = "gaitpdb: Right stride mean (s) by group",
    x = "Right stride mean (s)", y = "Count"
  ) +
  theme_minimal()

ggplot2::ggsave(file.path(plot_dir, "left_stride_mean_hist.png"), p1, width = 7, height = 5, dpi = 150)
ggplot2::ggsave(file.path(plot_dir, "right_stride_mean_hist.png"), p2, width = 7, height = 5, dpi = 150)

message("Saved plots to: ", plot_dir)

# Done
print(overview)
message("Characterization complete for gaitpdb.")