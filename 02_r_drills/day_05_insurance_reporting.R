library(tidyverse)
library(lubridate)

set.seed(123)

# ----------------------------
# 1. Create a policy table
#
# We are building a policy-quarter dataset that can later be joined with 
# claims to produce insurance reports.
#
# building a fake insurance policy dataset from scratch
# creating the foundation table for the whole exercise
#
# data structure thinking
# one table has the base info, other tables hold transaction/reporting data
# later you join them together
# ----------------------------

'
policy_master = the static identity card of each policy
policies = the expanded reporting table
'

policy_ids <- sprintf("P%03d", 1:120)

policy_master <- tibble(
  policy_id = policy_ids,
  line = sample(c("Health", "Motor", "Property"), length(policy_ids), replace = TRUE),
  region = sample(c("North", "South", "West"), length(policy_ids), replace = TRUE)
)
# sample() creates the random values, choosing from the vector
# and sample() creates length(policy_ids) amount of random values
# and with replacement
#
# crossing() is for panel / repeated-period reporting structure
policies <- tidyr::crossing(
  policy_id = policy_ids,
  quarter_start = as.Date(c("2023-01-01", "2023-04-01", "2023-07-01", "2023-10-01"))
) %>%
  left_join(policy_master, by = "policy_id") %>%
  mutate(
    year = year(quarter_start),
    qtr = quarter(quarter_start),
    year_quarter = paste0(year, "-Q", qtr),
    exposure = round(runif(n(), 0.80, 1.00), 2), # exposure = how much of the quarter is effectively active for premium/risk
    premium = round(
      case_when(
        line == "Health"   ~ runif(n(), 1800, 3200),
        line == "Motor"    ~ runif(n(), 1000, 2400),
        line == "Property" ~ runif(n(), 1200, 2800)
      ) * exposure,
      2
    )
  )
# left join = keep all rows from left table, and bring in matching columns from right table
#
# This kind of logic is one of the most important things for my prep:
#
# synthetic data creation
# IDs and keys
# joins
# grouped reporting
# insurance-style tables
#
'
Goals:

attach claims to policies

compare premium vs claims

calculate severity and loss ratio

make quarterly reports
'


# ----------------------------
# Business reporting is often grouped by time periods
#
# monthly summaries
# quarterly summaries
# annual summaries
#
# convert raw dates into reporting periods
# ----------------------------


# insurance data often adjusts premium or risk measures based on exposure
# policies is your policy-quarter reporting table.
#
#
# policies is the policy-quarter reporting table
# Each row means:
# This specific policy, in this specific quarter, had this line, this region, 
# this exposure, and this premium.”




# ----------------------------
# 2. Create a claims table
# ----------------------------
  
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
# sample() makes observations by random sampling


# ----------------------------
# 3. Summarise claims per policy-quarter
# ----------------------------

claims_summary <- claims %>%
  group_by(policy_id, line, region, year_quarter) %>%
  summarise(
    claim_count = n(),
    total_claim_amount = sum(claim_amount),
    .groups = "drop"
  )
# using group_by to group based on policies, lines, regions, etc

# summarize is the actual calculation part



# ----------------------------
# 4. Add a simple inflation table
# ----------------------------

inflation_tbl <- tibble(
  year_quarter = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4"),
  inflation_index = c(1.00, 1.02, 1.04, 1.06)
)


# ----------------------------
# 5. Join premiums with claims
# ----------------------------

report_tbl <- policies %>%
  left_join(claims_summary, by = c("policy_id", "line", "region", "year_quarter")) %>%
  left_join(inflation_tbl, by = "year_quarter") %>%
  mutate(
    claim_count = coalesce(claim_count, 0L),
    total_claim_amount = coalesce(total_claim_amount, 0),
    adjusted_claim_amount = total_claim_amount / inflation_index,
    avg_severity = if_else(claim_count > 0, total_claim_amount / claim_count, 0),
    adjusted_avg_severity = if_else(claim_count > 0, adjusted_claim_amount / claim_count, 0),
    loss_ratio = total_claim_amount / premium
  )


# ----------------------------
# 6. Build a quarterly report by line
# ----------------------------

quarterly_report <- report_tbl %>%
  group_by(year_quarter, line) %>%
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
    loss_ratio = sum(total_claim_amount) / sum(premium),
    .groups = "drop"
  ) %>%
  mutate(
    year_quarter = factor(
      year_quarter,
      levels = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4")
    )
  )

# tells use how we need to adjust out premiums based on the loss ratio for
# each line and each quarter


# ----------------------------
# 7. Print report
# ----------------------------

print(quarterly_report)


# ----------------------------
# 8. Plot 1: Loss ratio by quarter and line
# ----------------------------

ggplot(quarterly_report, aes(x = year_quarter, y = loss_ratio, group = line, color = line)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Loss Ratio by Quarter and Line",
    x = "Quarter",
    y = "Loss Ratio"
  ) +
  theme_minimal()




# ----------------------------
# 9. Plot 2: Average severity by quarter and line
# ----------------------------

ggplot(quarterly_report, aes(x = year_quarter, y = avg_severity, fill = line)) +
  geom_col(position = "dodge") +
  labs(
    title = "Average Severity by Quarter and Line",
    x = "Quarter",
    y = "Average Severity"
  ) +
  theme_minimal()
  

# Plot 2 again but axis flipped

ggplot(quarterly_report, aes(x = year_quarter, y = avg_severity, fill = line)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Average Severity by Quarter and Line",
    x = "Quarter",
    y = "Average Severity"
  ) +
  theme_minimal()


# ----------------------------
# 10. Build a region-level report
# ----------------------------

region_report <- report_tbl %>%
  group_by(year_quarter, region) %>%
  summarise(
    total_premium = sum(premium),
    total_claim_amount = sum(total_claim_amount),
    claim_count = sum(claim_count),
    avg_severity = ifelse(
      sum(claim_count) > 0,
      sum(total_claim_amount) / sum(claim_count),
      0
    ),
    loss_ratio = sum(total_claim_amount) / sum(premium),
    .groups = "drop"
  ) %>%
  mutate(
    year_quarter = factor(
      year_quarter,
      levels = c("2023-Q1", "2023-Q2", "2023-Q3", "2023-Q4")
    )
  )

print(region_report)


# ----------------------------
# 11. Plot 3: Region loss ratio
# ----------------------------

ggplot(region_report, aes(x = year_quarter, y = loss_ratio, group = region, color = region)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Loss Ratio by Quarter and Region",
    x = "Quarter",
    y = "Loss Ratio"
  ) +
  theme_minimal()


# ----------------------------
# 12. Optional export
# ----------------------------

readr::write_csv(quarterly_report, "02_r_drills/day_05_quarterly_report.csv")
readr::write_csv(region_report, "02_r_drills/day_05_region_report.csv")


# -------------------------------------------
#
# Line and Region Report
#
# - grouped report by line and region
#
# -------------------------------------------
line_region_report <- report_tbl %>%
  group_by(line, region) %>%
  summarise(
    total_premium = sum(premium),
    total_claim_amount = sum(total_claim_amount),
    claim_count = sum(claim_count),
    avg_severity = ifelse(sum(claim_count) > 0, sum(total_claim_amount) / sum(claim_count), 0),
    loss_ratio = sum(total_claim_amount) / sum(premium),
    .groups = "drop"
  )

print(line_region_report)
