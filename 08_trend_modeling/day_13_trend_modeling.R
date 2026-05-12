# ============================================================
# Day 13 - Trend Modeling Basics
# Gen Re Analyst Role Prep
#
# Goal:
# - Create monthly insurance-style claims data
# - Calculate severity
# - Smooth severity with moving averages
# - Fit simple linear and log trend models
# - Export a reporting summary
# ============================================================


# ----------------------------
# 1. Load packages
# ----------------------------

library(tidyverse)
library(lubridate)
library(slider)
library(openxlsx)


# ----------------------------
# 2. Create output folder if needed
# ----------------------------

if (!dir.exists("outputs")) {
  dir.create("outputs")
}


# ----------------------------
# 3. Create synthetic claims data
# ----------------------------
# In a real job, this data would come from Excel, a database, or an RDS file.
# Today we create fake monthly data so we can focus on trend modeling.

set.seed(123)

monthly_claims <- tibble(
  accident_month = seq.Date(
    from = as.Date("2022-01-01"),
    to   = as.Date("2024-12-01"),
    by   = "month"
  )
) %>%
  mutate(
    month_index = row_number(),
    
    # Simulate claim counts.
    # Claims slowly increase over time, but with randomness.
    claim_count = round(rnorm(
      n = n(),
      mean = 80 + month_index * 0.8,
      sd = 8
    )),
    
    # Simulate average severity.
    # Severity also increases over time and has random noise.
    true_avg_severity = 2500 + month_index * 45,
    
    avg_severity_noisy = rnorm(
      n = n(),
      mean = true_avg_severity,
      sd = 350
    ),
    
    # Add some artificial claim spikes.
    # These represent unusually expensive months.
    avg_severity_noisy = case_when(
      accident_month == as.Date("2022-11-01") ~ avg_severity_noisy * 1.45,
      accident_month == as.Date("2023-08-01") ~ avg_severity_noisy * 1.55,
      accident_month == as.Date("2024-05-01") ~ avg_severity_noisy * 1.35,
      TRUE ~ avg_severity_noisy
    ),
    
    # Total claim amount = number of claims * average severity
    claim_amount = claim_count * avg_severity_noisy,
    
    # Simulate premium amount.
    # Premium grows, but not necessarily at exactly the same speed as claims.
    premium_amount = claim_count * (3200 + month_index * 35),
    
    # Create a basic inflation index.
    # 100 is the base level at the start.
    inflation_index = 100 * (1.004 ^ (month_index - 1))
  )


# ----------------------------
# 4. Create monthly reporting table
# ----------------------------
# This is the kind of table an analyst might build before reporting.

trend_tbl <- monthly_claims %>%
  mutate(
    year = year(accident_month),
    quarter = paste0("Q", quarter(accident_month)),
    year_quarter = paste0(year, "-", quarter),
    
    severity = claim_amount / claim_count,
    
    # Inflation-adjusted severity.
    # This converts each month's severity back to the base inflation level.
    severity_inflation_adjusted = severity / (inflation_index / 100),
    
    loss_ratio = claim_amount / premium_amount
  )


# ----------------------------
# 5. Add moving averages
# ----------------------------
# slide_dbl() lets us calculate rolling / moving values.
#
# .before = 2 means:
# current month + 2 months before = 3-month moving average


# Drill #1 was done here on line 131
# I changed it to .before = 3 to make a moving average of 
# 4 months and the line became smoother, because each point uses
# more months
trend_tbl <- trend_tbl %>%
  arrange(accident_month) %>%
  mutate(
    severity_ma_3 = slide_dbl(
      .x = severity,
      .f = mean,
      .before = 2,
      .complete = TRUE # R only calculates the value if it has all 3 months available
    ),
    
    severity_ma_6 = slide_dbl(
      .x = severity,
      .f = mean,
      .before = 5,
      .complete = TRUE # R only calculates the value if it has all 3 months available
    ),
    
    severity_adj_ma_3 = slide_dbl(
      .x = severity_inflation_adjusted,
      .f = mean,
      .before = 2,
      .complete = TRUE # R only calculates the value if it has all 3 months available
    ),
    
    # Drill #2 is right here, added this 12 month moving average and also 
    # added it to the plot
    severity_ma_12 = slide_dbl(
      .x = severity,
      .f = mean,
      .before = 11,
      .complete = TRUE
    )
  )


# ----------------------------
# 6. Fit a simple linear trend model
# ----------------------------
# This asks:
# "How many euros does average severity increase per month?"

linear_model <- lm(
  severity ~ month_index,
  data = trend_tbl
)

linear_summary <- summary(linear_model)

# severity increases by about 45 Euro per month, ceteris paribus
linear_monthly_change <- coef(linear_model)[["month_index"]]


