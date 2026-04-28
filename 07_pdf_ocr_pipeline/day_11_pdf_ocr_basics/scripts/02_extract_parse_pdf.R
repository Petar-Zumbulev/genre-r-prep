# ============================================================
# Day 11 — Script 02
# Extract PDF text, parse claim rows, and export report
# ============================================================

library(tidyverse)
library(lubridate)
library(pdftools)
library(openxlsx)

# ------------------------------------------------------------
# 1. Define paths
# ------------------------------------------------------------

base_dir <- "07_pdf_ocr_pipeline/day_11_pdf_ocr_basics"

pdf_path <- file.path(
  base_dir,
  "data_raw",
  "sample_claims_statement_q1_2025.pdf"
)

processed_dir <- file.path(base_dir, "data_processed")
output_dir <- file.path(base_dir, "outputs")

dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------
# 2. Load helper functions
# ------------------------------------------------------------

source(file.path(base_dir, "R", "00_helpers.R"))

# ------------------------------------------------------------
# 3. Extract raw text from the PDF
# ------------------------------------------------------------

extracted_text <- extract_pdf_text(pdf_path)

# Save raw extracted text so we can inspect it
raw_text_path <- file.path(processed_dir, "extracted_pdf_text.txt")

writeLines(extracted_text, raw_text_path)

# ------------------------------------------------------------
# 4. Split text into lines
# ------------------------------------------------------------

clean_lines <- split_pdf_lines(extracted_text)

# Look at the cleaned lines
print(clean_lines)

# ------------------------------------------------------------
# 5. Filter only the claim rows
# ------------------------------------------------------------

claim_lines <- filter_claim_lines(clean_lines)

print(claim_lines)

# ------------------------------------------------------------
# 6. Parse claim rows into a data frame
# ------------------------------------------------------------

claims_tbl <- parse_claim_lines(claim_lines)

print(claims_tbl)

# ------------------------------------------------------------
# 7. Create an insurance summary table
# ------------------------------------------------------------

summary_tbl <- summarise_claims(claims_tbl)

print(summary_tbl)

# ------------------------------------------------------------
# 8. Save processed files
# ------------------------------------------------------------

claims_csv_path <- file.path(processed_dir, "clean_claims.csv")
summary_csv_path <- file.path(processed_dir, "quarterly_summary.csv")

readr::write_csv(claims_tbl, claims_csv_path)
readr::write_csv(summary_tbl, summary_csv_path)

# ------------------------------------------------------------
# 9. Export final Excel report
# ------------------------------------------------------------

excel_output_path <- file.path(output_dir, "claims_pdf_extraction_report.xlsx")

export_claim_report(
  claims_tbl = claims_tbl,
  summary_tbl = summary_tbl,
  output_path = excel_output_path
)

message("Day 11 PDF extraction workflow complete.")