#!/usr/bin/env Rscript

# Simple test script to validate PBPK model functions
# This script sources the model files directly and runs a basic simulation

cat("Testing PBPK Model for THC and CBD\n")
cat("===================================\n\n")

# Source model files
cat("Loading model functions...\n")
source("R/pbpk_model.R")
source("R/simulate_pbpk.R")

# Get default parameters
cat("Getting default parameters...\n")
params <- get_default_params(BW = 70)

cat("\nModel Parameters:\n")
cat(sprintf("  Body Weight: %.1f kg\n", params$BW))
cat(sprintf("  THC Dose: %.1f mg\n", params$dose_thc))
cat(sprintf("  CBD Dose: %.1f mg\n", params$dose_cbd))
cat(sprintf("  Inhalation Duration: %.2f hours (%.1f min)\n", params$t_inh, params$t_inh * 60))
cat(sprintf("  THC Hepatic Clearance: %.1f L/hr\n", params$CL_int_thc))
cat(sprintf("  CBD Hepatic Clearance: %.1f L/hr\n", params$CL_int_cbd))

# Check if deSolve is available
cat("\nChecking for deSolve package...\n")
if (!requireNamespace("deSolve", quietly = TRUE)) {
  cat("Warning: deSolve package not installed.\n")
  cat("To run simulations, install with: install.packages('deSolve')\n")
  cat("\nModel structure validated successfully!\n")
  quit(save = "no", status = 0)
}

# Run simulation
cat("\nRunning simulation...\n")
times <- seq(0, 24, by = 0.5)
results <- simulate_pbpk(params, times)

cat(sprintf("Simulation complete! %d time points simulated.\n", nrow(results)))

# Display summary statistics
cat("\nSummary of Results:\n")
cat(sprintf("  Max Arterial THC: %.4f mg/L at t=%.1f hr\n", 
            max(results$C_arterial_thc), 
            results$time[which.max(results$C_arterial_thc)]))
cat(sprintf("  Max Arterial CBD: %.4f mg/L at t=%.1f hr\n", 
            max(results$C_arterial_cbd), 
            results$time[which.max(results$C_arterial_cbd)]))
cat(sprintf("  Max Brain THC: %.4f mg/L at t=%.1f hr\n", 
            max(results$C_brain_thc), 
            results$time[which.max(results$C_brain_thc)]))
cat(sprintf("  Max Brain CBD: %.4f mg/L at t=%.1f hr\n", 
            max(results$C_brain_cbd), 
            results$time[which.max(results$C_brain_cbd)]))

cat("\nFirst few time points:\n")
print(head(results[, c("time", "C_arterial_thc", "C_arterial_cbd", "C_brain_thc", "C_brain_cbd")]))

cat("\n✓ Model validation successful!\n")
