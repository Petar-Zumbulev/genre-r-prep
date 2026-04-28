# ============================================================
# Day 11 — Script 03
# Optional OCR demo
# ============================================================

# OCR means Optical Character Recognition.
# It is used when the document is an image, not selectable text.

base_dir <- "07_pdf_ocr_pipeline/day_11_pdf_ocr_basics"

raw_dir <- file.path(base_dir, "data_raw")
processed_dir <- file.path(base_dir, "data_processed")

dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)

image_path <- file.path(raw_dir, "sample_scanned_claim_note.png")

# ------------------------------------------------------------
# 1. Create a fake scanned image
# ------------------------------------------------------------

png(image_path, width = 1200, height = 800)

plot.new()

text(
  x = 0.05,
  y = 0.90,
  labels = "SCANNED CLAIM NOTE",
  adj = 0,
  cex = 2,
  font = 2
)

text(
  x = 0.05,
  y = 0.75,
  labels = "Claim ID: CLM007",
  adj = 0,
  cex = 1.5
)

text(
  x = 0.05,
  y = 0.65,
  labels = "Policy ID: POL1007",
  adj = 0,
  cex = 1.5
)

text(
  x = 0.05,
  y = 0.55,
  labels = "Paid Amount: 1980.00",
  adj = 0,
  cex = 1.5
)

text(
  x = 0.05,
  y = 0.45,
  labels = "Line: Health",
  adj = 0,
  cex = 1.5
)

dev.off()

# ------------------------------------------------------------
# 2. Try OCR with tesseract
# ------------------------------------------------------------

if (requireNamespace("tesseract", quietly = TRUE)) {
  
  ocr_text <- tesseract::ocr(image_path)
  
  print(ocr_text)
  
  output_path <- file.path(processed_dir, "ocr_extracted_text.txt")
  
  writeLines(ocr_text, output_path)
  
  message("OCR text saved to: ", output_path)
  
} else {
  
  message("The tesseract package is not installed or not available.")
  message("Install it with: install.packages('tesseract')")
}
