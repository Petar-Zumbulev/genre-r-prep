library(tidyverse)
library(lubridate)
library(openxlsx)

set.seed(123)

# ---------------------------------
# 1. Create synthetic source data
# ---------------------------------

policy_ids <- sprintf("P%03d", 1:120)

policy_master <- tibble(
  policy_id = policy_ids,
  line = sample(c("Health", "Motor", "Property"), length(policy_ids), replace = TRUE),
  region = sample(c("North", "South", "West"), length(policy_ids), replace = TRUE)
)

policies <- tidyr::crossing(
  policy_id = policy_ids,
  quarter_start = as.Date(c("2023-01-01", "2023-04-01", "2023-07-01", "2023-10-01"))
) %>%
  left_join(policy_master, by = "policy_id") %>%
  mutate(
    year = year(quarter_start),
    qtr = quarter(quarter_start),
    year_quarter = paste0(year, "-Q", qtr),
    exposure = round(runif(n(), 0.80, 1.00), 2),
    premium = round(
      case_when(
        line == "Health"   ~ runif(n(), 1800, 3200),
        line == "Motor"    ~ runif(n(), 1000, 2400),
        line == "Property" ~ runif(n(), 1200, 2800)
      ) * exposure,
      2
    )
  )

claims <- tibble(
  claim_id = sprintf("C%04d", 1:360),
  policy_id = sample(policy_ids, 360, replace = TRUE),
  claim_date = sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"), 360, replace = TRUE)
) %>%
  left_join(policy_master, by = "policy_id") %>%
  mutate(
    year = year(claim_date),
    qtr = quarter(claim_date),
    year_quarter = paste0(year, "-Q", qtr),
    claim_amount = round(
      case_when(
        line == "Health"   ~ rlnorm(n(), meanlog = 7.6, sdlog = 0.45),
        line == "Motor"    ~ rlnorm(n(), meanlog = 7.3, sdlog = 0.55),
        line == "Property" ~ rlnorm(n(), meanlog = 7.5, sdlog = 0.50)
      ),
      2
    )
  )

inflation_tbl <- tibble(
  year_quarter = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4"),
  inflation_index = c(1.00, 1.02, 1.04, 1.06)
)


# ---------------------------------
# 2. Functions
# ---------------------------------

build_claims_summary <- function(claims_df) {
  claims_df %>%
    group_by(policy_id, line, region, year_quarter) %>%
    summarise(
      claim_count = n(),
      total_claim_amount = sum(claim_amount),
      .groups = "drop"
    )
}
#
# build_claims_summary is the function name
#
# claims_df is the input 
#
# the output is a summary table
#
# what the function does:
# “Take any claims table I give you, group it by policy, line, region, and quarter, 
# and return a summary with claim count and total claim amount.”
#
#
# it is like a little machine:
#  
# input: raw claims table
# process: group + summarise
# output: claims summary table
#
#
# Need a function because when the data changes, 
# the function recomputes the summary again with the new raw data
#
# the function gives us one clean rule that says this is 
# how we summarize claims
#
'
Examples of reusing the function on different datasets:

build_claims_summary(claims_2023)
build_claims_summary(claims_2024)
build_claims_summary(claims_test)

^^ This is calling the function

also, 

Instead of a giant wall of code, we can read:

claims_summary <- build_claims_summary(claims)
report_tbl <- build_report_table(...)

which is readable, re-usable, reliable
'

build_report_table <- function(policies_df, claims_summary_df, inflation_df) {
  policies_df %>%
    left_join(claims_summary_df, by = c("policy_id", "line", "region", "year_quarter")) %>%
    left_join(inflation_df, by = "year_quarter") %>%
    mutate(
      claim_count = coalesce(claim_count, 0L),
      total_claim_amount = coalesce(total_claim_amount, 0),
      adjusted_claim_amount = total_claim_amount / inflation_index,
      avg_severity = if_else(claim_count > 0, total_claim_amount / claim_count, 0),
      adjusted_avg_severity = if_else(claim_count > 0, adjusted_claim_amount / claim_count, 0),
      loss_ratio = total_claim_amount / premium
    )
}

summarise_metrics <- function(report_df, group_cols) {
  report_df %>%
    group_by(across(all_of(group_cols))) %>%
    summarise(
      policies = n(),
      total_premium = sum(premium),
      total_claim_amount = sum(total_claim_amount),
      adjusted_claim_amount = sum(adjusted_claim_amount),
      claim_count = sum(claim_count),
      avg_severity = ifelse(
        sum(claim_count) > 0,
        sum(total_claim_amount) / sum(claim_count),
        0
      ),
      loss_ratio = sum(total_claim_amount) / sum(total_premium),
      .groups = "drop"
    )
}

