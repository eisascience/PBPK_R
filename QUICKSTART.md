# PBPKR Quick Start Guide

## Installation

### System Requirements
- R version 3.5.0 or higher
- Required R packages: shiny, shinydashboard, deSolve, ggplot2, plotly, DT

### Install Dependencies

On Ubuntu/Debian:
```bash
sudo apt-get install r-base r-base-dev
sudo apt-get install r-cran-shiny r-cran-shinydashboard r-cran-desolve \
                     r-cran-ggplot2 r-cran-plotly r-cran-dt
```

Or in R:
```r
install.packages(c("shiny", "shinydashboard", "deSolve", "ggplot2", "plotly", "DT"))
```

### Install PBPKR Package

From source:
```bash
cd /path/to/PBPK_R
R CMD INSTALL .
```

Or in R:
```r
install.packages("/path/to/PBPK_R", repos = NULL, type = "source")
```

## Quick Start: 3 Ways to Use PBPKR

### 1. Interactive Shiny App (Recommended for Beginners)

Launch the interactive application:

```r
library(PBPKR)
run_pbpk_app()
```

Or from command line:
```bash
cd inst/shiny-app
R -e "shiny::runApp()"
```

The app provides:
- Point-and-click parameter adjustment
- Real-time simulation
- Interactive plots
- Data export

### 2. Command Line Simulation

For scripted analysis:

```r
library(PBPKR)

# Get default parameters for 70 kg individual
params <- get_default_params(BW = 70)

# Customize dosing
params$dose_thc <- 15  # mg
params$dose_cbd <- 10  # mg

# Run simulation
times <- seq(0, 24, by = 0.1)
results <- simulate_pbpk(params, times)

# View peak concentrations
max(results$C_arterial_thc)  # Peak arterial THC
max(results$C_brain_thc)     # Peak brain THC
```

### 3. Source Files Directly

If package not installed:

```r
# Source model functions
source("R/pbpk_model.R")
source("R/simulate_pbpk.R")

# Use as above
params <- get_default_params(BW = 70)
results <- simulate_pbpk(params, times)
```

## Common Use Cases

### Simulate Different Doses

```r
library(PBPKR)

# Low dose
params_low <- get_default_params()
params_low$dose_thc <- 5
results_low <- simulate_pbpk(params_low)

# High dose
params_high <- get_default_params()
params_high$dose_thc <- 25
results_high <- simulate_pbpk(params_high)
```

### Adjust for Body Weight

```r
# Light individual (55 kg)
params_light <- get_default_params(BW = 55)
results_light <- simulate_pbpk(params_light)

# Heavy individual (100 kg)
params_heavy <- get_default_params(BW = 100)
results_heavy <- simulate_pbpk(params_heavy)
```

### Modify Clearance Parameters

```r
# Slow metabolizer
params <- get_default_params()
params$CL_int_thc <- 25  # Reduced hepatic clearance
results <- simulate_pbpk(params)
```

### Plot Results

```r
library(ggplot2)

# Arterial concentrations
ggplot(results, aes(x = time)) +
  geom_line(aes(y = C_arterial_thc, color = "THC")) +
  geom_line(aes(y = C_arterial_cbd, color = "CBD")) +
  labs(x = "Time (hours)", y = "Concentration (mg/L)") +
  theme_minimal()

# Brain concentrations
ggplot(results, aes(x = time)) +
  geom_line(aes(y = C_brain_thc, color = "THC")) +
  geom_line(aes(y = C_brain_cbd, color = "CBD")) +
  labs(x = "Time (hours)", y = "Brain Concentration (mg/L)") +
  theme_minimal()
```

## Example Scripts

See the `examples/` directory for complete examples:

- `basic_simulation.R` - Simple simulation with default parameters
- `custom_parameters.R` - Demonstrates parameter customization
- `run_shiny_app.R` - Launches the Shiny application

To run an example:
```bash
cd examples
Rscript basic_simulation.R
```

## Key Parameters

### Dosing Parameters
- `dose_thc` - THC dose in mg (default: 10)
- `dose_cbd` - CBD dose in mg (default: 5)
- `t_inh` - Inhalation duration in hours (default: 0.083 = 5 minutes)
- `BW` - Body weight in kg (default: 70)

### Clearance Parameters
- `CL_int_thc` - THC hepatic clearance in L/hr (default: 50)
- `CL_renal_thc` - THC renal clearance in L/hr (default: 0.5)
- `CL_int_cbd` - CBD hepatic clearance in L/hr (default: 45)
- `CL_renal_cbd` - CBD renal clearance in L/hr (default: 0.4)

### Partition Coefficients
- `Kp_fat_thc` - THC fat partition coefficient (default: 400)
- `Kp_brain_thc` - THC brain partition coefficient (default: 25)
- Similar parameters exist for CBD and all other tissues

## Output Variables

Key concentration variables in simulation results:

- `C_arterial_thc/cbd` - Arterial blood concentration
- `C_venous_thc/cbd` - Venous blood concentration
- `C_brain_thc/cbd` - Brain tissue concentration
- `C_fat_thc/cbd` - Fat tissue concentration
- `C_muscle_thc/cbd` - Muscle tissue concentration
- `C_liver_thc/cbd` - Liver tissue concentration

## Troubleshooting

### Package Not Loading
```r
# Check if deSolve is installed
if (!requireNamespace("deSolve")) {
  install.packages("deSolve")
}
```

### Shiny App Not Opening
```r
# Check shiny is installed
if (!requireNamespace("shiny")) {
  install.packages("shiny")
}

# Try running directly
shiny::runApp("inst/shiny-app")
```

### Simulation Errors
- Ensure all parameters are positive
- Check that body weight is reasonable (40-150 kg)
- Verify time vector is properly defined: `seq(0, 24, by = 0.1)`

## Getting Help

- Read the full guide: `vignettes/pbpk_model_guide.md`
- Check examples: `examples/`
- GitHub issues: https://github.com/eisascience/PBPK_R/issues
- Documentation: `?simulate_pbpk`, `?get_default_params`, `?run_pbpk_app`

## Next Steps

1. **Explore the Shiny app** to understand how parameters affect results
2. **Run example scripts** to see different use cases
3. **Read the full vignette** for detailed model description
4. **Customize parameters** for your specific research question
5. **Validate results** against published pharmacokinetic data

## Citation

If you use this package in your research, please cite:

```
PBPKR: Physiologically-Based Pharmacokinetic Model for THC and CBD Inhalation
Version 0.1.0
https://github.com/eisascience/PBPK_R
```

## License

MIT License - see LICENSE file for details
