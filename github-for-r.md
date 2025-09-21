# GitHub for R: a beginner tutorial

Who this is for
- You use R/RStudio and want a simple, reliable way to save versions, back up to GitHub, and collaborate.
- You prefer clicks (GitHub Desktop) or staying inside RStudio (with usethis).

What you’ll learn (15–45 minutes)
- The basic mental model: commit, push, pull, branch, pull request (PR)
- Two simple workflows:
  - A) GitHub Desktop (GUI-only)
  - B) RStudio + usethis (R-native)
- How to merge Cosine’s pull requests into your main branch
- What to commit vs ignore for R projects

Prerequisites
- A GitHub account (https://github.com)
- R and RStudio installed
- Either GitHub Desktop (https://desktop.github.com) or the usethis package in R

---

## The mental model (1 minute)
- Commit: save a checkpoint on your computer with a short message.
- Push: send your commits up to GitHub (the cloud copy).
- Pull: bring any new commits from GitHub down to your computer.
- Branch: a safe workspace for a change (feature/fix) without touching main.
- Pull Request: propose merging your branch back into main after review.

---

## A) GitHub Desktop workflow (no command line)

Use this if you want a click-first experience.

1) Put your existing R project under Git
- Open GitHub Desktop
- File → Add Local Repository → choose your project folder (where R/, inst/, etc. live)
- If prompted, click “Create a repository” in this folder
- Commit message: “Initial commit” → Commit to main

2) Publish to GitHub
- Click “Publish repository”
- Choose Public or Private → Publish

3) Daily workflow
- Pull first (Repository → Pull)
- Work in RStudio as usual
- Switch to Desktop: review Changes → write a short commit message → Commit → Push (top bar)

4) Branches and PRs (recommended when trying changes)
- Branch → New Branch (e.g., feature-clean-transcripts)
- Commit and Push on that branch
- On GitHub.com, click “Compare & pull request” → Create pull request → Merge when ready
- After merging, in Desktop: switch to main → Pull

5) Merge Cosine’s changes (PRs)
- On GitHub.com → your repo → Pull requests tab → open Cosine’s PR
- Optional: click “Open with GitHub Desktop” to check out the PR branch locally and test
- Click “Merge pull request” → Confirm
- Back in Desktop: switch to main → Pull to update your local files

---

## B) RStudio + usethis (R-native)

Use this if you prefer to stay inside RStudio.

1) One-time setup
- Install helpers:
  - install.packages(c("usethis", "gitcreds"))
- Tell Git who you are:
  - usethis::use_git_config(user.name = "Your Name", user.email = "you@example.com")

2) Turn your existing project into a Git repo
- In RStudio, with the project open:
  - usethis::use_git()
- Accept the RStudio restart
- Use the Git tab to commit your files (select all → Commit)

3) Connect to GitHub
- Create a GitHub token:
  - usethis::create_github_token()
- Store it for Git to use:
  - gitcreds::gitcreds_set()
- Create the GitHub repo and push:
  - usethis::use_github()

4) Daily workflow in RStudio
- Git tab → Pull
- Make changes
- Git tab → stage files → write a short message → Commit → Push

5) Branches and PRs
- Create a branch: use Git tab (or git in Terminal), or use GitHub Desktop for simplicity
- Push the branch
- On GitHub.com: Open a Pull Request → review → Merge
- Back in RStudio: switch to main → Pull

6) Merge Cosine’s changes (PRs)
- On GitHub.com → Pull requests tab → open Cosine’s PR
- Click “Merge pull request” → Confirm
- In RStudio: Git tab → Pull (ensure you are on main)

---

## What to commit (and what to ignore)

Commit
- Your code and small data: R/, scripts/, tests/, DESCRIPTION, README, small CSVs
- Documentation, notebooks, and app code (e.g., inst/app)

Don’t commit
- Secrets (API keys, passwords) → keep in .Renviron (ignored)
- Large raw data or generated outputs (unless needed)
- Machine-generated files, caches, .Rhistory, .RData, .Rproj.user/

A good .gitignore for R (add to a file named .gitignore)

```
.Rhistory
.Rapp.history
.RData
.Ruserdata
.Rproj.user/

.DS_Store

# R build/check artifacts
.Rcheck/

# Knitr/rmarkdown caches
*_cache/
cache/

# renv (if you use it)
renv/library/
renv/staging/

# Packrat (older projects)
packrat/

# Logs / temporary
*.log
tmp/
temp/

# Keep secrets out of Git
.Renviron

# Optional: ignore large data or outputs (adjust as needed)
data/raw/
outputs/
figures/
```

---

## Common issues (and quick fixes)

- Can’t push (permission/auth)
  - Run gitcreds::gitcreds_set() and paste a new token from usethis::create_github_token()
  - Ensure your GitHub account has 2FA and the token has “repo” scope

- “Updates were rejected” or “diverged”
  - Pull first (Desktop: Pull; RStudio: Git tab → Pull)
  - If conflicts appear, open diffs, edit to resolve, then commit and push

- Wrong branch
  - Switch back to main (Desktop: Current Branch → main; RStudio Git tab → Checkout main)

- Large files
  - Don’t push big raw data; store externally or use Git LFS (https://git-lfs.github.com/)

---

## Daily checklist (copy/paste)

- Pull first
- Make changes (ideally on a branch)
- Stage → Commit with a short message
- Push
- If using a branch: open a PR on GitHub and Merge
- Switch to main and Pull again (so local matches GitHub)

---

## Helpful links

- GitHub Hello World: https://docs.github.com/en/get-started/quickstart/hello-world
- About pull requests: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests
- About branches: https://docs.github.com/articles/about-branches
- GitHub Desktop docs: https://docs.github.com/en/desktop
- Learn Git Branching (interactive): https://learngitbranching.js.org/
- Happy Git with R: https://happygitwithr.com/
- usethis: use_github(): https://usethis.r-lib.org/reference/use_github.html
- Git cheat sheet (PDF): https://training.github.com/downloads/github-git-cheat-sheet.pdf

Need a click-by-click for your exact setup (Desktop vs RStudio)? Ask and I’ll tailor it to your environment.