plot_metric_by_quarter <- function(summary_df, group_var, metric_var, title_text, y_label) {
  ggplot(
    summary_df,
    aes(
      x = year_quarter,
      y = .data[[metric_var]],
      group = .data[[group_var]],
      color = .data[[group_var]]
    )
  ) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    labs(
      title = title_text,
      x = "Quarter",
      y = y_label,
      color = group_var
    ) +
    theme_minimal()
}

export_reports_to_excel <- function(quarterly_df, region_df, file_name) {
  wb <- createWorkbook()
  
  addWorksheet(wb, "quarterly_report")
  addWorksheet(wb, "region_report")
  
  writeData(wb, "quarterly_report", quarterly_df)
  writeData(wb, "region_report", region_df)
  
  saveWorkbook(wb, file_name, overwrite = TRUE)
}


# ---------------------------------
# 3. Run the workflow
# ---------------------------------

claims_summary <- build_claims_summary(claims)

report_tbl <- build_report_table(
  policies_df = policies,
  claims_summary_df = claims_summary,
  inflation_df = inflation_tbl
)

quarterly_report <- summarise_metrics(
  report_df = report_tbl,
  group_cols = c("year_quarter", "line")
) %>%
  mutate(
    year_quarter = factor(
      year_quarter,
      levels = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4")
    )
  )

region_report <- summarise_metrics(
  report_df = report_tbl,
  group_cols = c("year_quarter", "region")
) %>%
  mutate(
    year_quarter = factor(
      year_quarter,
      levels = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4")
    )
  )

print(quarterly_report)
print(region_report)


# ---------------------------------
# 4. Plots
# ---------------------------------

plot_loss_ratio_line <- plot_metric_by_quarter(
  summary_df = quarterly_report,
  group_var = "line",
  metric_var = "loss_ratio",
  title_text = "Loss Ratio by Quarter and Line",
  y_label = "Loss Ratio"
)

plot_severity_line <- plot_metric_by_quarter(
  summary_df = quarterly_report,
  group_var = "line",
  metric_var = "avg_severity",
  title_text = "Average Severity by Quarter and Line",
  y_label = "Average Severity"
)

plot_loss_ratio_region <- plot_metric_by_quarter(
  summary_df = region_report,
  group_var = "region",
  metric_var = "loss_ratio",
  title_text = "Loss Ratio by Quarter and Region",
  y_label = "Loss Ratio"
)

print(plot_loss_ratio_line)
print(plot_severity_line)
print(plot_loss_ratio_region)


# ---------------------------------
# 5. Excel export
# ---------------------------------

export_reports_to_excel(
  quarterly_df = quarterly_report,
  region_df = region_report,
  file_name = "02_r_drills/day5_reporting_output.xlsx"
)

# ---------------------------------
# 6. Simple checks
# ---------------------------------

cat("Rows in report_tbl:", nrow(report_tbl), "\n")
cat("Rows in quarterly_report:", nrow(quarterly_report), "\n")
cat("Rows in region_report:", nrow(region_report), "\n")

cat("Missing values in loss_ratio (quarterly_report):", sum(is.na(quarterly_report$loss_ratio)), "\n")
cat("Missing values in loss_ratio (region_report):", sum(is.na(region_report$loss_ratio)), "\n")







# in real analyst work you often do:
  
# raw transaction data
# summary layer
# reporting layer
#
# so 3 different layers


# build_report_table()
# very common business pattern:
  
# one table has exposure/premium info
# another table has claims info
# you join them
# then calculate metrics

'
3) summarise_metrics(report_df, group_cols)

This is the most important new idea in Part 2.

Instead of writing:

one summary for line
another summary for region
another summary for something else

you write one function and only change the grouping columns.

That is cleaner and more professional.

Example:

summarise_metrics(report_tbl, c("year_quarter", "line"))
summarise_metrics(report_tbl, c("year_quarter", "region"))

That is exactly the kind of thing that looks good in an interview.
'


'
business interpretation task:

Which line has the worst loss ratio trend?
Property

Which region looks weakest overall?
Either South or West

Does inflation-adjusted claim cost look meaningfully different from raw claim cost?
Starting in Q2 there is a meaningful difference and it grows with the next quarters.
That makes sense, its inflation.
(answer is from quarterly_report because we summarized total claim and adjusted 
claims there)
(the difference does not appear extremely large, so I would describe it as modest
rather than strongly meaningful)
("Starting in Q2, the inflation-adjusted claim cost becomes lower than the raw
claim cost, and the gap grows in later quarters. The difference is noticeable 
and increasing over time, but it looks gradual rather than dramatic.")

Why is it useful to build one summary function instead of writing separate summaries manually?
a summary function is useful because its dynamic, we can re-use the function for many
different summaries with different inputs

("A summary function is useful because it:

avoids repeating the same code many times
makes the script cleaner and easier to maintain
reduces the chance of mistakes
lets you create multiple report views from the same logic")

("A summary function is useful because it lets us reuse the same reporting
logic for different groupings, such as by line or by region, without rewriting
the code each time. This makes the script cleaner, more consistent, easier to 
maintain, and less error-prone.")
'






