# concept demo of how R would talk to a database
# how R connects to SQL/Postgres Database
# basic DBI + RPostgres connection example
# understanding the structure of R-to-database workflows
# seeing how SQL lives inside R
# this is a big step in my analyst work

library(DBI) # DBI is the package with database functions for R
library(RPostgres) # postgres driver, connect, talk to postgres

# --------------------------------------------------
# Day 9 demo:
# basic structure for connecting R to a Postgres database
# --------------------------------------------------

# This is only a template example.
# I may not actually run this today if I do not have a real database set up.

# dbConnect() opens the connection to the database
# you need to store the database connection somewhere
con <- dbConnect(
  RPostgres::Postgres(), # tells R the type of database we're connecting to
  dbname = "my_database",
  host = "localhost",
  port = 5432, # the host machine may run many services, the port tells R which “door” to use to reach Postgres
  user = "my_user",
  password = "my_password"
)

# Store SQL code inside a string
qry <- "
SELECT
    policy_id,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_claim_amount
FROM claims
GROUP BY policy_id
"

# Run the SQL query and return the result to R as a data frame
# dbGetQuery() gives us a data frame / tibble object
# after running this, you have a R object that you got from the database
# and then you can summarize, aggergate, mutate, create a Shiny app with your 
# new R object called claims_summary
claims_summary <- dbGetQuery(con, qry)

# View result
print(claims_summary)

# Close connection
dbDisconnect(con)

