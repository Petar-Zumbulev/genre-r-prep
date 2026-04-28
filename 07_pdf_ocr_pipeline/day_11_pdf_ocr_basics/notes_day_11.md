# Notes Day 11

## Parse

means to take raw data and convert it to structured, tabular data that we can then work with

Parsing means organizing raw data into a structured format, a data frame

the idea is to go from messy raw data to a structured data frame

## pdftools vs tesseract

If you can select/copy the text inside the PDF: use pdftools::pdf_text()

If the PDF is just a scanned image: use OCR with tesseract

# Day 11 — PDF/OCR to Structured Insurance Data in R

## Goal

Today I learned how to turn semi-structured document data into structured data in R.

This is useful for insurance because many workflows involve PDFs, claim reports, Excel files, scanned documents, or unstructured text.

## Main workflow

PDF/document\
→ extract text\
→ split into lines\
→ identify relevant rows\
→ parse rows into columns\
→ convert data types\
→ summarize KPIs\
→ export report

## Important distinction

### Text-based PDF

A text-based PDF already contains selectable text.

Tool:

\`\`\`r pdftools::pdf_text()
