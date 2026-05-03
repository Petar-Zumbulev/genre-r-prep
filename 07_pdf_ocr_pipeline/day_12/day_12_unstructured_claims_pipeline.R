# ============================================================
# Day 12 — Unstructured Claims Text to Validated Report
# ============================================================

# Goal:
# 1. Start with messy claim lines
# 2. Parse them into a structured table
# 3. Validate the parsed output
# 4. Calculate insurance KPIs
# 5. Export a small Excel report
# ============================================================


# -----------------------------
# 1. Load packages
# -----------------------------

library(tidyverse)
library(lubridate)
library(openxlsx)


# -----------------------------
# 2. Set paths
# -----------------------------

# This assumes your working directory is the project root.
# In RStudio, open your .Rproj file before running this script.

day_dir <- file.path("07_pdf_ocr_pipeline", "day_12")
output_dir <- file.path(day_dir, "outputs")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)


# -----------------------------
# 3. Create messy raw claim lines
# -----------------------------

raw_claim_lines <- c(
  "2024-01-15 | Claim C001 | Line: Health | Region: North | Amount: 1240.50 | Status: Paid",
  "2024-01-22 | Claim C002 | Line: Motor | Region: South | Amount: 875.00 | Status: Paid",
  "2024-02-03 | Claim C003 | Line: Property | Region: West | Amount: 5400.00 | Status: Open",
  "2024-02-19 | Claim C004 | Line: Health | Region: North | Amount: 320.75 | Status: Closed",
  "2024-03-08 | Claim C005 | Line: Motor | Region: West | Amount: 2200.00 | Status: Paid",
  "2024-04-12 | Claim C006 | Line: Property | Region: South | Amount: 7600.00 | Status: Paid",
  "2024-04-21 | Claim C007 | Line: Health | Region: North | Amount: 980.20 | Status: Paid",
  "2024-05-05 | Claim C008 | Line: Motor | Region: South | Amount: 410.00 | Status: Closed",
  "2024-05-18 | Claim C009 | Line: Property | Region: West | Amount: 12300.00 | Status: Paid",
  "2024-06-02 | Claim C010 | Line: Health | Region: East | Amount: 150.00 | Status: Paid",
  
  # Intentionally messy / problematic rows
  "2024-06-15 | Claim C011 | Line: Motor | Region: North | Amount: -200.00 | Status: Paid",
  "2024-07-01 | Claim C012 | Line: Health | Region: South | Amount: missing | Status: Paid",
  "BAD LINE WITHOUT THE EXPECTED STRUCTURE",
  "2024-07-22 | Claim C014 | Line: Motor | Region: West | Amount: 1550.00 | Status: Unknown"
)


# -----------------------------
# 4. Function: parse claim lines
# -----------------------------

# turn messy text into columns, it creates a tibble with columns
parse_claim_lines <- function(lines) {
  
  pattern <- paste0(
    "^(\\d{4}-\\d{2}-\\d{2})",
    " \\| Claim (C\\d+)",
    " \\| Line: ([A-Za-z]+)",
    " \\| Region: ([A-Za-z]+)",
    " \\| Amount: ([A-Za-z0-9.-]+)",
    " \\| Status: ([A-Za-z]+)$"
  )
  
  # search each line of the unstructured file 
  matches <- str_match(lines, pattern)
  
  parsed_tbl <- tibble(
    raw_line = lines,
    claim_date = ymd(matches[, 2]),
    claim_id = matches[, 3],
    business_line = matches[, 4],
    region = matches[, 5],
    claim_amount = suppressWarnings(as.numeric(matches[, 6])),
    status = matches[, 7],
    parse_success = !is.na(matches[, 2])
  )
  
  return(parsed_tbl)
}


# -----------------------------
# 5. Function: validate parsed claims
# -----------------------------