# ----------------------------
# 7. Fit a log trend model
# ----------------------------
# This asks:
# "By approximately what percentage does severity grow each month?"
#
# We use log(severity), because percentage growth is easier to interpret
# with a log model.
#
# For insurance trend work because we usually care about percentage growth

log_model <- lm(
  log(severity) ~ month_index,
  data = trend_tbl
)

log_monthly_growth <- exp(coef(log_model)[["month_index"]]) - 1
log_annual_growth <- exp(12 * coef(log_model)[["month_index"]]) - 1


# ----------------------------
# 8. Add model predictions to the table
# ----------------------------

# very interesting, adding predictions, forecasts based on our linear or log model
# so this is why we build the models
trend_tbl <- trend_tbl %>%
  mutate(
    severity_linear_pred = predict(linear_model, newdata = trend_tbl),
    severity_log_pred = exp(predict(log_model, newdata = trend_tbl))
  )


# ----------------------------
# 9. Create quarterly summary
# ----------------------------
# Important:
# We do NOT average monthly severities directly.
# We recompute severity from totals:
#
# total claims / total claim count
#
# Do not average averages.
# Recalculate the metric from the underlying totals.

quarterly_summary <- trend_tbl %>%
  group_by(year_quarter) %>%
  summarise(
    total_claim_count = sum(claim_count),
    total_claim_amount = sum(claim_amount),
    total_premium = sum(premium_amount),
    
    severity = total_claim_amount / total_claim_count,
    loss_ratio = total_claim_amount / total_premium,
    
    # removes the hidden grouping memory
    .groups = "drop"
  )


# ----------------------------
# 10. Create trend interpretation table
# ----------------------------

trend_interpretation <- tibble(
  metric = c(
    "Linear monthly severity change",
    "Log monthly severity growth",
    "Log annualized severity growth"
  ),
  value = c(
    linear_monthly_change,
    log_monthly_growth,
    log_annual_growth
  ),
  interpretation = c(
    paste0(
      "Average severity increases by about €",
      round(linear_monthly_change, 2),
      " per month."
    ),
    paste0(
      "Average severity grows by about ",
      round(log_monthly_growth * 100, 2),
      "% per month."
    ),
    paste0(
      "Average severity grows by about ",
      round(log_annual_growth * 100, 2),
      "% per year if the monthly trend continues."
    )
  )
)


# ----------------------------
# 11. Plot raw severity, moving average, and model trend
# ----------------------------

severity_trend_plot <- ggplot(trend_tbl, aes(x = accident_month)) +
  geom_line(aes(y = severity), linewidth = 0.7, alpha = 0.5) +
  geom_line(aes(y = severity_ma_3), linewidth = 1) +
  geom_line(aes(y = severity_log_pred), linewidth = 1, linetype = "dashed") +
  
  # Drill #2 addition to the plot
  # The 12-month moving average is much smoother because it uses a full year of data.
  geom_line(aes(y = severity_ma_12), linewidth = 2) +
  labs(
    title = "Monthly Claim Severity Trend",
    subtitle = "Raw severity, 3-month moving average, and log trend model",
    x = "Accident month",
    y = "Average severity",
    caption = "Synthetic insurance data for R practice"
  ) +
  scale_y_continuous(
    labels = scales::label_number(
      prefix = "€",
      big.mark = ","
    )
  ) +
  theme_minimal()

print(severity_trend_plot)


# ----------------------------
# 12. Export plot
# ----------------------------

ggsave(
  filename = "outputs/day_13_severity_trend_plot.png",
  plot = severity_trend_plot,
  width = 9,
  height = 5,
  dpi = 300
)


# ----------------------------
# 13. Export Excel report
# ----------------------------

wb <- createWorkbook()

addWorksheet(wb, "monthly_trend_data")
addWorksheet(wb, "quarterly_summary")
addWorksheet(wb, "trend_interpretation")

writeData(wb, "monthly_trend_data", trend_tbl)
writeData(wb, "quarterly_summary", quarterly_summary)
writeData(wb, "trend_interpretation", trend_interpretation)

saveWorkbook(
  wb,
  file = "outputs/day_13_trend_summary.xlsx",
  overwrite = TRUE
)


# ----------------------------
# 14. Print key outputs
# ----------------------------

cat("\nLinear model interpretation:\n")
cat(
  "Average severity increases by about €",
  round(linear_monthly_change, 2),
  " per month.\n",
  sep = ""
)

cat("\nLog model interpretation:\n")
cat(
  "Average severity grows by about ",
  round(log_monthly_growth * 100, 2),
  "% per month.\n",
  sep = ""
)

cat(
  "Annualized severity growth is about ",
  round(log_annual_growth * 100, 2),
  "% per year.\n",
  sep = ""
)

cat("\nFiles created:\n")
cat("- outputs/day_13_severity_trend_plot.png\n")
cat("- outputs/day_13_trend_summary.xlsx\n")

