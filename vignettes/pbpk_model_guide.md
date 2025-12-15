# PBPK Model for THC and CBD Inhalation: User Guide

## Introduction

This vignette provides a comprehensive guide to using the PBPKR package for simulating the pharmacokinetics of delta-9-tetrahydrocannabinol (THC) and cannabidiol (CBD) following inhalation exposure.

## Model Overview

### Physiologically-Based Pharmacokinetic (PBPK) Modeling

PBPK models are mechanistic mathematical models that describe drug distribution and elimination in the body based on:
- Anatomical structure (tissue compartments)
- Physiological processes (blood flows, metabolism)
- Drug-specific properties (partition coefficients, clearance)

### Model Structure

The PBPKR model includes the following compartments for both THC and CBD:

1. **Lung** - Site of absorption via inhalation
2. **Arterial Blood** - Oxygenated blood from lungs
3. **Venous Blood** - Deoxygenated blood returning to lungs
4. **Fat Tissue** - Major storage compartment for lipophilic cannabinoids
5. **Muscle Tissue** - Large tissue compartment
6. **Liver** - Site of metabolic clearance
7. **Kidney** - Site of renal excretion
8. **Brain** - Site of pharmacological effects
9. **Other Tissues** - Lumped compartment for remaining tissues

### Mathematical Framework

The model uses ordinary differential equations (ODEs) to describe the rate of change of drug amount in each compartment:

```
dA/dt = Q × (C_in - C_out)
```

Where:
- `A` = Amount of drug in compartment (mg)
- `Q` = Blood flow rate (L/hr)
- `C_in` = Incoming concentration (mg/L)
- `C_out` = Outgoing concentration (mg/L)

For metabolizing organs (liver):
```
dA_liver/dt = Q_liver × (C_art - C_liver/Kp) - CL_int × C_liver/Kp
```

## Getting Started

### Installation

```r
# Install dependencies
install.packages(c("shiny", "shinydashboard", "deSolve", "ggplot2", "plotly", "DT"))

# Install PBPKR package (from source)
install.packages("path/to/PBPK_R", repos = NULL, type = "source")
```

### Basic Usage

```r
library(PBPKR)

# Get default parameters for 70 kg individual
params <- get_default_params(BW = 70)

# Run simulation
times <- seq(0, 24, by = 0.1)  # 24 hours, 0.1 hr intervals
results <- simulate_pbpk(params, times)

# View results
head(results)
```

### Using the Shiny App

The easiest way to explore the model is through the interactive Shiny application:

```r
library(PBPKR)
run_pbpk_app()
```

## Model Parameters

### Physiological Parameters

These are based on standard adult human physiology:

#### Tissue Volumes (as fractions of body weight)
- Fat: 21.4% of BW
- Muscle: 40% of BW
- Liver: 2.6% of BW
- Kidney: 0.4% of BW
- Brain: 2% of BW
- Lung: 0.76% of BW
- Arterial blood: 2.5% of BW
- Venous blood: 5.5% of BW

#### Blood Flow Rates (as fractions of cardiac output)
- Cardiac Output: 300 L/hr (5 L/min)
- Fat: 5% of CO
- Muscle: 17% of CO
- Liver: 25% of CO (hepatic artery + portal vein)
- Kidney: 19% of CO
- Brain: 12% of CO

### Drug-Specific Parameters

#### THC (Delta-9-Tetrahydrocannabinol)

**Partition Coefficients (Kp)**
- Fat: 400 (highly lipophilic)
- Brain: 25 (significant CNS penetration)
- Liver: 20
- Muscle: 10
- Kidney: 12
- Lung: 15
- Other: 8

**Clearance**
- Hepatic: 50 L/hr
- Renal: 0.5 L/hr

#### CBD (Cannabidiol)

**Partition Coefficients (Kp)**
- Fat: 300 (lipophilic but less than THC)
- Brain: 20 (good CNS penetration)
- Liver: 18
- Muscle: 8
- Kidney: 10
- Lung: 12
- Other: 7

**Clearance**
- Hepatic: 45 L/hr
- Renal: 0.4 L/hr

### Dosing Parameters

- `dose_thc`: THC dose in mg (default: 10)
- `dose_cbd`: CBD dose in mg (default: 5)
- `t_inh`: Inhalation duration in hours (default: 0.083, ~5 minutes)

## Example Use Cases

### Example 1: Basic Simulation

