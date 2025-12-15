library(shiny)
library(ggplot2)
library(plotly)
library(deSolve)

# Source the model functions if not loaded from package
if (!exists("pbpk_model", mode = "function") || 
    !exists("simulate_pbpk", mode = "function") ||
    !exists("get_default_params", mode = "function")) {
  source("../../R/pbpk_model.R")
  source("../../R/simulate_pbpk.R")
}

server <- function(input, output, session) {
  
  # Reactive value to store simulation results
  sim_results <- reactiveVal(NULL)
  
  # Observe reset button
  observeEvent(input$reset_params, {
    defaults <- get_default_params()
    
    # Update THC partition coefficients
    updateNumericInput(session, "Kp_fat_thc", value = defaults$Kp_fat_thc)
    updateNumericInput(session, "Kp_muscle_thc", value = defaults$Kp_muscle_thc)
    updateNumericInput(session, "Kp_liver_thc", value = defaults$Kp_liver_thc)
    updateNumericInput(session, "Kp_kidney_thc", value = defaults$Kp_kidney_thc)
    updateNumericInput(session, "Kp_brain_thc", value = defaults$Kp_brain_thc)
    updateNumericInput(session, "Kp_lung_thc", value = defaults$Kp_lung_thc)
    
    # Update CBD partition coefficients
    updateNumericInput(session, "Kp_fat_cbd", value = defaults$Kp_fat_cbd)
    updateNumericInput(session, "Kp_muscle_cbd", value = defaults$Kp_muscle_cbd)
    updateNumericInput(session, "Kp_liver_cbd", value = defaults$Kp_liver_cbd)
    updateNumericInput(session, "Kp_kidney_cbd", value = defaults$Kp_kidney_cbd)
    updateNumericInput(session, "Kp_brain_cbd", value = defaults$Kp_brain_cbd)
    updateNumericInput(session, "Kp_lung_cbd", value = defaults$Kp_lung_cbd)
    
    showNotification("Parameters reset to defaults", type = "message")
  })
  
  # Run simulation when button is clicked
  observeEvent(input$simulate, {
    
    # Show progress
    withProgress(message = 'Running simulation...', value = 0, {
      
      # Get default parameters
      params <- get_default_params(BW = input$BW)
      
      # Update with user inputs
      params$dose_thc <- input$dose_thc
      params$dose_cbd <- input$dose_cbd
      params$t_inh <- input$t_inh / 60  # Convert minutes to hours
      params$CL_int_thc <- input$CL_int_thc
      params$CL_renal_thc <- input$CL_renal_thc
      params$CL_int_cbd <- input$CL_int_cbd
      params$CL_renal_cbd <- input$CL_renal_cbd
      
      # Update partition coefficients
      params$Kp_fat_thc <- input$Kp_fat_thc
      params$Kp_muscle_thc <- input$Kp_muscle_thc
      params$Kp_liver_thc <- input$Kp_liver_thc
      params$Kp_kidney_thc <- input$Kp_kidney_thc
      params$Kp_brain_thc <- input$Kp_brain_thc
      params$Kp_lung_thc <- input$Kp_lung_thc
      
      params$Kp_fat_cbd <- input$Kp_fat_cbd
      params$Kp_muscle_cbd <- input$Kp_muscle_cbd
      params$Kp_liver_cbd <- input$Kp_liver_cbd
      params$Kp_kidney_cbd <- input$Kp_kidney_cbd
      params$Kp_brain_cbd <- input$Kp_brain_cbd
      params$Kp_lung_cbd <- input$Kp_lung_cbd
      
      incProgress(0.3, detail = "Setting up model...")
      
      # Create time vector
      times <- seq(0, input$sim_time, by = 0.1)
      
      incProgress(0.4, detail = "Solving differential equations...")
      
      # Run simulation
      results <- simulate_pbpk(params, times)
      
      incProgress(0.9, detail = "Preparing results...")
      
      # Store results
      sim_results(results)
      
      incProgress(1.0, detail = "Complete!")
    })
    
    showNotification("Simulation completed successfully!", type = "message", duration = 3)
  })
  
  # Status output
  output$status <- renderText({
    if (is.null(sim_results())) {
      return("No simulation run yet.\n\nClick 'Run Simulation' to start.")
    } else {
      results <- sim_results()
      max_time <- max(results$time)
      max_c_art_thc <- max(results$C_arterial_thc)
      max_c_art_cbd <- max(results$C_arterial_cbd)
      
      sprintf("Simulation complete!\n\nTime: 0 to %.1f hours\nMax arterial THC: %.3f mg/L\nMax arterial CBD: %.3f mg/L",
              max_time, max_c_art_thc, max_c_art_cbd)
    }
  })
  
  # Plot arterial concentrations
  output$plot_arterial <- renderPlotly({
    req(sim_results())
    
    results <- sim_results()
    
    p <- ggplot(results, aes(x = time)) +
      geom_line(aes(y = C_arterial_thc, color = "THC"), size = 1) +
      geom_line(aes(y = C_arterial_cbd, color = "CBD"), size = 1) +
      labs(x = "Time (hours)", 
           y = "Concentration (mg/L)",
           title = "Arterial Blood Concentrations",
           color = "Compound") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      scale_color_manual(values = c("THC" = "#E74C3C", "CBD" = "#3498DB"))
    
    ggplotly(p)
  })
  
  # Plot brain concentrations
  output$plot_brain <- renderPlotly({
    req(sim_results())
    
    results <- sim_results()
    
    p <- ggplot(results, aes(x = time)) +
      geom_line(aes(y = C_brain_thc, color = "THC"), size = 1) +
      geom_line(aes(y = C_brain_cbd, color = "CBD"), size = 1) +
      labs(x = "Time (hours)", 
           y = "Concentration (mg/L)",
           title = "Brain Tissue Concentrations",
           color = "Compound") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      scale_color_manual(values = c("THC" = "#E74C3C", "CBD" = "#3498DB"))
    
    ggplotly(p)
  })
  
  # Plot fat concentrations
  output$plot_fat <- renderPlotly({
    req(sim_results())
    
    results <- sim_results()
    
    p <- ggplot(results, aes(x = time)) +
      geom_line(aes(y = C_fat_thc, color = "THC"), size = 1) +
      geom_line(aes(y = C_fat_cbd, color = "CBD"), size = 1) +
      labs(x = "Time (hours)", 
           y = "Concentration (mg/L)",
           title = "Fat Tissue Concentrations",
           color = "Compound") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      scale_color_manual(values = c("THC" = "#E74C3C", "CBD" = "#3498DB"))
    
    ggplotly(p)
  })
  
  # Plot liver concentrations
  output$plot_liver <- renderPlotly({
    req(sim_results())
    
    results <- sim_results()
    
    p <- ggplot(results, aes(x = time)) +
      geom_line(aes(y = C_liver_thc, color = "THC"), size = 1) +
      geom_line(aes(y = C_liver_cbd, color = "CBD"), size = 1) +
      labs(x = "Time (hours)", 
           y = "Concentration (mg/L)",
           title = "Liver Tissue Concentrations",
           color = "Compound") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      scale_color_manual(values = c("THC" = "#E74C3C", "CBD" = "#3498DB"))
    
    ggplotly(p)
  })
  
  # Data table
  output$data_table <- DT::renderDataTable({
    req(sim_results())
    
    results <- sim_results()
    
    # Select key columns for display
    display_data <- results[, c("time", "C_arterial_thc", "C_arterial_cbd",
                                  "C_brain_thc", "C_brain_cbd",
                                  "C_fat_thc", "C_fat_cbd",
                                  "C_liver_thc", "C_liver_cbd")]
    
    DT::datatable(display_data, 
                  options = list(pageLength = 10, scrollX = TRUE),
                  rownames = FALSE) %>%
      DT::formatRound(columns = 2:9, digits = 4)
  })
  
  # Download handler
  output$download_data <- downloadHandler(
    filename = function() {
      paste("pbpk_simulation_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(sim_results(), file, row.names = FALSE)
    }
  )
}
