# PBPK_R

Physiologically-Based Pharmacokinetic (PBPK) Model for THC and CBD Inhalation

## Overview

This R package provides an interactive Shiny application for simulating the pharmacokinetics of delta-9-tetrahydrocannabinol (THC) and cannabidiol (CBD) following inhalation exposure. The PBPK model includes multiple tissue compartments and accounts for tissue-specific distribution, hepatic metabolism, and renal clearance.

## Features

- **Multi-compartment PBPK model** with 9 tissue compartments per compound
- **Interactive Shiny interface** for parameter adjustment and visualization
- **Physiologically-based parameters** scaled to body weight
- **Simultaneous simulation** of THC and CBD pharmacokinetics
- **Real-time visualization** of concentration-time profiles
- **Exportable results** in CSV format

## Model Compartments

The model includes the following tissue compartments:
- Lung (site of absorption via inhalation)
- Arterial and venous blood
- Fat tissue (major storage site for lipophilic cannabinoids)
- Muscle tissue
- Liver (site of metabolism)
- Kidney (site of excretion)
- Brain (site of pharmacological effects)
- Other tissues (lumped compartment)

## Installation

### From source

```r
# Install dependencies first
install.packages(c("shiny", "shinydashboard", "deSolve", "ggplot2", "plotly", "DT"))

# Install from local source
install.packages("path/to/PBPK_R", repos = NULL, type = "source")
```

### From GitHub (if available)

```r
# Using devtools
devtools::install_github("eisascience/PBPK_R")

# Or using remotes
remotes::install_github("eisascience/PBPK_R")
```

## Usage

### Running the Shiny App

```r
library(PBPKR)

# Launch the interactive Shiny application
run_pbpk_app()
```

### Using the Model Functions Directly

```r
library(PBPKR)

# Get default parameters for a 70 kg individual
params <- get_default_params(BW = 70)

# Modify dosing
params$dose_thc <- 15  # mg
params$dose_cbd <- 10  # mg
params$t_inh <- 0.083  # hours (~5 minutes)

# Run simulation
times <- seq(0, 24, by = 0.1)  # 24 hours
results <- simulate_pbpk(params, times)

# View results
head(results)

# Plot results
library(ggplot2)
ggplot(results, aes(x = time)) +
  geom_line(aes(y = C_arterial_thc, color = "THC")) +
  geom_line(aes(y = C_arterial_cbd, color = "CBD")) +
  labs(x = "Time (hours)", y = "Arterial Concentration (mg/L)") +
  theme_minimal()
```

## Model Parameters

### Physiological Parameters
- Tissue volumes (scaled to body weight)
- Blood flow rates (cardiac output distribution)
- Default values based on a 70 kg adult

### Drug-Specific Parameters

#### THC
- Highly lipophilic (fat Kp = 400)
- Significant brain distribution (brain Kp = 25)
- Hepatic clearance: 50 L/hr
- Renal clearance: 0.5 L/hr

#### CBD
- Moderately lipophilic (fat Kp = 300)
- Good brain distribution (brain Kp = 20)
- Hepatic clearance: 45 L/hr
- Renal clearance: 0.4 L/hr

### Customization

All parameters can be adjusted through the Shiny interface or programmatically:

```r
params <- get_default_params()

# Adjust partition coefficients
params$Kp_brain_thc <- 30  # Increase brain distribution

# Adjust clearance
params$CL_int_thc <- 60  # Increase hepatic clearance

# Run simulation with custom parameters
results <- simulate_pbpk(params)
```

## Shiny App Features

The interactive Shiny application provides:

1. **Dosing Parameters Tab**
   - THC and CBD dose inputs
   - Inhalation duration
   - Body weight
   - Simulation time

2. **Clearance Parameters**
   - Hepatic and renal clearance for both compounds

3. **Partition Coefficients Tab**
   - Tissue-specific distribution parameters
   - Reset to default values option

4. **Visualization**
   - Interactive plotly charts for arterial, brain, fat, and liver concentrations
   - Side-by-side comparison of THC and CBD

5. **Data Export**
   - Download simulation results as CSV
   - Interactive data table

## Example Use Case

Simulate inhalation of marijuana containing 10 mg THC and 5 mg CBD:

```r
library(PBPKR)

# Launch app
run_pbpk_app()

# In the app:
# 1. Set THC dose = 10 mg
# 2. Set CBD dose = 5 mg
# 3. Set inhalation duration = 5 minutes
# 4. Set body weight = 70 kg
# 5. Click "Run Simulation"
# 6. View concentration-time profiles
# 7. Download results if needed
```

## Model Assumptions

- First-order absorption from lung
- Linear pharmacokinetics
- Well-stirred compartment model
- Instantaneous distribution within compartments
- Constant blood flow rates
- Constant partition coefficients

## References

This model is based on published PBPK modeling principles and cannabinoid pharmacokinetics literature. Default parameters are derived from physiological values for adult humans and published cannabinoid disposition data.

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contact

For questions or issues, please open an issue on GitHub.
