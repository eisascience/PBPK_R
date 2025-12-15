# Installation and Testing Guide

## System Requirements

- **Operating System**: Linux, macOS, or Windows
- **R Version**: 3.5.0 or higher
- **RAM**: At least 2 GB (4 GB recommended)
- **Disk Space**: ~200 MB for package and dependencies

## Installation Steps

### 1. Install R

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install r-base r-base-dev
```

#### macOS
```bash
brew install r
```

#### Windows
Download and install from [CRAN](https://cran.r-project.org/bin/windows/base/)

### 2. Install R Dependencies

You can install dependencies either from system packages (Ubuntu/Debian) or from CRAN.

#### Option A: System Packages (Ubuntu/Debian - Recommended)
```bash
sudo apt-get install r-cran-shiny \
                     r-cran-shinydashboard \
                     r-cran-desolve \
                     r-cran-ggplot2 \
                     r-cran-plotly \
                     r-cran-dt
```

#### Option B: From CRAN (All Platforms)
```r
# In R console
install.packages(c(
  "shiny",
  "shinydashboard",
  "deSolve",
  "ggplot2",
  "plotly",
  "DT"
))
```

### 3. Install PBPKR Package

#### From Local Source
```bash
cd /path/to/PBPK_R
R CMD build .
R CMD INSTALL PBPKR_0.1.0.tar.gz
```

Or in R:
```r
install.packages("/path/to/PBPK_R", repos = NULL, type = "source")
```

#### From GitHub (if available)
```r
# Using devtools
install.packages("devtools")
devtools::install_github("eisascience/PBPK_R")

# Or using remotes
install.packages("remotes")
remotes::install_github("eisascience/PBPK_R")
```

## Verification

### Test Package Installation

```r
# Load the package
library(PBPKR)

# Check functions are available
exists("simulate_pbpk")
exists("get_default_params")
exists("run_pbpk_app")
```

### Run Basic Test

```r
# Get default parameters
params <- get_default_params(BW = 70)

# Run a short simulation
times <- seq(0, 10, by = 0.1)
results <- simulate_pbpk(params, times)

# Check results
print(head(results))
print(paste("Simulation completed:", nrow(results), "time points"))
```

Expected output should show a data frame with concentration values.

### Test Shiny App

```r
# Launch the Shiny app (will open in browser)
library(PBPKR)
run_pbpk_app()
```

The app should open in your default web browser. Try:
1. Adjusting dose parameters
2. Clicking "Run Simulation"
3. Viewing the plots
4. Downloading data

## Running Without Installation

If you don't want to install the package, you can run the code directly:

```r
# Set working directory to package root
setwd("/path/to/PBPK_R")

# Source the functions
source("R/pbpk_model.R")
source("R/simulate_pbpk.R")

# Run simulation
params <- get_default_params()
results <- simulate_pbpk(params)

# Launch Shiny app
shiny::runApp("inst/shiny-app")
```

## Testing

### Run Example Scripts

```bash
cd /path/to/PBPK_R/examples
Rscript basic_simulation.R
```

This will:
- Run a basic simulation
- Generate a plot (basic_simulation_arterial.png)
- Save results to CSV

### Run Custom Parameters Example

```bash
cd /path/to/PBPK_R/examples
Rscript custom_parameters.R
```

This demonstrates different dosing scenarios and parameter modifications.

## Troubleshooting

### Issue: "package 'deSolve' is not available"

**Solution**: Install deSolve manually
```r
install.packages("deSolve")
```

### Issue: "could not find function 'pbpk_model'"

**Solution**: Make sure you've loaded the package or sourced the files
```r
library(PBPKR)
# OR
source("R/pbpk_model.R")
```

### Issue: Shiny app won't start

**Solution**: Check that Shiny is installed and try running directly
```r
install.packages("shiny")
shiny::runApp("inst/shiny-app")
```

### Issue: "Sum of tissue volumes exceeds body weight"

**Solution**: This validation error means the body weight is too small for the defined tissue volumes. Use a body weight >= 40 kg.

### Issue: Simulation is very slow

**Solution**: 
- Reduce simulation time: `times <- seq(0, 24, by = 0.5)` instead of `by = 0.1`
- Use a coarser time step for exploratory analysis
- For production runs, finer time steps (0.1 hr) provide smoother curves

### Issue: Plot shows warnings about 'size' aesthetic

**Solution**: This is a deprecation warning from ggplot2. The plots still work correctly. To fix, replace `size = 1` with `linewidth = 1` in plot code.

## Performance Notes

- **Simulation time**: A 24-hour simulation with 0.1 hr time step takes ~1-2 seconds
- **Memory usage**: Typical simulation uses ~50 MB RAM
- **Shiny app**: Initial load takes 2-3 seconds; simulations are near-instantaneous

## Uninstallation

To remove the package:
```r
remove.packages("PBPKR")
```

## Getting Help

- **Documentation**: See `vignettes/pbpk_model_guide.md`
- **Quick Start**: See `QUICKSTART.md`
- **Examples**: See files in `examples/` directory
- **Issues**: https://github.com/eisascience/PBPK_R/issues

## System-Specific Notes

### Windows
- May need to install Rtools for package building
- Paths use backslashes: `C:\path\to\PBPK_R`
- Use `setwd("C:/path/to/PBPK_R")` (forward slashes in R)

### macOS
- May need Xcode command line tools: `xcode-select --install`
- Some CRAN packages may require additional system libraries

### Linux
- System packages (via apt-get) are generally more reliable than CRAN
- May need libcurl4-openssl-dev, libssl-dev for some dependencies

## Validation

To validate that everything is working correctly:

```r
# Source validation script
source("R/pbpk_model.R")
source("R/simulate_pbpk.R")

# Test 1: Basic simulation
params <- get_default_params(BW = 70)
results <- simulate_pbpk(params, seq(0, 24, by = 0.1))
stopifnot(nrow(results) == 241)
stopifnot(max(results$C_arterial_thc) > 0)

# Test 2: Different body weights
for (bw in c(50, 70, 100)) {
  params <- get_default_params(BW = bw)
  results <- simulate_pbpk(params)
  stopifnot(nrow(results) > 0)
}

# Test 3: Edge cases
params <- get_default_params()
params$dose_thc <- 0  # No THC
results <- simulate_pbpk(params)
stopifnot(max(results$C_arterial_thc) == 0)

cat("✓ All validation tests passed!\n")
```

## Next Steps

After successful installation:

1. **Explore the Shiny app**: `run_pbpk_app()`
2. **Run examples**: Try `examples/basic_simulation.R`
3. **Read the vignette**: `vignettes/pbpk_model_guide.md`
4. **Customize for your needs**: Modify parameters for your specific use case

## Support

For questions or issues:
- Open an issue on GitHub
- Check existing documentation
- Review example scripts for common patterns
