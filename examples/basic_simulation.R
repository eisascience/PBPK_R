#!/usr/bin/env Rscript

# Basic PBPK Simulation Example
# Demonstrates how to run a simple simulation with default parameters

library(deSolve)
library(ggplot2)

# Source the model functions (if package not installed)
source("../R/pbpk_model.R")
source("../R/simulate_pbpk.R")

cat("=== Basic PBPK Simulation Example ===\n\n")

# Get default parameters for a 70 kg individual
cat("Loading default parameters for 70 kg individual...\n")
params <- get_default_params(BW = 70)

# Display key parameters
cat("\nKey Parameters:\n")
cat(sprintf("  THC Dose: %.1f mg\n", params$dose_thc))
cat(sprintf("  CBD Dose: %.1f mg\n", params$dose_cbd))
cat(sprintf("  Inhalation Duration: %.1f minutes\n", params$t_inh * 60))
cat(sprintf("  Body Weight: %.1f kg\n", params$BW))

# Run simulation for 24 hours
cat("\nRunning simulation for 24 hours...\n")
times <- seq(0, 24, by = 0.1)
results <- simulate_pbpk(params, times)

cat("Simulation complete!\n")

# Calculate some summary statistics
max_thc_arterial <- max(results$C_arterial_thc)
time_max_thc <- results$time[which.max(results$C_arterial_thc)]
max_cbd_arterial <- max(results$C_arterial_cbd)
time_max_cbd <- results$time[which.max(results$C_arterial_cbd)]

cat("\nSummary Statistics:\n")
cat(sprintf("  Peak arterial THC: %.3f mg/L at %.2f hours\n", max_thc_arterial, time_max_thc))
cat(sprintf("  Peak arterial CBD: %.3f mg/L at %.2f hours\n", max_cbd_arterial, time_max_cbd))
cat(sprintf("  THC elimination half-life (approx): %.2f hours\n", 
            log(2) / (params$CL_int_thc / params$V_art)))
cat(sprintf("  CBD elimination half-life (approx): %.2f hours\n", 
            log(2) / (params$CL_int_cbd / params$V_art)))

# Create visualization
cat("\nGenerating plot...\n")

png("basic_simulation_arterial.png", width = 800, height = 600)
p <- ggplot(results, aes(x = time)) +
  geom_line(aes(y = C_arterial_thc, color = "THC"), size = 1.2) +
  geom_line(aes(y = C_arterial_cbd, color = "CBD"), size = 1.2) +
  labs(
    title = "Arterial Blood Concentrations After Inhalation",
    subtitle = sprintf("THC: %.1f mg, CBD: %.1f mg (70 kg individual)", 
                       params$dose_thc, params$dose_cbd),
    x = "Time (hours)",
    y = "Concentration (mg/L)",
    color = "Compound"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c("THC" = "#E74C3C", "CBD" = "#3498DB"))
print(p)
dev.off()

cat("Plot saved to: basic_simulation_arterial.png\n")

# Save results to CSV
write.csv(results, "basic_simulation_results.csv", row.names = FALSE)
cat("Results saved to: basic_simulation_results.csv\n")

cat("\n✓ Example complete!\n")
