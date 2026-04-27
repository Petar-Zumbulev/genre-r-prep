library(jsonlite)
library(dplyr)
library(tibble)

json_data <- fromJSON("06_api_json/day_10_api_json/api_json_mock_response.json")
claims_tbl <- as_tibble(json_data$records)

# Drill 1:
# create a new column called adjusted_claim_amount
# using claim_amount * inflation_index

claims_tbl <- claims_tbl %>%
  mutate(
    adjusted_claim_amount = claim_amount * inflation_index
  )

# Drill 2:
# return only claims where status == "Open"

open_claims_tbl <- claims_tbl %>%
  filter(status == "Open")

# Drill 3:
# compute total claim amount by region
# classic summary example
total_claim_region <- claims_tbl %>%
  group_by(region) %>%
  summarise(
    total_claim_amount = sum(claim_amount),
    .groups = "drop"
  )

# Drill 4:
# compute average claim amount by status
avg_claim_status <- claims_tbl %>%
  group_by(status) %>%
  summarise(
    avg_claim_amount = mean(claim_amount),
    .groups = "drop"
  )

# Drill 5:
# count how many claims are in each region
claims_per_region <- claims_tbl %>%
  group_by(region) %>%
  summarise(
    claim_count = n(),
    .groups = "drop"
  )

# Drill 6:
# sort claims from highest to lowest claim_amount
claims_sorted <- claims_tbl %>%
  arrange(desc(claim_amount))

# Drill 7:
# create a summary table with:
# region, claim_count, total_claim_amount, avg_claim_amount
# group by region
summary_table <- claims_tbl %>%
  group_by(region) %>%
  summarise(
    claim_count = n(),
    total_claim_amount = sum(claim_amount),
    avg_claim_amount = mean(claim_amount),
    .groups = "drop"
  )


# Drill 8:
# add report_date and portfolio from the top level JSON object
# into the claims table
# use json_data$ to reach into the json response and pull data
claims_tbl <- claims_tbl %>%
  mutate(
    report_date = json_data$report_date,
    portfolio = json_data$portfolio
  )








