# ============================================================
# Day 11 — Helper functions
# PDF/OCR to structured insurance data
#
# This file stores helper functions. 
# This is better than putting everything into one huge script.
# ============================================================

library(tidyverse)
library(lubridate)
library(pdftools)
library(openxlsx)

# ------------------------------------------------------------
# Function 1: Extract text from a text-based PDF
# ------------------------------------------------------------

extract_pdf_text <- function(pdf_path) {
  
  if (!file.exists(pdf_path)) {
    stop("PDF file does not exist: ", pdf_path)
  }
  
  extracted_text <- pdftools::pdf_text(pdf_path)
  
  return(extracted_text)
}


# ------------------------------------------------------------
# Function 2: Split extracted text into clean lines
# ------------------------------------------------------------

split_pdf_lines <- function(extracted_text) {
  
  clean_lines <- extracted_text |>
    paste(collapse = "\n") |>
    stringr::str_split("\n") |>
    unlist() |>
    stringr::str_trim()
  
  clean_lines <- clean_lines[clean_lines != ""]
  
  return(clean_lines)
}


# ------------------------------------------------------------
# Function 3: Keep only claim rows
# ------------------------------------------------------------

filter_claim_lines <- function(clean_lines) {
  
  claim_lines <- clean_lines |>
    stringr::str_subset("^CLM[0-9]+\\s*\\|")
  
  return(claim_lines)
}


# ------------------------------------------------------------
# Function 4: Parse claim rows into a structured table
# ------------------------------------------------------------

parse_claim_lines <- function(claim_lines) {
  
  claims_tbl <- tibble(raw_line = claim_lines) |>
    tidyr::separate_wider_delim(
      cols = raw_line,
      delim = "|",
      names = c(
        "claim_id",
        "policy_id",
        "accident_date",
        "line",
        "paid_amount"
      )
    ) |>
    mutate(
      across(everything(), stringr::str_trim),
      accident_date = lubridate::ymd(accident_date),
      paid_amount = readr::parse_number(paid_amount),
      quarter = paste0(lubridate::year(accident_date), " Q", lubridate::quarter(accident_date))
    )
  
  return(claims_tbl)
}


# ------------------------------------------------------------
# Function 5: Create insurance summary table
# ------------------------------------------------------------

summarise_claims <- function(claims_tbl) {
  
  summary_tbl <- claims_tbl |>
    group_by(quarter, line) |>
    summarise(
      claim_count = n(),
      total_paid = sum(paid_amount, na.rm = TRUE),
      avg_severity = mean(paid_amount, na.rm = TRUE),
      .groups = "drop"
    ) |>
    arrange(quarter, line)
  
  return(summary_tbl)
}


# ------------------------------------------------------------
# Function 6: Export clean data and summary to Excel
# ------------------------------------------------------------

export_claim_report <- function(claims_tbl, summary_tbl, output_path) {
  
  wb <- openxlsx::createWorkbook()
  
  openxlsx::addWorksheet(wb, "clean_claims")
  openxlsx::writeData(wb, "clean_claims", claims_tbl)
  
  openxlsx::addWorksheet(wb, "quarterly_summary")
  openxlsx::writeData(wb, "quarterly_summary", summary_tbl)
  
  openxlsx::saveWorkbook(wb, output_path, overwrite = TRUE)
  
  message("Excel report exported to: ", output_path)
}