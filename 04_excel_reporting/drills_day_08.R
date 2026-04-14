# 04_excel_reporting/drills_day8.R

library(dplyr)
library(openxlsx)

# --------------------------------------------------
# Assumption:
# You already have a data frame called dashboard_metrics
#
# Expected columns:
# quarter, line, claim_count, claim_amount, premium
#
# If your claim amount column has a different name,
# replace "claim_amount" everywhere below.
# --------------------------------------------------

# Optional safety check
required_cols <- c("quarter", "line", "claim_count", "claim_amount", "premium")

missing_cols <- setdiff(required_cols, names(dashboard_metrics))

if (length(missing_cols) > 0) {
  stop(
    paste(
      "These required columns are missing from dashboard_metrics:",
      paste(missing_cols, collapse = ", ")
    )
  )
}

# --------------------------------------------------
# Drill 1
# Export workbook with:
# - quarter_summary
# - line_summary
# - raw_data
# --------------------------------------------------

quarter_summary <- dashboard_metrics %>%
  group_by(quarter) %>%
  summarise(
    claim_count = sum(claim_count, na.rm = TRUE),
    claim_amount = sum(claim_amount, na.rm = TRUE),
    premium = sum(premium, na.rm = TRUE),
    avg_severity = ifelse(
      sum(claim_count, na.rm = TRUE) > 0,
      sum(claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      NA_real_
    ),
    loss_ratio = ifelse(
      sum(premium, na.rm = TRUE) > 0,
      sum(claim_amount, na.rm = TRUE) / sum(premium, na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  )

line_summary <- dashboard_metrics %>%
  group_by(line) %>%
  summarise(
    claim_count = sum(claim_count, na.rm = TRUE),
    claim_amount = sum(claim_amount, na.rm = TRUE),
    premium = sum(premium, na.rm = TRUE),
    avg_severity = ifelse(
      sum(claim_count, na.rm = TRUE) > 0,
      sum(claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      NA_real_
    ),
    loss_ratio = ifelse(
      sum(premium, na.rm = TRUE) > 0,
      sum(claim_amount, na.rm = TRUE) / sum(premium, na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  )

# --------------------------------------------------
# Drill 2
# Add definitions sheet
# --------------------------------------------------

definitions_tbl <- data.frame(
  metric = c("claim_count", "claim_amount", "avg_severity", "loss_ratio"),
  definition = c(
    "Total number of claims",
    "Total claim cost / claim amount",
    "Average cost per claim = claim_amount / claim_count",
    "Loss ratio = claim_amount / premium"
  ),
  stringsAsFactors = FALSE
)

# --------------------------------------------------
# Create workbook
# --------------------------------------------------

wb <- createWorkbook()

addWorksheet(wb, "quarter_summary")
addWorksheet(wb, "line_summary")
addWorksheet(wb, "raw_data")
addWorksheet(wb, "definitions")

writeData(wb, "quarter_summary", quarter_summary, withFilter = TRUE)
writeData(wb, "line_summary", line_summary, withFilter = TRUE)
writeData(wb, "raw_data", dashboard_metrics, withFilter = TRUE)
writeData(wb, "definitions", definitions_tbl, withFilter = TRUE)

# --------------------------------------------------
# Styling
# --------------------------------------------------

header_style <- createStyle(
  textDecoration = "bold"
)

number_style <- createStyle(
  numFmt = "#,##0.00"
)

percent_style <- createStyle(
  numFmt = "0.0%"
)

# Freeze top row
freezePane(wb, "quarter_summary", firstRow = TRUE)
freezePane(wb, "line_summary", firstRow = TRUE)
freezePane(wb, "raw_data", firstRow = TRUE)
freezePane(wb, "definitions", firstRow = TRUE)

# Auto column widths
setColWidths(wb, "quarter_summary", cols = 1:ncol(quarter_summary), widths = "auto")
setColWidths(wb, "line_summary", cols = 1:ncol(line_summary), widths = "auto")
setColWidths(wb, "raw_data", cols = 1:ncol(dashboard_metrics), widths = "auto")
setColWidths(wb, "definitions", cols = 1:ncol(definitions_tbl), widths = "auto")

# Header style on all sheets
addStyle(
  wb, "quarter_summary", header_style,
  rows = 1, cols = 1:ncol(quarter_summary),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "line_summary", header_style,
  rows = 1, cols = 1:ncol(line_summary),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "raw_data", header_style,
  rows = 1, cols = 1:ncol(dashboard_metrics),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "definitions", header_style,
  rows = 1, cols = 1:ncol(definitions_tbl),
  gridExpand = TRUE, stack = TRUE
)

# --------------------------------------------------
# Drill 3
# Format loss_ratio as percent
# Also format avg_severity as number
# --------------------------------------------------

quarter_names <- names(quarter_summary)
line_names <- names(line_summary)

if ("avg_severity" %in% quarter_names) {
  addStyle(
    wb, "quarter_summary", number_style,
    rows = 2:(nrow(quarter_summary) + 1),
    cols = which(quarter_names == "avg_severity"),
    gridExpand = TRUE, stack = TRUE
  )
}

if ("loss_ratio" %in% quarter_names) {
  addStyle(
    wb, "quarter_summary", percent_style,
    rows = 2:(nrow(quarter_summary) + 1),
    cols = which(quarter_names == "loss_ratio"),
    gridExpand = TRUE, stack = TRUE
  )
}

if ("avg_severity" %in% line_names) {
  addStyle(
    wb, "line_summary", number_style,
    rows = 2:(nrow(line_summary) + 1),
    cols = which(line_names == "avg_severity"),
    gridExpand = TRUE, stack = TRUE
  )
}

if ("loss_ratio" %in% line_names) {
  addStyle(
    wb, "line_summary", percent_style,
    rows = 2:(nrow(line_summary) + 1),
    cols = which(line_names == "loss_ratio"),
    gridExpand = TRUE, stack = TRUE
  )
}

# --------------------------------------------------
# Drill 4
# Make filename include today's date
# --------------------------------------------------

output_dir <- file.path("04_excel_reporting", "output")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

output_file <- file.path(
  output_dir,
  paste0("dashboard_report_", Sys.Date(), ".xlsx")
)

saveWorkbook(wb, file = output_file, overwrite = TRUE)

cat("Workbook saved to:", output_file, "\n")