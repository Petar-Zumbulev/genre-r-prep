# concept demo of how R would talk to a database
# how R talks to SQL/Postgres
# basic DBI + RPostgres connection example

library(DBI)
library(RPostgres)

# --------------------------------------------------
# Day 9 demo:
# basic structure for connecting R to a Postgres database
# --------------------------------------------------

# This is only a template example.
# I may not actually run this today if I do not have a real database set up.

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "my_database",
  host = "localhost",
  port = 5432,
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
claims_summary <- dbGetQuery(con, qry)

# View result
print(claims_summary)

# Close connection
dbDisconnect(con)

