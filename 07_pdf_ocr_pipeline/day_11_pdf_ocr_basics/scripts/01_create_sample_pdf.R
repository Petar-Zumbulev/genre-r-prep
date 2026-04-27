# ============================================================
# Day 11 — Script 01
# Create a sample insurance-style PDF
# ============================================================

# This script creates a simple text-based PDF.
# Later we will extract the text from this PDF using pdftools.

# Create paths
base_dir <- "07_pdf_ocr_pipeline/day_11_pdf_ocr_basics"

raw_dir <- file.path(base_dir, "data_raw")

dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

pdf_path <- file.path(raw_dir, "sample_claims_statement_q1_2025.pdf")

# Lines that will appear in the PDF
pdf_lines <- c(
  "GEN RE SAMPLE CLAIMS STATEMENT",
  "Reporting period: Q1 2025",
  "",
  "This document contains sample claim records for training purposes.",
  "",
  "CLAIM_ID | POLICY_ID | ACCIDENT_DATE | LINE | PAID_AMOUNT",
  "CLM001 | POL1001 | 2025-01-14 | Health   | 1250.00",
  "CLM002 | POL1002 | 2025-01-22 | Motor    | 850.00",
  "CLM003 | POL1003 | 2025-02-03 | Property | 2300.00",
  "CLM004 | POL1004 | 2025-02-18 | Health   | 1750.00",
  "CLM005 | POL1005 | 2025-03-05 | Motor    | 620.00",
  "CLM006 | POL1006 | 2025-03-21 | Property | 3100.00",
  "",
  "End of report."
)

# Create a PDF using base R
pdf(pdf_path, width = 8.5, height = 11)

plot.new()

# Add title
text(
  x = 0.05,
  y = 0.95,
  labels = pdf_lines[1],
  adj = 0,
  cex = 1.2,
  font = 2
)

# Add remaining lines
y_start <- 0.90
line_spacing <- 0.045

for (i in 2:length(pdf_lines)) {
  text(
    x = 0.05,
    y = y_start - (i - 2) * line_spacing,
    labels = pdf_lines[i],
    adj = 0,
    cex = 0.9
  )
}

dev.off()

message("Sample PDF created at: ", pdf_path)