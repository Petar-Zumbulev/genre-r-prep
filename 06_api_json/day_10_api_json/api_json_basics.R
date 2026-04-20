library(jsonlite)
library(dplyr)
library(tibble)
library(readr)

# --------------------------------------------------
# DAY 10
# API + JSON workflow in R
# Big idea:
# read JSON -> inspect structure -> extract nested data
# -> turn into tibble -> clean -> report -> export
# --------------------------------------------------

# 1. Read the mock JSON file
json_data <- fromJSON("06_api_json/day_10_api_json/api_json_mock_response.json")

# 2. Inspect the object
str(json_data)

# 3. Pull out the nested records table
claims_tbl <- as_tibble(json_data$records)

# 4. Add top-level metadata if useful
claims_tbl <- claims_tbl %>%
  mutate(
    report_date = json_data$report_date,
    portfolio = json_data$portfolio
  )

# 5. Create an inflation-adjusted amount
claims_tbl <- claims_tbl %>%
  mutate(
    adjusted_claim_amount = claim_amount * inflation_index
  )

# 6. Build a simple reporting table
summary_tbl <- claims_tbl %>%
  group_by(region, status) %>%
  summarise(
    claim_count = n(),
    total_claim_amount = sum(claim_amount),
    avg_claim_amount = mean(claim_amount),
    total_adjusted_claim_amount = sum(adjusted_claim_amount),
    .groups = "drop"
  )

# 7. Print results
print(claims_tbl)
print(summary_tbl)

# 8. Export cleaned detailed table
write_csv(
  claims_tbl,
  "06_api_json/day_10_api_json/api_json_report_output.csv"
)




