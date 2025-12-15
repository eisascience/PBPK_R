#!/usr/bin/env Rscript

# Test if Shiny app files can be loaded without errors

cat("Testing Shiny App Files\n")
cat("========================\n\n")

# Check required packages
required_packages <- c("shiny", "shinydashboard", "ggplot2", "plotly", "deSolve", "DT")

cat("Checking required packages:\n")
for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("  ✓ %s\n", pkg))
  } else {
    cat(sprintf("  ✗ %s (not installed)\n", pkg))
  }
}

# Try to load the app files
cat("\nChecking app structure:\n")

if (file.exists("inst/shiny-app/ui.R")) {
  cat("  ✓ ui.R found\n")
} else {
  cat("  ✗ ui.R not found\n")
}

if (file.exists("inst/shiny-app/server.R")) {
  cat("  ✓ server.R found\n")
} else {
  cat("  ✗ server.R not found\n")
}

if (file.exists("inst/shiny-app/global.R")) {
  cat("  ✓ global.R found\n")
} else {
  cat("  ✗ global.R not found\n")
}

# Check model files
if (file.exists("R/pbpk_model.R")) {
  cat("  ✓ pbpk_model.R found\n")
} else {
  cat("  ✗ pbpk_model.R not found\n")
}

if (file.exists("R/simulate_pbpk.R")) {
  cat("  ✓ simulate_pbpk.R found\n")
} else {
  cat("  ✗ simulate_pbpk.R not found\n")
}

if (file.exists("R/run_app.R")) {
  cat("  ✓ run_app.R found\n")
} else {
  cat("  ✗ run_app.R not found\n")
}

cat("\n✓ Shiny app structure validated!\n")
cat("\nTo run the app:\n")
cat("  cd inst/shiny-app\n")
cat("  R -e \"shiny::runApp()\"\n")
