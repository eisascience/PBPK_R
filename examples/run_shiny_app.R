#!/usr/bin/env Rscript

# Run Shiny App Example
# This script launches the interactive PBPK Shiny application

cat("=== PBPK Shiny Application ===\n\n")
cat("Launching interactive PBPK modeling application...\n")
cat("The app will open in your default web browser.\n\n")
cat("Features:\n")
cat("  - Interactive parameter adjustment\n")
cat("  - Real-time simulation\n")
cat("  - Multiple visualization plots\n")
cat("  - Data export to CSV\n\n")
cat("Press Ctrl+C to stop the application.\n\n")

# Check if running from package or source
if (requireNamespace("PBPKR", quietly = TRUE)) {
  cat("Loading from installed package...\n")
  library(PBPKR)
  run_pbpk_app()
} else {
  cat("Loading from source files...\n")
  app_dir <- "../inst/shiny-app"
  if (dir.exists(app_dir)) {
    shiny::runApp(app_dir)
  } else {
    # Try alternative path
    app_dir <- "inst/shiny-app"
    if (dir.exists(app_dir)) {
      shiny::runApp(app_dir)
    } else {
      stop("Could not find Shiny app directory. Please run from package root.")
    }
  }
}
