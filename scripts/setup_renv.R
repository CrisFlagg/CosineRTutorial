# Bootstrap renv and install project packages
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

if (!file.exists("renv/activate.R")) {
  message("Initializing renv for this project...")
  renv::init(bare = TRUE)
} else {
  message("Activating existing renv...")
  renv::activate()
}

pkgs <- c(
  "dplyr", "ggplot2", "tidyr", "readr",
  "shiny", "testthat", "devtools", "roxygen2"
)

message("Installing packages into the renv library (this may take a moment)...")
renv::install(pkgs)

message("Snapshotting the project library to renv.lock...")
renv::snapshot(prompt = FALSE)

message("Done. New R sessions in this project will auto-activate renv via .Rprofile.")