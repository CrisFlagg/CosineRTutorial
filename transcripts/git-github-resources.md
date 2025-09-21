# Git and GitHub for R users: beginner resources

This transcript collects beginner-friendly resources to help you understand Git and GitHub (branches, pull requests, daily workflow), with R/RStudio-specific guidance first.

## R-specific resources (start here)
- Happy Git and GitHub for the useR (Jenny Bryan) – the go-to guide for R users
  - https://happygitwithr.com/
- RStudio (Posit) Version Control – using Git inside RStudio
  - https://docs.posit.co/ide/user/ide/guide/tools/version-control.html
- R Packages (2e) – Git/GitHub chapter (Wickham & Bryan)
  - https://r-pkgs.org/git.html
- usethis (R package) – set up Git and GitHub from R
  - use_git(): https://usethis.r-lib.org/reference/use_git.html
  - create_github_token(): https://usethis.r-lib.org/reference/create_github_token.html
  - use_github(): https://usethis.r-lib.org/reference/use_github.html
- gitcreds (R) – securely store your GitHub token so pushes work
  - https://github.com/r-lib/gitcreds
- renv – manage R package versions for reproducibility
  - https://rstudio.github.io/renv/
- GitHub Actions for R (r-lib/actions) – run R CMD check automatically
  - https://github.com/r-lib/actions
  - Examples: https://github.com/r-lib/actions/tree/v2/examples
  - usethis helper: use_github_action_check_standard(): https://usethis.r-lib.org/reference/use_github_action_check_standard.html
- precommit (R) – optional quality checks before commits (styling, lintr)
  - https://lorenzwalthert.github.io/precommit/

## Beginner-friendly Git/GitHub
- GitHub Hello World (create repo → branch → PR → merge)
  - https://docs.github.com/en/get-started/quickstart/hello-world
- GitHub Skills: Introduction to GitHub (hands-on mini-course)
  - https://skills.github.com/ (choose “Introduction to GitHub”)
- Learn Git Branching (interactive with visuals)
  - https://learngitbranching.js.org/
- GitHub Desktop docs (GUI workflow—no command line)
  - https://docs.github.com/en/desktop
- Printable Git cheat sheet (GitHub Training)
  - https://training.github.com/downloads/github-git-cheat-sheet.pdf

## Deeper when ready
- Atlassian Git Tutorials (clear visuals)
  - https://www.atlassian.com/git
- Pro Git book – Branching basics and beyond
  - Basic Branching and Merging: https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging
  - Branches in a Nutshell: https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell

## Large files
- Git LFS (Large File Storage) – for versioning big files if you must
  - https://git-lfs.github.com/

## A 1–2 hour learning path
1) Do GitHub Hello World (first repo, branch, PR, merge).
2) Skim Happy Git with R (first chapters) and set up usethis + gitcreds in RStudio.
3) Print the Git cheat sheet.
4) Spend 10–15 minutes on Learn Git Branching (first few levels).

## Daily workflow (simple checklist)
- Pull first (keep your local copy up to date).
- Make changes on a branch (optional but safer).
- Stage → Commit with a short message.
- Push to GitHub.
- Open a Pull Request, review, and Merge.
- Switch back to main and Pull again so your local matches GitHub.

If you want, I can tailor a click-by-click guide for either GitHub Desktop or RStudio, set up a good .gitignore for R, or wire up GitHub Actions to run checks automatically on every push.