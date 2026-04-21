library(jsonlite)
library(dplyr)
library(tibble)

json_data <- fromJSON("05_api_json/day_10_api_json/api_json_mock_response.json")
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

# Drill 4:
# compute average claim amount by status

# Drill 5:
# count how many claims are in each region

# Drill 6:
# sort claims from highest to lowest claim_amount

# Drill 7:
# create a summary table with:
# region, claim_count, total_claim_amount, avg_claim_amount

# Drill 8:
# add report_date and portfolio from the top level JSON object
# into the claims table