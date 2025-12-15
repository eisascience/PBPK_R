#' PBPK Model for THC and CBD via Inhalation
#'
#' This function defines the differential equations for a physiologically-based
#' pharmacokinetic (PBPK) model for THC and CBD following inhalation.
#'
#' @param t Time (hours)
#' @param state Vector of state variables (drug amounts in different compartments)
#' @param parameters List of model parameters
#'
#' @return List containing the rate of change of state variables
#' @export
pbpk_model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    
    # State variables for THC
    # Amount in each compartment (mg)
    A_lung_thc <- state[1]
    A_art_thc <- state[2]
    A_ven_thc <- state[3]
    A_fat_thc <- state[4]
    A_muscle_thc <- state[5]
    A_liver_thc <- state[6]
    A_kidney_thc <- state[7]
    A_brain_thc <- state[8]
    A_other_thc <- state[9]
    
    # State variables for CBD
    A_lung_cbd <- state[10]
    A_art_cbd <- state[11]
    A_ven_cbd <- state[12]
    A_fat_cbd <- state[13]
    A_muscle_cbd <- state[14]
    A_liver_cbd <- state[15]
    A_kidney_cbd <- state[16]
    A_brain_cbd <- state[17]
    A_other_cbd <- state[18]
    
    # Concentrations (mg/L)
    C_art_thc <- A_art_thc / V_art
    C_ven_thc <- A_ven_thc / V_ven
    C_lung_thc <- A_lung_thc / V_lung
    C_fat_thc <- A_fat_thc / V_fat
    C_muscle_thc <- A_muscle_thc / V_muscle
    C_liver_thc <- A_liver_thc / V_liver
    C_kidney_thc <- A_kidney_thc / V_kidney
    C_brain_thc <- A_brain_thc / V_brain
    C_other_thc <- A_other_thc / V_other
    
    C_art_cbd <- A_art_cbd / V_art
    C_ven_cbd <- A_ven_cbd / V_ven
    C_lung_cbd <- A_lung_cbd / V_lung
    C_fat_cbd <- A_fat_cbd / V_fat
    C_muscle_cbd <- A_muscle_cbd / V_muscle
    C_liver_cbd <- A_liver_cbd / V_liver
    C_kidney_cbd <- A_kidney_cbd / V_kidney
    C_brain_cbd <- A_brain_cbd / V_brain
    C_other_cbd <- A_other_cbd / V_other
    
    # Inhalation input (first-order absorption from lung)
    # Zero-order input during inhalation period
    if (t <= t_inh) {
      R_inh_thc <- dose_thc / t_inh  # mg/hr
      R_inh_cbd <- dose_cbd / t_inh  # mg/hr
    } else {
      R_inh_thc <- 0
      R_inh_cbd <- 0
    }
    
    # Differential equations for THC
    # Lung compartment
    dA_lung_thc <- R_inh_thc - Q_lung * (C_lung_thc / Kp_lung_thc - C_ven_thc)
    
    # Arterial blood
    dA_art_thc <- Q_lung * (C_lung_thc / Kp_lung_thc - C_ven_thc)
    
    # Fat tissue
    dA_fat_thc <- Q_fat * (C_art_thc - C_fat_thc / Kp_fat_thc)
    
    # Muscle tissue
    dA_muscle_thc <- Q_muscle * (C_art_thc - C_muscle_thc / Kp_muscle_thc)
    
    # Liver (with metabolism)
    dA_liver_thc <- Q_liver * (C_art_thc - C_liver_thc / Kp_liver_thc) - 
                     CL_int_thc * C_liver_thc / Kp_liver_thc
    
    # Kidney (with renal clearance)
    dA_kidney_thc <- Q_kidney * (C_art_thc - C_kidney_thc / Kp_kidney_thc) - 
                      CL_renal_thc * C_kidney_thc / Kp_kidney_thc
    
    # Brain
    dA_brain_thc <- Q_brain * (C_art_thc - C_brain_thc / Kp_brain_thc)
    
    # Other tissues
    dA_other_thc <- Q_other * (C_art_thc - C_other_thc / Kp_other_thc)
    
    # Venous blood (all tissues drain here)
    dA_ven_thc <- Q_fat * C_fat_thc / Kp_fat_thc +
                   Q_muscle * C_muscle_thc / Kp_muscle_thc +
                   Q_liver * C_liver_thc / Kp_liver_thc +
                   Q_kidney * C_kidney_thc / Kp_kidney_thc +
                   Q_brain * C_brain_thc / Kp_brain_thc +
                   Q_other * C_other_thc / Kp_other_thc -
                   Q_lung * C_ven_thc
    
    # Differential equations for CBD (same structure as THC)
    dA_lung_cbd <- R_inh_cbd - Q_lung * (C_lung_cbd / Kp_lung_cbd - C_ven_cbd)
    
    dA_art_cbd <- Q_lung * (C_lung_cbd / Kp_lung_cbd - C_ven_cbd)
    
    dA_fat_cbd <- Q_fat * (C_art_cbd - C_fat_cbd / Kp_fat_cbd)
    
    dA_muscle_cbd <- Q_muscle * (C_art_cbd - C_muscle_cbd / Kp_muscle_cbd)
    
    dA_liver_cbd <- Q_liver * (C_art_cbd - C_liver_cbd / Kp_liver_cbd) - 
                     CL_int_cbd * C_liver_cbd / Kp_liver_cbd
    
    dA_kidney_cbd <- Q_kidney * (C_art_cbd - C_kidney_cbd / Kp_kidney_cbd) - 
                      CL_renal_cbd * C_kidney_cbd / Kp_kidney_cbd
    
    dA_brain_cbd <- Q_brain * (C_art_cbd - C_brain_cbd / Kp_brain_cbd)
    
    dA_other_cbd <- Q_other * (C_art_cbd - C_other_cbd / Kp_other_cbd)
    
    dA_ven_cbd <- Q_fat * C_fat_cbd / Kp_fat_cbd +
                   Q_muscle * C_muscle_cbd / Kp_muscle_cbd +
                   Q_liver * C_liver_cbd / Kp_liver_cbd +
                   Q_kidney * C_kidney_cbd / Kp_kidney_cbd +
                   Q_brain * C_brain_cbd / Kp_brain_cbd +
                   Q_other * C_other_cbd / Kp_other_cbd -
                   Q_lung * C_ven_cbd
    
    # Return derivatives
    return(list(c(dA_lung_thc, dA_art_thc, dA_ven_thc, dA_fat_thc, dA_muscle_thc,
                  dA_liver_thc, dA_kidney_thc, dA_brain_thc, dA_other_thc,
                  dA_lung_cbd, dA_art_cbd, dA_ven_cbd, dA_fat_cbd, dA_muscle_cbd,
                  dA_liver_cbd, dA_kidney_cbd, dA_brain_cbd, dA_other_cbd),
                # Additional outputs for monitoring
                C_art_thc = C_art_thc,
                C_brain_thc = C_brain_thc,
                C_fat_thc = C_fat_thc,
                C_art_cbd = C_art_cbd,
                C_brain_cbd = C_brain_cbd,
                C_fat_cbd = C_fat_cbd))
  })
}
