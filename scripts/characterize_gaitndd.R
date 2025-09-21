#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
})

# Characterize PhysioNet "Gait in Neurodegenerative Disease" (gaitndd)
# - Summarizes per-record duration and stride/swing/stance/double-support statistics from .ts files.
# - Outputs CSV summaries and overview plots into outputs/gaitndd/.
#
# Assumptions:
# - Data were downloaded via scripts/download_gait_datasets.R
# - Files are under datasets/gaitndd/gaitndd-1.0.0/
#
# References:
# - https://physionet.org/content/gaitndd/1.0.0/
# - .ts columns (tab-separated):
#   1) time (s), 2) L stride, 3) R stride, 4) L swing (s), 5) R swing (s),
#   6) L swing (%), 7) R swing (%), 8) L stance (s), 9) R stance (s),
#   10) L stance (%), 11) R stance (%), 12) double support (s), 13) double support (%)

dataset_base <- file.path("datasets", "gaitndd")

resolve_dataset_dir <- function(base_dir) {
  if (!dir.exists(base_dir)) return(NA_character_)
  subdirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
  cand <- subdirs[grepl("gaitndd", basename(subdirs), ignore.case = TRUE)]
  if (length(cand) > 0) return(cand[[1]])
  return(base_dir)
}

ds_dir <- resolve_dataset_dir(dataset_base)
if (is.na(ds_dir) || !dir.exists(ds_dir)) {
  stop("Dataset folder not found. Run: Rscript scripts/download_gait_datasets.R")
}

# Output folders
out_dir <- file.path("outputs", "gaitndd")
plot_dir <- file.path(out_dir, "plots")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(plot_dir, recursive = TRUE, showWarnings = FALSE)

# .ts files list
ts_files <- list.files(ds_dir, pattern = "\\.ts$", full.names = TRUE)
if (length(ts_files) == 0) {
  stop("No .ts files found in gaitndd. Check that data were extracted into datasets/gaitndd/ ...")
}

# Subject description (optional, for reference)
subj_desc_path <- file.path(ds_dir, "subject-description.txt")
subj_desc <- NULL
if (file.exists(subj_desc_path)) {
  subj_desc <- tryCatch(
    readr::read_tsv(subj_desc_path, col_names = FALSE, show_col_types = FALSE),
    error = function(e) NULL
  )
  if (!is.null(subj_desc) && ncol(subj_desc) >= 1) {
    names(subj_desc)[1] <- "record"
  }
}

# Helper: get record id and group from filename
parse_record_id <- function(path) {
  b <- tools::file_path_sans_ext(basename(path))
  group <- sub("[0-9]+$", "", b)  # prefix: park, hunt, als, control
  tibble(
    file = path,
    record = b,
    group = dplyr::case_when(
      group == "park" ~ "pd",
      group == "control" ~ "control",
      group == "hunt" ~ "huntington",
      group == "als" ~ "als",
      TRUE ~ group
    )
  )
}

# Summarize one .ts file
summarize_ts <- function(f) {
  dat <- suppressWarnings(readr::read_tsv(
    f, col_names = FALSE, show_col_types = FALSE, progress = FALSE
  ))
  if (ncol(dat) < 13) return(NULL)
  names(dat) <- c(
    "time_s", "l_stride_s", "r_stride_s", "l_swing_s", "r_swing_s",
    "l_swing_pct", "r_swing_pct", "l_stance_s", "r_stance_s",
    "l_stance_pct", "r_stance_pct", "ds_s", "ds_pct"
  )
  # Duration = last time stamp
  duration_s <- if (nrow(dat) > 0) max(dat$time_s, na.rm = TRUE) else NA_real_

  # Helper to make stats safely
  smean <- function(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
  ssd   <- function(x) if (all(is.na(x))) NA_real_ else sd(x, na.rm = TRUE)
  scv   <- function(x) {
    m <- smean(x); s <- ssd(x)
    if (is.na(m) || m <= 0) NA_real_ else 100 * s / m
  }

  tibble(
    file = f,
    duration_s = duration_s,
    n_rows = nrow(dat),
    l_stride_mean_s = smean(dat$l_stride_s),
    l_stride_sd_s = ssd(dat$l_stride_s),
    l_stride_cv_pct = scv(dat$l_stride_s),
    r_stride_mean_s = smean(dat$r_stride_s),
    r_stride_sd_s = ssd(dat$r_stride_s),
    r_stride_cv_pct = scv(dat$r_stride_s),
    l_swing_mean_s = smean(dat$l_swing_s),
    r_swing_mean_s = smean(dat$r_swing_s),
    l_swing_mean_pct = smean(dat$l_swing_pct),
    r_swing_mean_pct = smean(dat$r_swing_pct),
    l_stance_mean_s = smean(dat$l_stance_s),
    r_stance_mean_s = smean(dat$r_stance_s),
    l_stance_mean_pct = smean(dat$l_stance_pct),
    r_stance_mean_pct = smean(dat$r_stance_pct),
    ds_mean_s = smean(dat$ds_s),
    ds_mean_pct = smean(dat$ds_pct)
  )
}

message("Scanning gaitndd .ts files ...")
ids <- map_dfr(ts_files, parse_record_id)
summ <- map_dfr(ts_files, summarize_ts)

summary_records <- ids %>%
  left_join(summ, by = "file") %>%
  relocate(group, record, .after = file) %>%
  mutate(dataset = "gaitndd")

# Write per-record summary
out_csv <- file.path(out_dir, "characterization_records.csv")
readr::write_csv(summary_records, out_csv)
message("Wrote: ", out_csv)

# Overview by group
overview <- summary_records %>%
  group_by(group) %>%
  summarise(
    n_records = n(),
    mean_duration_s = mean(duration_s, na.rm = TRUE),
    median_l_stride_s = median(l_stride_mean_s, na.rm = TRUE),
    median_r_stride_s = median(r_stride_mean_s, na.rm = TRUE),
    median_l_cv_pct = median(l_stride_cv_pct, na.rm = TRUE),
    median_r_cv_pct = median(r_stride_cv_pct, na.rm = TRUE),
    median_ds_pct = median(ds_mean_pct, na.rm = TRUE),
    .groups = "drop"
  )

out_overview <- file.path(out_dir, "characterization_overview.csv")
readr::write_csv(overview, out_overview)
message("Wrote: ", out_overview)

# Plots
p1 <- summary_records %>%
  filter(group %in% c("pd", "control")) %>%
  ggplot(aes(x = l_stride_mean_s, fill = group)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 30) +
  labs(
    title = "gaitndd: Left stride mean (s) by group",
    x = "Left stride mean (s)", y = "Count"
  ) +
  theme_minimal()

p2 <- summary_records %>%
  filter(group %in% c("pd", "control")) %>%
  ggplot(aes(x = r_stride_mean_s, fill = group)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 30) +
  labs(
    title = "gaitndd: Right stride mean (s) by group",
    x = "Right stride mean (s)", y = "Count"
  ) +
  theme_minimal()

ggplot2::ggsave(file.path(plot_dir, "left_stride_mean_hist.png"), p1, width = 7, height = 5, dpi = 150)
ggplot2::ggsave(file.path(plot_dir, "right_stride_mean_hist.png"), p2, width = 7, height = 5, dpi = 150)

message("Saved plots to: ", plot_dir)
print(overview)
message("Characterization complete for gaitndd.")