
---
  
  # 8. Starter R files
  
  ## `R/00_packages.R`
  
  ```r
# ============================================================
# 00_packages.R
# Load packages for the insurance dashboard project
# ============================================================

packages <- c(
  "tidyverse",
  "lubridate",
  "ggplot2",
  "shiny",
  "DT",
  "scales",
  "openxlsx"
)

new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]

if (length(new_packages) > 0) {
  install.packages(new_packages)
}

lapply(packages, library, character.only = TRUE)