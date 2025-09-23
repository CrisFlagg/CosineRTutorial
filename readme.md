# Using Cosine.sh and R

# Setup
- git repository
- Cosine.s account

# Tutorials

## Cosine Signup and Student Discount

This tutorial explains how to sign up for Cosine (via cosine.sh/ai.cosine.sh), what to expect around the free trial and monthly billing, and practical ways to redeem the “3 months Pro free for students” promotion referenced on LinkedIn—even if the post link isn’t accessible. It includes suggested steps, what to send support, and ready‑to‑use message templates.

Transcript: [Cosine Signup and Student Discount – full transcript](transcripts/cosine-signup.md)

## Setup Initial R Repository

This brief overview explains how the repo is prepared to use R with Cosine.sh: a reproducible environment (renv), a small R package with documented and tested functions, a simple Shiny app you can open, an example analysis that saves shareable results, and automated GitHub checks to keep things working. The linked transcript walks through why each piece exists, how the folders fit together, and collaboration tips—written for readers without a CS background.

Transcript: [Setup Initial R Repository – full transcript](transcripts/r-repository-setup.md)

## Git and GitHub for R users

A curated, beginner-friendly list of resources explaining branches, pull requests, and daily Git/GitHub workflows, with R/RStudio-specific guidance.

- Tutorial: [GitHub for R – step-by-step tutorial](github-for-r.md)
- Transcript: [Git and GitHub for R users – conversation transcript](transcripts/git-github-resources.md)

## Parkinson’s Gait Datasets (gaitpdb & gaitndd)

This tutorial covers two PhysioNet datasets widely used for Parkinson’s gait research—gaitpdb (in‑shoe force sensors; PD + controls) and gaitndd (footswitch signals; PD, Huntington’s, ALS, controls). It explains what data are included, access/licensing, how to download them into this repo, and how to generate quick characterizations (duration, stride means/variability, swing/stance/double support) using the provided R scripts.

- Transcript: [Parkinson’s Gait Datasets – full transcript](transcripts/pd-gait-datasets.md)
- Scripts:
  - Download both datasets: [scripts/download_gait_datasets.R](scripts/download_gait_datasets.R)
  - Characterize gaitpdb: [scripts/characterize_gaitpdb.R](scripts/characterize_gaitpdb.R)
  - Characterize gaitndd: [scripts/characterize_gaitndd.R](scripts/characterize_gaitndd.R)
- Dataset folder notes: [datasets/README.md](datasets/README.md)

Quick commands:
- Rscript scripts/download_gait_datasets.R
- Rscript scripts/characterize_gaitpdb.R
- Rscript scripts/characterize_gaitndd.R

## Shiny Gait Explorer (plotly + raw trial viewer)

Explore gaitpdb and gaitndd interactively with a bundled Shiny app that includes:
- Distribution panel (plotly): histogram of any numeric metric, colorable by group (PD vs control where available), adjustable bins.
- Trial browser (DT): filterable/selectable table of summarized trials/records with key metrics.
- Raw trial viewer (gaitpdb): plots left/right total force over time, overlays heel‑strike markers with an adjustable threshold slider.

Transcript: [Shiny Gait Explorer – full transcript](transcripts/shiny-gait-explorer.md)

Files (app and supporting setup):
- App entry: [inst/app/app.R](inst/app/app.R)
- renv installer (adds plotly, DT): [scripts/setup_renv.R](scripts/setup_renv.R)
- Package imports: [DESCRIPTION](DESCRIPTION)

Prerequisites
- Make sure the characterization outputs exist:
  - gaitpdb: outputs/gaitpdb/characterization_trials.csv
  - gaitndd: outputs/gaitndd/characterization_records.csv
- If not present, generate them:
  - Rscript scripts/characterize_gaitpdb.R
  - Rscript scripts/characterize_gaitndd.R

Run the app
- Initialize dependencies (renv):
  - Rscript scripts/setup_renv.R
- Launch:
  - Direct: R -e "shiny::runApp('inst/app')"
  - Via helper: R -e "devtools::load_all(); cosineR::run_app()"

Notes
- Interactivity uses plotly; tables use DT.
- Raw trial viewer expects gaitpdb trial .txt files under datasets/gaitpdb/... (use the download script if needed).

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

## Note on Creating Transcripts

Transcripts in this repository are generated with an additional instruction added to the Cosine system prompt:

"When you are instructed to create a transcript the purpose is to show the exact interactions that occurred during a session.  This will allow students to read the transcript and understand how to interact with Cosine.  The transcript should be a complete as possible, showing the user input and as close to the Cosine internal step-by-step process and end result as possible."

A transcript of this discussion has been created and linked here: [Creating Transcripts – full transcript](transcripts/creating-transcripts.md)
