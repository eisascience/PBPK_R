#' Run PBPK Shiny Application
#'
#' Launches an interactive Shiny application for PBPK modeling of THC and CBD
#'
#' @param ... Additional arguments passed to shiny::runApp
#'
#' @return Starts the Shiny application
#' @import shiny
#' @import ggplot2
#' @export
run_pbpk_app <- function(...) {
  appDir <- system.file("shiny-app", package = "PBPKR")
  if (appDir == "") {
    # If package not installed, try to find app in current directory
    appDir <- file.path(getwd(), "inst", "shiny-app")
    if (!dir.exists(appDir)) {
      stop("Could not find Shiny app directory. Please ensure the package is properly installed.")
    }
  }
  shiny::runApp(appDir, ...)
}