# never blindly trust parsed data, but always do validation checks
validate_claims <- function(parsed_tbl) {
  
  validated_tbl <- parsed_tbl %>%
    mutate(
      validation_issue = case_when(
        parse_success == FALSE ~ "Could not parse line",
        is.na(claim_date) ~ "Missing or invalid claim date",
        is.na(claim_id) ~ "Missing claim ID",
        is.na(business_line) ~ "Missing business line",
        is.na(region) ~ "Missing region",
        is.na(claim_amount) ~ "Missing or invalid claim amount",
        claim_amount < 0 ~ "Negative claim amount",
        !status %in% c("Paid", "Open", "Closed") ~ "Unexpected claim status",
        TRUE ~ NA_character_
      ),
      is_valid = is.na(validation_issue)
    )
  
  return(validated_tbl)
}


# -----------------------------
# 6. Function: calculate quarterly KPIs
# -----------------------------

calculate_quarterly_kpis <- function(validated_tbl) {
  
  kpi_tbl <- validated_tbl %>%
    filter(is_valid == TRUE) %>%
    mutate(
      year = year(claim_date),
      quarter = quarter(claim_date),
      year_quarter = paste0(year, " Q", quarter)
    ) %>%
    group_by(year_quarter, business_line, region) %>%
    summarise(
      claim_count = n(),
      total_claim_amount = sum(claim_amount, na.rm = TRUE),
      avg_severity = mean(claim_amount, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year_quarter, business_line, region)
  
  return(kpi_tbl)
}


# -----------------------------
# 7. Function: add simple premium logic
# -----------------------------

add_premium_logic <- function(kpi_tbl) {
  
  premium_tbl <- kpi_tbl %>%
    mutate(
      base_premium = case_when(
        business_line == "Health" ~ 4000,
        business_line == "Motor" ~ 5000,
        business_line == "Property" ~ 8000,
        TRUE ~ 3000
      ),
      premium = base_premium + claim_count * 250,
      loss_ratio = total_claim_amount / premium
    )
  
  return(premium_tbl)
}


# -----------------------------
# 8. Run the workflow
# -----------------------------

parsed_claims <- parse_claim_lines(raw_claim_lines)

validated_claims <- validate_claims(parsed_claims)

quarterly_kpis <- calculate_quarterly_kpis(validated_claims)

quarterly_report <- add_premium_logic(quarterly_kpis)


# -----------------------------
# 9. Create validation summary
# -----------------------------

validation_summary <- validated_claims %>%
  count(is_valid, validation_issue, name = "row_count") %>%
  arrange(is_valid, validation_issue)

validation_issues <- validated_claims %>%
  filter(is_valid == FALSE)


# -----------------------------
# 10. Print key outputs
# -----------------------------

cat("\n--- Parsed Claims ---\n")
print(parsed_claims)

cat("\n--- Validation Summary ---\n")
print(validation_summary)

cat("\n--- Validation Issues ---\n")
print(validation_issues)

cat("\n--- Quarterly Report ---\n")
print(quarterly_report)


# -----------------------------
# 11. Export to Excel
# -----------------------------

output_file <- file.path(output_dir, "day_12_claim_report.xlsx")

wb <- createWorkbook()

addWorksheet(wb, "parsed_claims")
writeData(wb, "parsed_claims", parsed_claims)

addWorksheet(wb, "validated_claims")
writeData(wb, "validated_claims", validated_claims)

addWorksheet(wb, "validation_summary")
writeData(wb, "validation_summary", validation_summary)

addWorksheet(wb, "validation_issues")
writeData(wb, "validation_issues", validation_issues)

addWorksheet(wb, "quarterly_report")
writeData(wb, "quarterly_report", quarterly_report)

saveWorkbook(wb, output_file, overwrite = TRUE)

cat("\nExcel report saved to:\n")
cat(output_file, "\n")


# -----------------------------
# 12. Save RDS outputs
# -----------------------------

saveRDS(validated_claims, file.path(output_dir, "validated_claims_day_12.rds"))
saveRDS(quarterly_report, file.path(output_dir, "quarterly_report_day_12.rds"))

cat("\nRDS files saved in:\n")
cat(output_dir, "\n")



