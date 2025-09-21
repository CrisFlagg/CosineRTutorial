# Using Cosine.sh and R

# Setup
- git repository
- Cosine.s account

# Tutorials

## Setup Initial R Repository

This brief overview explains how the repo is prepared to use R with Cosine.sh: a reproducible environment (renv), a small R package with documented and tested functions, a simple Shiny app you can open, an example analysis that saves shareable results, and automated GitHub checks to keep things working. The linked transcript walks through why each piece exists, how the folders fit together, and collaboration tips—written for readers without a CS background.

Transcript: [Setup Initial R Repository – full transcript](transcripts/r-repository-setup.md)

---

Project now includes:
- R package scaffold (cosineR) with unit tests and CI
- Bundled Shiny app (inst/app/app.R) and helper `run_app()`
- Example analysis script (scripts/analysis.R)
- renv setup script for reproducible environments

## Quick start

1) Initialize renv and install deps
- From the project root, run:
  - Rscript scripts/setup_renv.R

2) Run the example analysis
- Rscript scripts/analysis.R
- Outputs are written to:
  - outputs/summary.csv
  - outputs/plot.png

3) Run the Shiny app
- Option A (direct):
  - R -e "shiny::runApp('inst/app')"
- Option B (via package helper):
  - R -e "devtools::load_all(); cosineR::run_app()"

4) Develop and test the package
- Generate docs:
  - R -e "roxygen2::roxygenise()"
- Run tests:
  - R -e "devtools::test()"
- Install locally:
  - R -e "devtools::install_local()"

## CI

GitHub Actions workflow (.github/workflows/R-CMD-check.yaml) runs R CMD check on pushes and pull requests (main/master). It roxygenises docs before checking.

## Notes

- The package exports:
  - mean_sd(): utility returning mean and sd for a numeric vector
  - run_app(): launches the bundled Shiny app
- .Rprofile auto-activates renv when present.
- Edit DESCRIPTION to update package metadata (name, author, URLs) as needed.
