library(dplyr)
library(lubridate)

# --------------------------------------------------
# START FROM YOUR FINAL DAY 5 REPORTING TABLE
# which is called report_tbl
# --------------------------------------------------

# ----------------------------------------
# the new script explicitly runs the old script with source()
# it runs the other script, so all objects created there become available here.
# this is how you properly connect scripts in R
#
# we need to run the source() file because we need the 'report_tbl'
# in our environment because that's the cleaned, grouped, processed table
# ready for our dashboard
# ----------------------------------------

# Example expected columns in reporting_base which is report_tbl:
#
# report_date
# line
# region
# claim_amount
# premium
#
# Important:
# Only sum premium here if your table is already at the correct level.
# If premium repeats on every claim row, fix that first before using it here.
#

source("02_r_drills/day_05_reporting_functions.R")

dashboard_metrics <- report_tbl %>%
  mutate(
    quarter = year_quarter
  ) %>%
  group_by(quarter, line, region) %>%
  summarise(
    claim_count = sum(claim_count, na.rm = TRUE),
    total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
    total_premium = sum(premium, na.rm = TRUE),
    avg_severity = if_else(
      sum(claim_count, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      NA_real_
    ),
    loss_ratio = if_else(
      sum(premium, na.rm = TRUE) > 0,
      sum(total_claim_amount, na.rm = TRUE) / sum(premium, na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  ) %>%
  arrange(quarter, line, region)

dashboard_metrics

# created dashboard_metrics as a dashboard-ready summary table
#
# It takes the detailed rows in report_tbl and rolls them up into one row per:
#
# quarter
# line
# region
#
# Then for each of those groups it calculates the main business metrics:
#   
# claim count
# total claim amount
# total premium
# average severity
# loss ratio
#
# This is the table your Shiny app will read from
#
# It is a middle layer between:
#
# your raw/reporting logic
# and
# your dashboard
#
# report_tbl = reporting output
# dashboard_metrics = dashboard input

'
What “one row per quarter, line, region” means:

each row represents one unique combination of:

a quarter
a business line
a region

So instead of many detailed rows like:

Policy P001, 2023-Q1, Property, South
Policy P002, 2023-Q1, Property, South
Policy P003, 2023-Q1, Property, South

you combine them into one single summary row:

2023-Q1, Property, South

And that one row contains the totals and ratios for that whole group.
'

'
A manager usually asks things like:

How is Property in South doing this quarter?
Which region has the highest loss ratio?
Did severity worsen from Q1 to Q4?
Where do we have claims pressure building up?

They usually do not ask:

What happened on policy P001 specifically?

That second question is more detailed investigation.
The first type is dashboard reporting.

So rolling up is really about matching the data structure to the business question.
'


# ---------------------------------
#
# An .rds file is an R data file that stores one R object 
# exactly as it currently exists
#
# We need an RDS file .rds because when we run this script it
# will save the R object 'dashboard_metrics' which is the 
# starting point dashboard for shiny, and we need that in our app.R 
# for day 07
#
# R paths are based on the current working directory, not on where 
# the script file lives, thats why as long as my current working 
# directory for R is the root of the project, I can just use the 
# directory below to save my .rds file

# ---------------------------------
# SAVE THE PREPARED DASHBOARD DATA
# TO A PROJECT-LEVEL DATA FOLDER
# ---------------------------------

# Create the project-level data folder if it does not exist yet
if (!dir.exists(file.path("data"))) {
  dir.create(file.path("data"), recursive = TRUE)
}

# Save the prepared dashboard object in the shared project-level data folder
saveRDS(
  dashboard_metrics,
  file.path("data", "dashboard_metrics.rds")
)


'
dashboard_metrics = the object in your current R session
dashboard_metrics.rds = that same object saved to disk
'

'
You do not need .rds because Shiny requires it.

You use it because it is a clean way to separate data preparation from the app.
'

'
Without .rds

Your app would have to:

read raw files
clean them
join tables
build summaries
create dashboard_metrics

every time the app starts.

That is messy and slower.

With .rds

You do the prep once, save the finished table, and then your app just loads the ready-made object.
'


