# Using Cosine.sh and R

# Setup
- git repository
- Cosine.s account

# Tutorials

## Setup Initial R Repository

This tutorial summarizes what was configured in this repository and why, and links to a complete transcript that walks through the process end-to-end.

What the transcript covers
- Repository goals for Cosine.sh + R and the overall approach
- Creating a reproducible environment with renv and auto-activation via .Rprofile
- Scaffolding a minimal R package (DESCRIPTION, R/, tests/) and documenting with roxygen2
- Bundling a Shiny app under inst/app and exposing a run_app() helper
- Setting up GitHub Actions to perform R CMD check on pushes/PRs
- Adding an example analysis script that generates versioned artifacts (CSV/PNG) in outputs/
- Using .gitignore and .Rbuildignore to keep caches and non-package files out of the build
- Repository layout and conventions to make collaboration and CI straightforward

What you’ll learn by reading it
- How to structure a new R repository that plays well with Cosine.sh
- How to initialize and manage renv for reproducibility
- How to create and export package functions and add unit tests with testthat
- How to embed and launch a Shiny app from within a package
- How to wire up CI for continuous checks with r-lib/actions
- How to produce and track analysis artifacts

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
