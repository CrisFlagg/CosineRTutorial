# AGENTS.md

This file gives coding agents a safe, reliable workflow for contributing to this repository.

## 1) Project purpose and scope

This repository contains:
- An R package (`cosineR`) with small exported utilities.
- Data scripts for downloading and characterizing external gait datasets.
- A bundled Shiny app for interactive dataset exploration.
- Documentation/transcripts for student-facing tutorials.

Primary goals for agent changes:
- Keep setup and run commands reproducible.
- Avoid committing large/generated data.
- Preserve beginner-friendly workflow in docs.

---

## 2) Repository map (quick orientation)

- `R/` - package functions (e.g., `mean_sd()`, `run_app()`).
- `inst/app/` - Shiny app (`inst/app/app.R`).
- `scripts/` - environment setup, analysis, dataset download, dataset characterization.
- `tests/testthat/` - unit tests.
- `datasets/` - local downloaded data (ignored by git except README/.gitignore).
- `outputs/` - generated analysis/characterization artifacts (ignored by git).
- `.github/workflows/R-CMD-check.yaml` - CI check workflow.

---

## 3) Required setup sequence

From repo root, run:

1. Initialize dependencies
   - `Rscript scripts/setup_renv.R`
2. Download datasets (only if working on dataset or app tasks)
   - `Rscript scripts/download_gait_datasets.R`
   - Use `--force` only when intentionally re-downloading:
     - `Rscript scripts/download_gait_datasets.R --force`
3. Generate characterization outputs needed by app/docs
   - `Rscript scripts/characterize_gaitpdb.R`
   - `Rscript scripts/characterize_gaitndd.R`

Notes:
- Dataset downloads can be large and may take several minutes.
- Do not assume datasets/outputs exist in a fresh checkout.

---

## 4) Preflight checks before coding

Confirm these expected files exist when your task depends on them:

- `outputs/gaitpdb/characterization_trials.csv`
- `outputs/gaitndd/characterization_records.csv`

If missing, generate them using the characterization scripts before running app-related checks.

For Shiny work, launch with one of:
- `R -e "shiny::runApp('inst/app')"`
- `R -e "devtools::load_all(); cosineR::run_app()"`

---

## 5) Validation checklist before committing

Run the minimum applicable checks for your change:

- Package tests:
  - `R -e "devtools::test()"`
- Example analysis:
  - `Rscript scripts/analysis.R`
- If app or data logic changed:
  - Re-run characterization scripts as needed
  - Smoke test app launch

CI alignment:
- CI runs roxygen and `rcmdcheck`; keep code compatible with `.github/workflows/R-CMD-check.yaml`.

---

## 6) Data and git safety guardrails

Always:
- Keep downloaded dataset contents out of git.
- Keep generated `outputs/` artifacts out of git.
- Commit only source code/docs/tests/config changes relevant to the task.

Never:
- Commit `datasets/gaitpdb/*` or `datasets/gaitndd/*` payloads.
- Commit `outputs/*` generated files.
- Remove user-authored files or rewrite history unless explicitly requested.

---

## 7) Known pitfalls and conventions

- Several scripts use `library(tidyverse)`. Ensure required packages are available in your environment.
- The Shiny app expects characterization CSVs in `outputs/`; missing files produce empty views.
- Preserve beginner-friendly README commands and wording when updating docs.
- Prefer small, focused commits with clear messages.

---

## 8) Definition of done

A task is done when:

1. The requested change is implemented.
2. Relevant checks pass locally.
3. No ignored/generated dataset/output artifacts are staged.
4. Docs remain accurate for a clean checkout workflow.

