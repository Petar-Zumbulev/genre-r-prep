library(tidyverse)
library(lubridate)

set.seed(123)

# ----------------------------
# 1. Create a policy table
#
# building a fake insurance policy dataset from scratch
# creating the foundation table for the whole exercise
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


'
Goals:

attach claims to policies

compare premium vs claims

calculate severity and loss ratio

make quarterly reports
'


# ----------------------------
# 2. Create a claims table
# ----------------------------
  
  
  
  
  
  