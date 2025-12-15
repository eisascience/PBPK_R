library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  
  dashboardHeader(title = "PBPK Model: THC & CBD Inhalation"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Model Simulation", tabName = "simulation", icon = icon("dashboard")),
      menuItem("Parameters", tabName = "parameters", icon = icon("sliders")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Simulation tab
      tabItem(tabName = "simulation",
        fluidRow(
          box(
            title = "Dosing Parameters",
            width = 4,
            solidHeader = TRUE,
            status = "primary",
            numericInput("dose_thc", "THC Dose (mg):", value = 10, min = 0, max = 100, step = 1),
            numericInput("dose_cbd", "CBD Dose (mg):", value = 5, min = 0, max = 100, step = 1),
            numericInput("t_inh", "Inhalation Duration (minutes):", value = 5, min = 1, max = 30, step = 1),
            numericInput("BW", "Body Weight (kg):", value = 70, min = 40, max = 150, step = 5),
            numericInput("sim_time", "Simulation Time (hours):", value = 24, min = 1, max = 72, step = 1),
            actionButton("simulate", "Run Simulation", icon = icon("play"), class = "btn-success btn-lg btn-block")
          ),
          
          box(
            title = "Clearance Parameters",
            width = 4,
            solidHeader = TRUE,
            status = "warning",
            numericInput("CL_int_thc", "THC Hepatic Clearance (L/hr):", value = 50, min = 0, max = 200, step = 5),
            numericInput("CL_renal_thc", "THC Renal Clearance (L/hr):", value = 0.5, min = 0, max = 10, step = 0.1),
            numericInput("CL_int_cbd", "CBD Hepatic Clearance (L/hr):", value = 45, min = 0, max = 200, step = 5),
            numericInput("CL_renal_cbd", "CBD Renal Clearance (L/hr):", value = 0.4, min = 0, max = 10, step = 0.1)
          ),
          
          box(
            title = "Simulation Status",
            width = 4,
            solidHeader = TRUE,
            status = "info",
            verbatimTextOutput("status"),
            hr(),
            h4("Quick Info:"),
            p("This PBPK model simulates the pharmacokinetics of THC and CBD after inhalation."),
            p("Adjust the dosing parameters and click 'Run Simulation' to see concentration-time profiles."),
            p("Default parameters are based on a 70 kg adult.")
          )
        ),
        
        fluidRow(
          box(
            title = "Arterial Blood Concentrations",
            width = 6,
            solidHeader = TRUE,
            status = "success",
            plotlyOutput("plot_arterial", height = "400px")
          ),
          
          box(
            title = "Brain Concentrations",
            width = 6,
            solidHeader = TRUE,
            status = "success",
            plotlyOutput("plot_brain", height = "400px")
          )
        ),
        
        fluidRow(
          box(
            title = "Fat Tissue Concentrations",
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            plotlyOutput("plot_fat", height = "400px")
          ),
          
          box(
            title = "Liver Concentrations",
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            plotlyOutput("plot_liver", height = "400px")
          )
        ),
        
        fluidRow(
          box(
            title = "Simulation Data Table",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            downloadButton("download_data", "Download CSV"),
            hr(),
            DT::dataTableOutput("data_table")
          )
        )
      ),
      
      # Parameters tab
      tabItem(tabName = "parameters",
        fluidRow(
          box(
            title = "THC Tissue Partition Coefficients",
            width = 6,
            solidHeader = TRUE,
            status = "warning",
            numericInput("Kp_fat_thc", "Fat (Kp):", value = 400, min = 1, max = 1000, step = 10),
            numericInput("Kp_muscle_thc", "Muscle (Kp):", value = 10, min = 1, max = 100, step = 1),
            numericInput("Kp_liver_thc", "Liver (Kp):", value = 20, min = 1, max = 100, step = 1),
            numericInput("Kp_kidney_thc", "Kidney (Kp):", value = 12, min = 1, max = 100, step = 1),
            numericInput("Kp_brain_thc", "Brain (Kp):", value = 25, min = 1, max = 100, step = 1),
            numericInput("Kp_lung_thc", "Lung (Kp):", value = 15, min = 1, max = 100, step = 1)
          ),
          
          box(
            title = "CBD Tissue Partition Coefficients",
            width = 6,
            solidHeader = TRUE,
            status = "warning",
            numericInput("Kp_fat_cbd", "Fat (Kp):", value = 300, min = 1, max = 1000, step = 10),
            numericInput("Kp_muscle_cbd", "Muscle (Kp):", value = 8, min = 1, max = 100, step = 1),
            numericInput("Kp_liver_cbd", "Liver (Kp):", value = 18, min = 1, max = 100, step = 1),
            numericInput("Kp_kidney_cbd", "Kidney (Kp):", value = 10, min = 1, max = 100, step = 1),
            numericInput("Kp_brain_cbd", "Brain (Kp):", value = 20, min = 1, max = 100, step = 1),
            numericInput("Kp_lung_cbd", "Lung (Kp):", value = 12, min = 1, max = 100, step = 1)
          )
        ),
        
        fluidRow(
          box(
            title = "Information",
            width = 12,
            solidHeader = TRUE,
            status = "info",
            h4("About Partition Coefficients:"),
            p("Partition coefficients (Kp) represent the ratio of tissue concentration to plasma concentration at equilibrium."),
            p("Higher values indicate greater tissue affinity and accumulation."),
            p("THC and CBD are both highly lipophilic, resulting in high fat partition coefficients."),
            actionButton("reset_params", "Reset to Defaults", icon = icon("undo"), class = "btn-warning")
          )
        )
      ),
      
      # About tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "About This Application",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            h3("PBPK Model for THC and CBD Inhalation"),
            p("This Shiny application implements a physiologically-based pharmacokinetic (PBPK) model 
              for simulating the disposition of delta-9-tetrahydrocannabinol (THC) and cannabidiol (CBD) 
              following inhalation exposure."),
            
            h4("Model Features:"),
            tags$ul(
              tags$li("Multi-compartment model with 9 tissue compartments per compound"),
              tags$li("Physiological tissue volumes and blood flow rates"),
              tags$li("Tissue-specific partition coefficients for THC and CBD"),
              tags$li("Hepatic metabolism and renal clearance"),
              tags$li("Simultaneous simulation of both compounds")
            ),
            
            h4("Model Compartments:"),
            tags$ul(
              tags$li("Lung (site of absorption)"),
              tags$li("Arterial and venous blood"),
              tags$li("Fat tissue (major storage site)"),
              tags$li("Muscle tissue"),
              tags$li("Liver (site of metabolism)"),
              tags$li("Kidney (site of excretion)"),
              tags$li("Brain (site of pharmacological effects)"),
              tags$li("Other tissues")
            ),
            
            h4("Usage:"),
            p("1. Adjust dosing parameters (THC dose, CBD dose, body weight) in the Simulation tab"),
            p("2. Optionally modify clearance and partition coefficient parameters"),
            p("3. Click 'Run Simulation' to generate concentration-time profiles"),
            p("4. View results in interactive plots and download data as CSV"),
            
            h4("References:"),
            p("This model is based on published PBPK models for cannabinoids and general PBPK modeling principles."),
            p("Default parameters are derived from literature values for a standard 70 kg adult."),
            
            hr(),
            p("Package: PBPKR v0.1.0"),
            p("License: MIT"),
            p(tags$a(href = "https://github.com/eisascience/PBPK_R", "GitHub Repository", target = "_blank"))
          )
        )
      )
    )
  )
)
