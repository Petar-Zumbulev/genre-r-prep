---
editor_options: 
  markdown: 
    wrap: 72
---

# Day 9 — SQL and Postgres basics

## What SQL is

SQL is a language used to query, filter, group, sort, and join tabular
data stored in a database.

## What Postgres is

Postgres (PostgreSQL) is a relational database system. It stores data in
tables and lets you query those tables with SQL. Postgres is one of many
relational database systems, others include: Oracle, MySQL, SQLite

## Core idea

SQL helps me: - choose columns - filter rows - group rows - calculate
summaries - sort results - join tables

I just dont understand why we need SQL for things like choosing columns,
filtering rows, grouping, summaries, etc. when we just learned how to do
all of this in R, with the summarize() group() mutate() functions

-   SQL and R do overlapping things, but in different places for
    different reasons

-   R works on data you already have in memory

-   SQL works on data that still lives inside a database

-   Use SQL when you need to ask the database for data

-   Use R when you want to analyze, clean, visualize, report, and
    app-build with the data after that

-   Why not just do everything in R?

-   Because in many real jobs, the data is not sitting as a neat CSV on
    your laptop

-   It is often: inside a database very large split across multiple
    tables

-   So instead of doing this:

pull 20 million rows into R then filter to what you actually need

you do this:

use SQL to ask for only the needed rows/columns bring the smaller result
into R continue in R

## Most important concept

Granularity = what one row represents.

Examples: - one row per policy - one row per claim - one row per premium
transaction - one row per policy-quarter

Before I join tables, I should always ask: What does one row represent
in each table? Meaning, do the granularities match?

## Key SQL commands

-   SELECT = choose columns
-   FROM = choose the table
-   WHERE = filter rows
-   GROUP BY = define grouping level
-   ORDER BY = sort rows
-   JOIN = combine tables

## Important lesson

Do not join tables with different granularity carelessly.

If two detailed tables both have multiple rows per policy, joining them
directly can multiply rows and create wrong totals.

Safer habit: aggregate first, then join.

## Memory phrase

Match granularity before joining.

## How SQL fits into R work

A common workflow is: 1. use SQL to pull or aggregate data from a
database 2. bring the result into R 3. do cleaning, plotting, reporting,
or Shiny work in R

## What I should be able to explain after Day 9

-   what granularity means
-   what a LEFT JOIN does
-   why joins can duplicate rows
-   how to compute claim count and severity in SQL
-   how R connects to a SQL database conceptually

## Granularity and Using Joins

Be careful when joining two tables in SQL because you could accidently
multiply the rows if the granularities dont match

Rule 1: ask the “one row means what?” question

Before every join, ask:

What does one row represent in table A? What does one row represent in
table B?

Examples:

policies → one row = one policy claims → one row = one claim
premium_transactions → one row = one premium transaction

That question alone will save you a lot.

Rule 2: do the duplication test

Ask:

Can one ID from the left table match many rows on the right?

If yes, that join can expand rows.

Then ask again for the next table:

Can one ID from my current joined result also match many rows in the
next table?

If yes again, alarm bells should go off.

That usually means:

many + many = multiplication risk

A super simple visual trick

Draw this in your head:

Safe policies: 1 row per policy claim_totals: 1 row per policy
premium_totals: 1 row per policy

That is safe because everything matches.

Risky policies: 1 row per policy claims: many rows per policy
premium_transactions: many rows per policy

That is risky because both detailed tables can explode the join.

# How to solve row multiplication in SQL joins

## The problem

Row multiplication happens when I join two tables that both have
multiple rows for the same key.

Example: - `claims` has many rows per `policy_id` -
`premium_transactions` has many rows per `policy_id`

If I join both raw tables directly on `policy_id`, SQL can create all
combinations between claim rows and premium rows for the same policy.

That duplicates values and makes sums wrong.

------------------------------------------------------------------------

## The safe solution

### Step 1

Identify the level I want each table to be at before joining.

In this example, the safe level is:

-   one row per `policy_id`

------------------------------------------------------------------------

### Step 2

Aggregate each detailed table first.

Example:

-   turn `claims` into one row per policy with total claims
-   turn `premium_transactions` into one row per policy with total
    premium

So instead of joining raw detail tables, I join summarized tables.

------------------------------------------------------------------------

### Step 3

Join the summarized tables.

Now the join is much safer because the key matches at the same level:

-   `policies` = one row per policy
-   `claim_totals` = one row per policy
-   `premium_totals` = one row per policy

This means the granularity matches.

------------------------------------------------------------------------

### Step 4

Only after that, do the final summary.

For example:

-   first create policy-level totals
-   then group by line, region, quarter, etc.

So the logic becomes:

detail tables\
→ aggregate to safe level\
→ join\
→ final summary

------------------------------------------------------------------------

## The key rule

If both tables have many rows per key, do not join them raw unless I am
absolutely sure that multiplication is intended.

Safer default: **aggregate first, then join**

------------------------------------------------------------------------

## Good mental model

Bad pattern:

-   one policy
-   many claim rows
-   many premium rows
-   raw join
-   rows multiply

Better pattern:

-   one policy
-   one total claims row
-   one total premium row
-   safe join
-   correct totals

------------------------------------------------------------------------

## Best memory phrase

**Match granularity before joining.**

------------------------------------------------------------------------

## Short version

When two tables both have multiple rows for the same join key, I should
usually:

1.  summarize each table to the needed level first
2.  join those summarized tables
3.  then calculate final grouped results

This prevents duplicated rows and wrong totals.



# Quick fix checklist for join multiplication

Before joining, ask:

1. What does one row represent in each table?
2. Is the join key unique in each table?
3. If not unique in both tables, could rows multiply?
4. Should I aggregate first?

Safe pattern:

- summarize detail table A
- summarize detail table B
- join summarized tables
- then do final report summary


## Important Concept:

Granularity = what one row represents.

Examples:

one row = one policy
one row = one claim
one row = one policy-quarter
one row = one payment transaction


This matters because if you join tables with different granularity carelessly, 
you can create duplicates and wrong totals.


## Analyst Instinct:

What does one row represent, and what happens to row counts when I join?




