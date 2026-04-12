library(dplyr)
library(openxlsx)

# load the prepared dashboard data from the project-level data folder
# assuming our current working directory is the main root folder
dashboard_data <- readRDS(file.path("data", "dashboard_metrics.rds"))

# ---------------------------
# summary tables
# ---------------------------

# 1) Quarter summary
quarter_summary <- dashboard_data %>%
  group_by(quarter) %>%
  summarise(
    claim_count = sum(claim_count, na.rm = TRUE),
    total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
    total_premium = sum(total_premium, na.rm = TRUE),
    avg_severity = ifelse(
      sum(claim_count, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      NA_real_
    ),
    loss_ratio = ifelse(
      sum(total_premium, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(total_premium, na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  )

# 2) Line summary
line_summary <- dashboard_data %>%
  group_by(line) %>%
  summarise(
    claim_count = sum(claim_count, na.rm = TRUE),
    total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
    total_premium = sum(total_premium, na.rm = TRUE),
    avg_severity = ifelse(
      sum(claim_count, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      NA_real_
    ),
    loss_ratio = ifelse(
      sum(total_premium, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(total_premium, na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  )

# 3) Region Summary
region_summary <- dashboard_data %>%
  group_by(region) %>%
  summarise(
    claim_count = sum(claim_count, na.rm = TRUE),
    total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
    total_premium = sum(total_premium, na.rm = TRUE),
    avg_severity = ifelse(
      sum(claim_count, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      NA_real_
    ),
    loss_ratio = ifelse(
      sum(total_premium, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(total_premium, na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  )

# ---------------------------
# create workbook
# ---------------------------

wb <- createWorkbook()

addWorksheet(wb, "quarter_summary")
addWorksheet(wb, "line_summary")
addWorksheet(wb, "region_summary")
addWorksheet(wb, "raw_data")

writeData(wb, "quarter_summary", quarter_summary, withFilter = TRUE)
writeData(wb, "line_summary", line_summary, withFilter = TRUE)
writeData(wb, "region_summary", region_summary, withFilter = TRUE)
writeData(wb, "raw_data", dashboard_data, withFilter = TRUE)

# ---------------------------
# styles
# ---------------------------

header_style <- createStyle(textDecoration = "bold")
percent_style <- createStyle(numFmt = "0.0%")
number_style <- createStyle(numFmt = "#,##0.00")
integer_style <- createStyle(numFmt = "#,##0")

# freeze top row
freezePane(wb, "quarter_summary", firstRow = TRUE)
freezePane(wb, "line_summary", firstRow = TRUE)
freezePane(wb, "region_summary", firstRow = TRUE)
freezePane(wb, "raw_data", firstRow = TRUE)

# auto widths
setColWidths(wb, "quarter_summary", cols = 1:ncol(quarter_summary), widths = "auto")
setColWidths(wb, "line_summary", cols = 1:ncol(line_summary), widths = "auto")
setColWidths(wb, "region_summary", cols = 1:ncol(region_summary), widths = "auto")
setColWidths(wb, "raw_data", cols = 1:ncol(dashboard_data), widths = "auto")

# bold headers
addStyle(wb, "quarter_summary", header_style, rows = 1, cols = 1:ncol(quarter_summary), gridExpand = TRUE)
addStyle(wb, "line_summary", header_style, rows = 1, cols = 1:ncol(line_summary), gridExpand = TRUE)
addStyle(wb, "region_summary", header_style, rows = 1, cols = 1:ncol(region_summary), gridExpand = TRUE)
addStyle(wb, "raw_data", header_style, rows = 1, cols = 1:ncol(dashboard_data), gridExpand = TRUE)

# ---------------------------
# format quarter_summary
# ---------------------------

quarter_names <- names(quarter_summary)

addStyle(
  wb, "quarter_summary", integer_style,
  rows = 2:(nrow(quarter_summary) + 1),
  cols = which(quarter_names == "claim_count"),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "quarter_summary", number_style,
  rows = 2:(nrow(quarter_summary) + 1),
  cols = which(quarter_names %in% c("total_claim_amount", "total_premium", "avg_severity")),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "quarter_summary", percent_style,
  rows = 2:(nrow(quarter_summary) + 1),
  cols = which(quarter_names == "loss_ratio"),
  gridExpand = TRUE, stack = TRUE
)

# ---------------------------
# format line_summary
# ---------------------------

line_names <- names(line_summary)

addStyle(
  wb, "line_summary", integer_style,
  rows = 2:(nrow(line_summary) + 1),
  cols = which(line_names == "claim_count"),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "line_summary", number_style,
  rows = 2:(nrow(line_summary) + 1),
  cols = which(line_names %in% c("total_claim_amount", "total_premium", "avg_severity")),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "line_summary", percent_style,
  rows = 2:(nrow(line_summary) + 1),
  cols = which(line_names == "loss_ratio"),
  gridExpand = TRUE, stack = TRUE
)

# ---------------------------
# format region_summary
# ---------------------------

region_names <- names(region_summary)

addStyle(
  wb, "region_summary", integer_style,
  rows = 2:(nrow(region_summary) + 1),
  cols = which(region_names == "claim_count"),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "region_summary", number_style,
  rows = 2:(nrow(region_summary) + 1),
  cols = which(region_names %in% c("total_claim_amount", "total_premium", "avg_severity")),
  gridExpand = TRUE, stack = TRUE
)

addStyle(
  wb, "region_summary", percent_style,
  rows = 2:(nrow(region_summary) + 1),
  cols = which(region_names == "loss_ratio"),
  gridExpand = TRUE, stack = TRUE
)

# ---------------------------
# save workbook
# ---------------------------

saveWorkbook(
  wb,
  file = file.path("04_excel_reporting", "output", "dashboard_report.xlsx"),
  overwrite = TRUE
)