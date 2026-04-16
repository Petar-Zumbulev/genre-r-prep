# Day 9 — SQL and Postgres basics

## What SQL is
SQL is a language used to query, filter, group, sort, and join tabular data stored in a database.

## What Postgres is
Postgres (PostgreSQL) is a relational database system.
It stores data in tables and lets you query those tables with SQL.
Postgres is one of many relational database systems, others include: 
Oracle, MySQL, SQLite

## Core idea
SQL helps me:
- choose columns
- filter rows
- group rows
- calculate summaries
- sort results
- join tables

I just dont understand why we need SQL for things like choosing columns,
filtering rows, grouping, summaries, etc. when we just learned how to do 
all of this in R, with the summarize() group() mutate() functions

## Most important concept
Granularity = what one row represents.

Examples:
- one row per policy
- one row per claim
- one row per premium transaction
- one row per policy-quarter

Before I join tables, I should always ask:
What does one row represent in each table?

## Key SQL commands
- SELECT = choose columns
- FROM = choose the table
- WHERE = filter rows
- GROUP BY = define grouping level
- ORDER BY = sort rows
- JOIN = combine tables

## Important lesson
Do not join tables with different granularity carelessly.

If two detailed tables both have multiple rows per policy,
joining them directly can multiply rows and create wrong totals.

Safer habit:
aggregate first, then join.

## Memory phrase
Match granularity before joining.

## How SQL fits into R work
A common workflow is:
1. use SQL to pull or aggregate data from a database
2. bring the result into R
3. do cleaning, plotting, reporting, or Shiny work in R

## What I should be able to explain after Day 9
- what granularity means
- what a LEFT JOIN does
- why joins can duplicate rows
- how to compute claim count and severity in SQL
- how R connects to a SQL database conceptually