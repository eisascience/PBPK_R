#' Simulate PBPK Model for THC and CBD
#'
#' This function runs the PBPK model simulation with specified parameters
#'
#' @param params List of model parameters including physiological parameters,
#'   drug-specific parameters, and dosing information
#' @param times Vector of time points for simulation (hours)
#'
#' @return Data frame with simulation results
#' @import deSolve
#' @export
simulate_pbpk <- function(params, times = seq(0, 24, by = 0.1)) {
  
  # Initial conditions (all compartments start at 0)
  initial_state <- c(
    A_lung_thc = 0, A_art_thc = 0, A_ven_thc = 0,
    A_fat_thc = 0, A_muscle_thc = 0, A_liver_thc = 0,
    A_kidney_thc = 0, A_brain_thc = 0, A_other_thc = 0,
    A_lung_cbd = 0, A_art_cbd = 0, A_ven_cbd = 0,
    A_fat_cbd = 0, A_muscle_cbd = 0, A_liver_cbd = 0,
    A_kidney_cbd = 0, A_brain_cbd = 0, A_other_cbd = 0
  )
  
  # Run ODE solver
  out <- deSolve::ode(
    y = initial_state,
    times = times,
    func = pbpk_model,
    parms = params,
    method = "lsoda"
  )
  
  # Convert to data frame
  out_df <- as.data.frame(out)
  
  # Calculate concentrations for plotting
  out_df$C_arterial_thc <- out_df$A_art_thc / params$V_art
  out_df$C_venous_thc <- out_df$A_ven_thc / params$V_ven
  out_df$C_brain_thc <- out_df$A_brain_thc / params$V_brain
  out_df$C_fat_thc <- out_df$A_fat_thc / params$V_fat
  out_df$C_muscle_thc <- out_df$A_muscle_thc / params$V_muscle
  out_df$C_liver_thc <- out_df$A_liver_thc / params$V_liver
  out_df$C_kidney_thc <- out_df$A_kidney_thc / params$V_kidney
  out_df$C_lung_thc <- out_df$A_lung_thc / params$V_lung
  out_df$C_other_thc <- out_df$A_other_thc / params$V_other
  
  out_df$C_arterial_cbd <- out_df$A_art_cbd / params$V_art
  out_df$C_venous_cbd <- out_df$A_ven_cbd / params$V_ven
  out_df$C_brain_cbd <- out_df$A_brain_cbd / params$V_brain
  out_df$C_fat_cbd <- out_df$A_fat_cbd / params$V_fat
  out_df$C_muscle_cbd <- out_df$A_muscle_cbd / params$V_muscle
  out_df$C_liver_cbd <- out_df$A_liver_cbd / params$V_liver
  out_df$C_kidney_cbd <- out_df$A_kidney_cbd / params$V_kidney
  out_df$C_lung_cbd <- out_df$A_lung_cbd / params$V_lung
  out_df$C_other_cbd <- out_df$A_other_cbd / params$V_other
  
  return(out_df)
}


