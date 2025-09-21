#!/usr/bin/env Rscript

# Download and extract PD gait datasets into datasets/
# - gaitpdb: PhysioNet "Gait in Parkinson's Disease"
# - gaitndd: PhysioNet "Gait in Neurodegenerative Disease"
#
# Usage:
#   Rscript scripts/download_gait_datasets.R
#   Rscript scripts/download_gait_datasets.R --force   # re-download and re-extract
#
# Notes:
# - Requires only base R (utils). No extra packages needed.
# - Extracted folders will be created under datasets/{gaitpdb,gaitndd}
# - Large files are intentionally kept out of git via datasets/.gitignore

args <- commandArgs(trailingOnly = TRUE)
force_redownload <- any(args %in% c("--force", "-f"))

# Increase timeout for large downloads
options(timeout = max(600, getOption("timeout", 60)))

datasets <- list(
  list(
    name    = "gaitpdb",
    zip_url = "https://physionet.org/content/gaitpdb/get-zip/1.0.0/",
    sha_url = "https://physionet.org/content/gaitpdb/1.0.0/SHA256SUMS.txt",
    info    = "PhysioNet: Gait in Parkinson's Disease (vertical GRF via in-shoe sensors)"
  ),
  list(
    name    = "gaitndd",
    zip_url = "https://physionet.org/content/gaitndd/get-zip/1.0.0/",
    sha_url = "https://physionet.org/content/gaitndd/1.0.0/SHA256SUMS.txt",
    info    = "PhysioNet: Gait in Neurodegenerative Disease (footswitch signals + derived time series)"
  )
)

root <- getwd()
base_dir <- file.path(root, "datasets")
if (!dir.exists(base_dir)) dir.create(base_dir, recursive = TRUE, showWarnings = FALSE)

download_into <- function(d) {
  sub_dir <- file.path(base_dir, d$name)
  if (!dir.exists(sub_dir)) dir.create(sub_dir, recursive = TRUE, showWarnings = FALSE)

  existing_files <- list.files(sub_dir, recursive = TRUE, all.files = TRUE, no.. = TRUE)
  if (!force_redownload && length(existing_files) > 0) {
    message(sprintf("Skipping %s: found existing files in %s. Use --force to re-download.",
                    d$name, sub_dir))
    return(invisible(TRUE))
  }

  # If forcing, clear the subdirectory first
  if (force_redownload && length(existing_files) > 0) {
    message(sprintf("Removing existing contents in %s ...", sub_dir))
    unlink(list.files(sub_dir, full.names = TRUE, recursive = TRUE), recursive = TRUE, force = TRUE)
  }

  message(sprintf("\n[%s] %s", d$name, d$info))
  message(sprintf("[%s] Downloading ZIP from: %s", d$name, d$zip_url))

  zip_tmp <- tempfile(pattern = paste0(d$name, "_"), fileext = ".zip")
  utils::download.file(d$zip_url, destfile = zip_tmp, mode = "wb", quiet = FALSE)

  message(sprintf("[%s] Extracting into: %s", d$name, sub_dir))
  utils::unzip(zip_tmp, exdir = sub_dir)
  unlink(zip_tmp)

  # Try to fetch the upstream SHA256 list for reference
  if (!is.null(d$sha_url) && nzchar(d$sha_url)) {
    sha_dest <- file.path(sub_dir, "SHA256SUMS.txt")
    message(sprintf("[%s] Downloading upstream checksums: %s", d$name, d$sha_url))
    try(utils::download.file(d$sha_url, destfile = sha_dest, mode = "wb", quiet = TRUE), silent = TRUE)
  }

  n_files <- length(list.files(sub_dir, recursive = TRUE, all.files = TRUE, no.. = TRUE))
  message(sprintf("[%s] Done. Extracted %d files.", d$name, n_files))
  invisible(TRUE)
}

status <- vapply(datasets, download_into, logical(1))
if (all(status)) {
  message("\nAll requested datasets are ready under datasets/.")
} else {
  message("\nSome datasets failed to download or extract. See messages above.")
}