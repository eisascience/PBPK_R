# Global file for PBPK Shiny App
# This file loads before ui.R and server.R

# Load required packages
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(deSolve)
library(DT)

# Try to load from package first, otherwise source from files
tryCatch({
  library(PBPKR)
}, error = function(e) {
  # If package not installed, source the R files directly
  source("../../R/pbpk_model.R")
  source("../../R/simulate_pbpk.R")
})