Simulate typical marijuana cigarette inhalation (10 mg THC, 5 mg CBD):

```r
library(PBPKR)
library(ggplot2)

# Default parameters
params <- get_default_params(BW = 70)

# Run simulation
times <- seq(0, 24, by = 0.1)
results <- simulate_pbpk(params, times)

# Plot arterial concentrations
ggplot(results, aes(x = time)) +
  geom_line(aes(y = C_arterial_thc, color = "THC")) +
  geom_line(aes(y = C_arterial_cbd, color = "CBD")) +
  labs(x = "Time (hours)", y = "Arterial Concentration (mg/L)") +
  theme_minimal()
```

### Example 2: Dose-Response Study

Compare different doses:

```r
doses_thc <- c(5, 10, 20, 40)
all_results <- list()

for (i in seq_along(doses_thc)) {
  params <- get_default_params(BW = 70)
  params$dose_thc <- doses_thc[i]
  params$dose_cbd <- doses_thc[i] * 0.5
  
  results <- simulate_pbpk(params, times)
  results$dose <- paste0(doses_thc[i], " mg")
  all_results[[i]] <- results
}

combined <- do.call(rbind, all_results)

# Plot comparison
ggplot(combined, aes(x = time, y = C_brain_thc, color = dose)) +
  geom_line(size = 1) +
  labs(title = "Brain THC Concentrations at Different Doses",
       x = "Time (hours)", y = "Brain Concentration (mg/L)") +
  theme_minimal()
```

### Example 3: Population Variability

Simulate different body weights:

```r
body_weights <- seq(50, 100, by = 10)
peak_concentrations <- numeric(length(body_weights))

for (i in seq_along(body_weights)) {
  params <- get_default_params(BW = body_weights[i])
  results <- simulate_pbpk(params, times)
  peak_concentrations[i] <- max(results$C_arterial_thc)
}

plot(body_weights, peak_concentrations, type = "b",
     xlab = "Body Weight (kg)", 
     ylab = "Peak Arterial THC (mg/L)",
     main = "Effect of Body Weight on Peak Concentrations")
```

### Example 4: Sensitivity Analysis

Examine effect of hepatic clearance:

```r
clearances <- seq(20, 80, by = 10)
auc_values <- numeric(length(clearances))

for (i in seq_along(clearances)) {
  params <- get_default_params(BW = 70)
  params$CL_int_thc <- clearances[i]
  
  results <- simulate_pbpk(params, times)
  # Calculate AUC using trapezoidal rule
  auc_values[i] <- sum(diff(results$time) * 
                       (results$C_arterial_thc[-1] + results$C_arterial_thc[-nrow(results)])/2)
}

plot(clearances, auc_values, type = "b",
     xlab = "Hepatic Clearance (L/hr)",
     ylab = "AUC (mg·hr/L)",
     main = "Effect of Hepatic Clearance on Exposure")
```

## Interpretation of Results

### Key Outputs

1. **Arterial Concentrations** - Represent systemic exposure
2. **Brain Concentrations** - Correlate with pharmacological effects
3. **Fat Concentrations** - Indicate long-term storage
4. **Liver Concentrations** - Relevant for metabolism and toxicity

### Typical Profiles

After inhalation:
- **Rapid rise** in arterial concentrations (peak at ~0.5-1 hour)
- **Brain concentrations** peak slightly later (1-2 hours)
- **Fat accumulation** continues over several hours
- **Biphasic elimination** due to redistribution from fat

### Pharmacokinetic Parameters

Calculate common PK parameters from simulation results:

```r
# Peak concentration (Cmax)
Cmax <- max(results$C_arterial_thc)
Tmax <- results$time[which.max(results$C_arterial_thc)]

# Area under the curve (AUC) using trapezoidal rule
AUC <- sum(diff(results$time) * 
           (results$C_arterial_thc[-1] + results$C_arterial_thc[-nrow(results)])/2)

# Apparent elimination half-life
# Find time when concentration drops to half of Cmax
half_conc <- Cmax / 2
idx_half <- which(results$C_arterial_thc < half_conc & results$time > Tmax)[1]
t_half <- results$time[idx_half] - Tmax

cat(sprintf("Cmax: %.3f mg/L at %.2f hours\n", Cmax, Tmax))
cat(sprintf("AUC: %.2f mg·hr/L\n", AUC))
cat(sprintf("Apparent t½: %.2f hours\n", t_half))
```

