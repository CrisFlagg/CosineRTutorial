#' Run the bundled Shiny app
#'
#' Launches the Shiny app included in `inst/app`.
#' @param ... Additional parameters passed to `shiny::runApp()`.
#' @export
run_app <- function(...) {
  app_dir <- system.file("app", package = "cosineR")
  if (app_dir == "") {
    stop("Could not find app directory. Try re-installing this package.")
  }
  shiny::runApp(appDir = app_dir, ...)
}