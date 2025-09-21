# Using Cosine.sh and R

# Setup
- git repository
- Cosine.s account

# Tutorials

## Setup Initial R Repository

This tutorial explains, in plain language, how this repository was set up to use R with Cosine.sh and what each moving part does. It links to a full, step-by-step transcript you can read at your own pace.

What the transcript covers (plain English)
- Reproducible setup (renv): A project-specific “list of packages and versions.” It makes your computer and your teammate’s computer use the same R packages. The .Rprofile file automatically turns this on when you open the project.
- Your “toolbox” (R package): We created a simple R package (a folder of reusable functions). It includes:
  - Functions in R/
  - Help pages generated from short comments (roxygen2)
  - Small tests to catch mistakes (testthat)
- A small app (Shiny): A clickable web page that uses R. It lives in inst/app and you can open it with run_app(). Great for demos or quick exploration.
- An example analysis: A single R script that reads data, summarizes it, and saves two files you can share: outputs/summary.csv and outputs/plot.png.
- Automatic checks (CI): A GitHub “robot” that builds and tests the project each time you push changes. This helps catch problems early and keeps the project consistent.
- Housekeeping: .gitignore and .Rbuildignore keep temporary files out of Git and out of your package build so you only share what matters.

What you’ll learn by reading it
- The basic vocabulary (renv, package, Shiny, CI) explained without jargon
- How the folders fit together and where to put your own work
- How analysis files produce shareable results in outputs/
- How the Shiny app is bundled and launched
- How automated checks protect your project over time
- Tips for collaborating without “it works on my machine” problems

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
