#!/usr/bin/env Rscript

# Custom Parameters Example
# Demonstrates how to modify model parameters for different scenarios

library(deSolve)
library(ggplot2)

# Source the model functions (if package not installed)
source("../R/pbpk_model.R")
source("../R/simulate_pbpk.R")

cat("=== Custom Parameters Example ===\n\n")

# Scenario 1: High dose inhalation (heavy user)
cat("Scenario 1: High-dose inhalation (25 mg THC, 15 mg CBD)\n")
params1 <- get_default_params(BW = 70)
params1$dose_thc <- 25
params1$dose_cbd <- 15
params1$t_inh <- 0.17  # 10 minutes

# Scenario 2: Light dose (occasional user)
cat("Scenario 2: Low-dose inhalation (5 mg THC, 3 mg CBD)\n")
params2 <- get_default_params(BW = 70)
params2$dose_thc <- 5
params2$dose_cbd <- 3
params2$t_inh <- 0.05  # 3 minutes

# Scenario 3: Higher body weight individual
cat("Scenario 3: Heavier individual (100 kg, 10 mg THC, 5 mg CBD)\n")
params3 <- get_default_params(BW = 100)
params3$dose_thc <- 10
params3$dose_cbd <- 5

# Run all simulations
cat("\nRunning simulations...\n")
times <- seq(0, 24, by = 0.1)

results1 <- simulate_pbpk(params1, times)
results1$scenario <- "High Dose (25mg THC)"

results2 <- simulate_pbpk(params2, times)
results2$scenario <- "Low Dose (5mg THC)"

results3 <- simulate_pbpk(params3, times)
results3$scenario <- "Heavy Individual (100kg)"

# Combine results
all_results <- rbind(results1, results2, results3)

cat("Simulations complete!\n")

# Print peak concentrations for each scenario
cat("\nPeak Arterial THC Concentrations:\n")
for (scenario in unique(all_results$scenario)) {
  subset_data <- all_results[all_results$scenario == scenario, ]
  max_conc <- max(subset_data$C_arterial_thc)
  time_max <- subset_data$time[which.max(subset_data$C_arterial_thc)]
  cat(sprintf("  %s: %.3f mg/L at %.2f hours\n", scenario, max_conc, time_max))
}

# Create comparison plot
cat("\nGenerating comparison plot...\n")

png("custom_parameters_comparison.png", width = 1000, height = 600)
p <- ggplot(all_results, aes(x = time, y = C_arterial_thc, color = scenario)) +
  geom_line(size = 1.2) +
  labs(
    title = "Comparison of Different Dosing Scenarios",
    subtitle = "Arterial THC concentrations",
    x = "Time (hours)",
    y = "THC Concentration (mg/L)",
    color = "Scenario"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c(
    "High Dose (25mg THC)" = "#E74C3C",
    "Low Dose (5mg THC)" = "#3498DB",
    "Heavy Individual (100kg)" = "#2ECC71"
  ))
print(p)
dev.off()

cat("Plot saved to: custom_parameters_comparison.png\n")

# Example: Modifying partition coefficients
cat("\n--- Advanced: Modifying Partition Coefficients ---\n")
cat("Simulating effect of increased brain penetration...\n")

params_base <- get_default_params(BW = 70)
params_high_brain <- get_default_params(BW = 70)
params_high_brain$Kp_brain_thc <- 40  # Increase brain partition coefficient

results_base <- simulate_pbpk(params_base, times)
results_high <- simulate_pbpk(params_high_brain, times)

cat(sprintf("  Standard brain Kp: Max brain THC = %.2f mg/L\n", 
            max(results_base$C_brain_thc)))
cat(sprintf("  Increased brain Kp: Max brain THC = %.2f mg/L\n", 
            max(results_high$C_brain_thc)))
cat(sprintf("  Fold increase: %.2fx\n", 
            max(results_high$C_brain_thc) / max(results_base$C_brain_thc)))

cat("\n✓ Example complete!\n")
cat("\nTry modifying other parameters such as:\n")
cat("  - CL_int_thc/cbd (hepatic clearance)\n")
cat("  - Kp values for different tissues\n")
cat("  - Body weight (BW)\n")
cat("  - Dose amounts and inhalation duration\n")