## Model Limitations and Assumptions

### Assumptions
1. Well-stirred compartments (instant distribution within tissues)
2. Linear pharmacokinetics (no saturation)
3. First-order absorption from lung
4. Constant blood flows and partition coefficients
5. No active metabolites modeled
6. No protein binding explicitly modeled

### Limitations
1. Parameter values are literature-based estimates
2. Significant inter-individual variability not captured
3. Chronic use and tolerance not modeled
4. No interaction between THC and CBD
5. Simplified lung absorption model
6. No consideration of smoking vs vaping differences

## Best Practices

### Simulation Setup
- Use adequate time resolution (0.1 hr or finer for inhalation)
- Simulate long enough to capture elimination phase (24-48 hours)
- Check mass balance (total drug = dose - amount eliminated)

### Parameter Selection
- Use physiologically plausible values
- Scale parameters appropriately with body weight
- Document any deviations from defaults

### Interpretation
- Compare results to clinical data when available
- Consider biological plausibility
- Perform sensitivity analyses for uncertain parameters
- Report limitations and assumptions

## Advanced Topics

### Adding New Compartments

To extend the model with additional compartments, modify `pbpk_model.R`:

1. Add new state variables
2. Define tissue volume and blood flow
3. Add differential equations
4. Update parameter lists

### Alternative Dosing Routes

The current model is designed for inhalation. To add other routes:
- **Oral**: Add GI absorption compartment
- **IV**: Direct input to arterial blood
- **Dermal**: Add skin compartment with absorption rate

### Metabolite Modeling

To track metabolites:
1. Add metabolite compartments
2. Link formation rate to parent clearance
3. Define metabolite-specific parameters

## References

### PBPK Modeling
- Jones, H. M., & Rowland-Yeo, K. (2013). Basic concepts in physiologically based pharmacokinetic modeling in drug discovery and development. CPT: pharmacometrics & systems pharmacology, 2(8), 1-12.

### Cannabinoid Pharmacokinetics
- Huestis, M. A. (2007). Human cannabinoid pharmacokinetics. Chemistry & biodiversity, 4(8), 1770-1804.
- Grotenhermen, F. (2003). Pharmacokinetics and pharmacodynamics of cannabinoids. Clinical pharmacokinetics, 42(4), 327-360.

### Physiological Parameters
- Brown, R. P., et al. (1997). Physiological parameter values for physiologically based pharmacokinetic models. Toxicology and industrial health, 13(4), 407-484.

## Support

For questions, issues, or contributions:
- GitHub: https://github.com/eisascience/PBPK_R
- Issues: https://github.com/eisascience/PBPK_R/issues

## Appendix: Parameter Tables

### Default Tissue Volumes (70 kg individual)

| Tissue | Volume (L) | % BW |
|--------|-----------|------|
| Fat | 14.98 | 21.4 |
| Muscle | 28.00 | 40.0 |
| Liver | 1.82 | 2.6 |
| Kidney | 0.28 | 0.4 |
| Brain | 1.40 | 2.0 |
| Lung | 0.53 | 0.76 |
| Arterial | 1.75 | 2.5 |
| Venous | 3.85 | 5.5 |

### Default Blood Flows (CO = 300 L/hr)

| Tissue | Flow (L/hr) | % CO |
|--------|------------|------|
| Fat | 15 | 5 |
| Muscle | 51 | 17 |
| Liver | 75 | 25 |
| Kidney | 57 | 19 |
| Brain | 36 | 12 |
| Other | 66 | 22 |
| Lung | 300 | 100 |

### THC Partition Coefficients

| Tissue | Kp | Rationale |
|--------|-----|-----------|
| Fat | 400 | Highly lipophilic |
| Brain | 25 | High CNS penetration |
| Liver | 20 | Metabolizing organ |
| Muscle | 10 | Moderate distribution |
| Kidney | 12 | Moderate distribution |
| Lung | 15 | Site of absorption |
| Other | 8 | Average of other tissues |

### CBD Partition Coefficients

| Tissue | Kp | Rationale |
|--------|-----|-----------|
| Fat | 300 | Lipophilic (less than THC) |
| Brain | 20 | Good CNS penetration |
| Liver | 18 | Metabolizing organ |
| Muscle | 8 | Moderate distribution |
| Kidney | 10 | Moderate distribution |
| Lung | 12 | Site of absorption |
| Other | 7 | Average of other tissues |