#' Get Default PBPK Parameters
#'
#' Returns a list of default physiological and drug-specific parameters
#' for a standard 70 kg adult human
#'
#' @param BW Body weight in kg (default = 70)
#'
#' @return List of parameters
#' @export
get_default_params <- function(BW = 70) {
  
  # Physiological parameters (scaled to body weight)
  # Tissue volumes as fractions of body weight
  V_fat <- 0.214 * BW      # L (21.4% of BW)
  V_muscle <- 0.40 * BW    # L (40% of BW)
  V_liver <- 0.026 * BW    # L (2.6% of BW)
  V_kidney <- 0.004 * BW   # L (0.4% of BW)
  V_brain <- 0.02 * BW     # L (2% of BW)
  V_lung <- 0.0076 * BW    # L (0.76% of BW)
  V_art <- 0.025 * BW      # L (2.5% of BW - arterial blood)
  V_ven <- 0.055 * BW      # L (5.5% of BW - venous blood)
  V_other <- BW - (V_fat + V_muscle + V_liver + V_kidney + V_brain + 
                   V_lung + V_art + V_ven)
  
  # Validate that remaining volume is positive
  if (V_other <= 0) {
    stop("Sum of tissue volumes exceeds body weight. Check volume parameters.")
  }
  
  # Blood flow rates (L/hr) - Cardiac output = 5 L/min = 300 L/hr
  CO <- 300  # Cardiac output (L/hr)
  Q_fat <- 0.05 * CO       # 5% of CO
  Q_muscle <- 0.17 * CO    # 17% of CO
  Q_liver <- 0.25 * CO     # 25% of CO (includes hepatic artery and portal vein)
  Q_kidney <- 0.19 * CO    # 19% of CO
  Q_brain <- 0.12 * CO     # 12% of CO
  Q_lung <- CO             # All blood goes through lungs
  Q_other <- CO - (Q_fat + Q_muscle + Q_liver + Q_kidney + Q_brain)
  
  # THC-specific parameters
  # Tissue:plasma partition coefficients (dimensionless)
  Kp_fat_thc <- 400        # Highly lipophilic - accumulates in fat
  Kp_muscle_thc <- 10      # Moderate distribution to muscle
  Kp_liver_thc <- 20       # High liver distribution
  Kp_kidney_thc <- 12      # Moderate kidney distribution
  Kp_brain_thc <- 25       # High brain distribution (lipophilic)
  Kp_lung_thc <- 15        # Moderate lung distribution
  Kp_other_thc <- 8        # Other tissues
  
  CL_int_thc <- 50         # Intrinsic hepatic clearance (L/hr)
  CL_renal_thc <- 0.5      # Renal clearance (L/hr)
  
  # CBD-specific parameters
  Kp_fat_cbd <- 300        # Lipophilic but less than THC
  Kp_muscle_cbd <- 8       # Moderate distribution
  Kp_liver_cbd <- 18       # High liver distribution
  Kp_kidney_cbd <- 10      # Moderate kidney distribution
  Kp_brain_cbd <- 20       # High brain distribution
  Kp_lung_cbd <- 12        # Moderate lung distribution
  Kp_other_cbd <- 7        # Other tissues
  
  CL_int_cbd <- 45         # Intrinsic hepatic clearance (L/hr)
  CL_renal_cbd <- 0.4      # Renal clearance (L/hr)
  
  # Dosing parameters (to be set by user)
  dose_thc <- 10           # THC dose (mg)
  dose_cbd <- 5            # CBD dose (mg)
  t_inh <- 0.083           # Inhalation duration (hours) - ~5 minutes
  
  # Return all parameters as a list
  params <- list(
    # Volumes
    V_fat = V_fat, V_muscle = V_muscle, V_liver = V_liver,
    V_kidney = V_kidney, V_brain = V_brain, V_lung = V_lung,
    V_art = V_art, V_ven = V_ven, V_other = V_other,
    
    # Blood flows
    Q_fat = Q_fat, Q_muscle = Q_muscle, Q_liver = Q_liver,
    Q_kidney = Q_kidney, Q_brain = Q_brain, Q_lung = Q_lung,
    Q_other = Q_other,
    
    # THC partition coefficients
    Kp_fat_thc = Kp_fat_thc, Kp_muscle_thc = Kp_muscle_thc,
    Kp_liver_thc = Kp_liver_thc, Kp_kidney_thc = Kp_kidney_thc,
    Kp_brain_thc = Kp_brain_thc, Kp_lung_thc = Kp_lung_thc,
    Kp_other_thc = Kp_other_thc,
    
    # CBD partition coefficients
    Kp_fat_cbd = Kp_fat_cbd, Kp_muscle_cbd = Kp_muscle_cbd,
    Kp_liver_cbd = Kp_liver_cbd, Kp_kidney_cbd = Kp_kidney_cbd,
    Kp_brain_cbd = Kp_brain_cbd, Kp_lung_cbd = Kp_lung_cbd,
    Kp_other_cbd = Kp_other_cbd,
    
    # Clearances
    CL_int_thc = CL_int_thc, CL_renal_thc = CL_renal_thc,
    CL_int_cbd = CL_int_cbd, CL_renal_cbd = CL_renal_cbd,
    
    # Dosing
    dose_thc = dose_thc, dose_cbd = dose_cbd, t_inh = t_inh,
    
    # Body weight
    BW = BW
  )
  
  return(params)
}
