# Day 6 notes — Understanding my Day 5 objects for Shiny

## Main question

When moving from Day 5 reporting into Day 6 Shiny, which object should be the main input table for the app?

The most likely answer is:

`report_tbl`

But this should still be checked once before building the full dashboard.

------------------------------------------------------------------------

## How to think about my Day 5 objects

| Object | What it likely is | Use for Shiny? |
|------------------------|------------------------|------------------------|
| `claims` | raw claims table | not the best starting point |
| `policies` / `policy_master` | raw or policy-level supporting tables | supporting data, not main Shiny base |
| `inflation_tbl` | lookup table | supporting data |
| `claims_summary` | already summarized claims output | too summarized for flexible Shiny |
| `quarterly_report` | final quarterly report output | useful as a check, but not ideal as the main base |
| `region_report` | final regional report output | useful as a check, but not ideal as the main base |
| `report_tbl` | joined/enriched reporting table | best candidate |

------------------------------------------------------------------------

## The core logic

For Shiny, I usually do **not** want to start from the final finished report tables.

Why?

Because the app needs enough detail to let the user:

-   filter by region
-   filter by line
-   filter by quarter
-   recompute summaries dynamically
-   generate different views from the same base data

That means the app should usually start from a table that is:

-   already cleaned
-   already joined
-   enriched with useful columns
-   but **not yet over-summarized**

That is why `report_tbl` is probably the best candidate.

------------------------------------------------------------------------

## A simple mental model

-   `claims`, `policies`, `inflation_tbl` = ingredients
-   `report_tbl` = the prepared base mixture
-   `quarterly_report`, `region_report` = finished report outputs

For Shiny, I usually want the **prepared base mixture**, not the finished output.

------------------------------------------------------------------------

## Why not start from `quarterly_report` or `region_report`?

Because those are already aggregated for one specific view.

That makes them useful for:

-   checking calculations
-   exporting reports
-   validating results

But not ideal for:

-   interactive filtering
-   recomputing metrics across multiple dimensions
-   building one app with many views

------------------------------------------------------------------------

## Why `report_tbl` is probably right

`report_tbl` is likely the table that still contains enough detail to support:

-   quarter filters
-   region filters
-   line filters
-   severity calculations
-   loss ratio calculations
-   summary tables
-   plots

So if I want a Shiny app that updates dynamically, `report_tbl` is the strongest candidate.

------------------------------------------------------------------------

## Important warning: granularity matters

Even if `report_tbl` is the correct starting object, I still need to check its row level.

Main question:

**What does one row in `report_tbl` represent?**

Possible answers:

-   one claim
-   one policy
-   one policy-quarter
-   one already aggregated segment row

This matters because if premium is repeated across multiple claim rows, then doing:

`sum(premium)`

can overcount premium.

That would make:

-   total premium wrong
-   loss ratio wrong

So before using `report_tbl` in Shiny, I need to confirm the granularity.

------------------------------------------------------------------------

## Best practical rule

### For static reporting

These are often fine:

-   `quarterly_report`
-   `region_report`

### For interactive dashboards

I usually want:

-   `report_tbl`

because the app needs a flexible base table.

------------------------------------------------------------------------

## Current best guess

Most likely:

-   `report_tbl` = correct base table for Day 6 Shiny
-   `quarterly_report` and `region_report` = final outputs created from `report_tbl`

But this should still be verified.

------------------------------------------------------------------------

## What I need to check next

To confirm whether `report_tbl` is really the right Day 6 table, I need to inspect:

-   its column names
-   its row structure
-   whether premium repeats
-   whether it contains line / region / date / claim amount / premium fields

Useful checks:

\`\`\`r names(report_tbl) glimpse(report_tbl) head(report_tbl, 10)

## Day 5 was:

“Run script → create one report”

## Day 6 becomes:

“User chooses filters → app updates the same report logic automatically”

# Understanding Shiny

## The 4 key ideas

## 1. ui

This is the front end. It is what the user sees:

dropdowns sliders tables plots titles

## 2. server

This is the logic layer. It does the work:

filter data calculate metrics create tables create plots

## 3. input

This is what the user selects. Example:

chosen line chosen region chosen quarter

## 4. reactive

This is the heart of Shiny.

It means:

“When the input changes, rerun the dependent calculation.”

So instead of you manually changing code and rerunning the script, the app does that for the user.

-   maybe the "dynamic" part

Day 5: I was the one changing the filters in code Day 6: the user changes the filters in the app

## Prepare dashboard-ready data

This is very important.

Do not throw messy raw data directly into Shiny

A good dashboard usually sits on top of a table that is already:

clean consistent grouped at the right level ready for filtering

For insurance metrics, granularity matters a lot.

Example:

If premium is repeated on every claim row, and then you sum premium in the app, you may accidentally double count premium.

That would make your loss ratio wrong.

So before Shiny, you want a clean table at the right level, such as:

one row per quarter-line-region or one row per policy-quarter

\^\^ that's the granularity part







## Explaining 'one row per quarter, line, region" from dashboard_metrics_prep.R


> each row represents one **unique combination** of:
- a quarter
- a business line
- a region

So instead of many detailed rows like:

- Policy P001, 2023-Q1, Property, South
- Policy P002, 2023-Q1, Property, South
- Policy P003, 2023-Q1, Property, South

you combine them into **one single summary row**:

- 2023-Q1, Property, South

And that one row contains the totals and ratios for that whole group.

---

## Simple example

Imagine `report_tbl` has 3 rows:

| policy_id | year_quarter | line | region | premium | claim_count | total_claim_amount |
|---|---|---|---|---:|---:|---:|
| P001 | 2023-Q1 | Property | South | 1000 | 1 | 500 |
| P002 | 2023-Q1 | Property | South | 2000 | 2 | 1200 |
| P003 | 2023-Q1 | Property | South | 1500 | 0 | 0 |

After rolling up, you get **one row**:

| quarter | line | region | total_premium | claim_count | total_claim_amount |
|---|---|---|---:|---:|---:|
| 2023-Q1 | Property | South | 4500 | 3 | 1700 |

Then you calculate:

- `avg_severity = 1700 / 3`
- `loss_ratio = 1700 / 4500`

---

# Why do we do this business-wise?

Because dashboards are usually meant to answer **management-level questions**, not policy-level detail questions.

A manager usually asks things like:

- How is **Property in South** doing this quarter?
- Which region has the highest loss ratio?
- Did severity worsen from Q1 to Q4?
- Where do we have claims pressure building up?

They usually do **not** ask:

- What happened on policy P001 specifically?

That second question is more detailed investigation.  
The first type is **dashboard reporting**.

So rolling up is really about matching the data structure to the business question.

---

# Why do we need aggregation?

## 1. To reduce noise

Detailed data has too much detail for a dashboard.

If you show hundreds of policy rows, it becomes hard to see patterns.

But if you group them into:

- quarter
- line
- region

you can immediately compare business segments.

So aggregation helps you see the **signal instead of the noise**.

---

## 2. To match how businesses think

Insurance businesses often monitor performance by segments like:

- time period
- line of business
- geography

Why?

Because those are common decision-making dimensions.

For example:

- **Quarter** tells you trend over time
- **Line** tells you which insurance business is stronger or weaker
- **Region** tells you where experience is better or worse

So these dimensions are not random.  
They are business reporting dimensions.

---

## 3. To create meaningful KPIs

Metrics like:

- claim count
- total claim amount
- premium
- severity
- loss ratio

become more useful when computed for a business segment.

For example:

A single policy’s loss ratio is often too noisy.

But the loss ratio for:

- Motor, North, 2023-Q2

is much more analytically useful.

Why?

Because it reflects the performance of a broader portfolio slice.

---

## 4. To make filtering easy in Shiny

Shiny works best when the data is already prepared at the level you want to analyze.

If the user chooses:

- line = Property
- region = South

then the app can quickly show the relevant quarter rows.

That is much easier if the table is already rolled up to that level.

So the rolled-up table is really the **correct dashboard grain**.

---

# What does “grain” mean here?

“Grain” means the level of detail of a row.

For example:

- policy-level grain = one row per policy-quarter
- dashboard grain = one row per quarter-line-region

So when we changed from `report_tbl` to `dashboard_metrics`, we changed the grain.

That is one of the most important ideas in analytics.

---

# Why not just use the detailed table directly?

You could, but it is usually worse for dashboarding.

## Problems with using detailed rows directly:

- harder to read
- harder to compare groups
- slower to plot and filter
- higher chance of calculation mistakes
- harder to explain business performance clearly

So instead, you pre-aggregate.

That gives you a cleaner and more trustworthy dashboard base.

---

# Why those three dimensions specifically?

Because each one answers a different business question.

## Quarter

Shows time trend.

Business question:

- Are we improving or worsening over time?

## Line

Shows portfolio type.

Business question:

- Which insurance product area is performing poorly?

## Region

Shows geographic difference.

Business question:

- Is one market or region driving bad results?

When you combine them, you can ask:

- How did **Motor in West** perform in **2023-Q3**?

That is a very realistic insurance reporting question.

---

# Why do we recalculate severity and loss ratio after grouping?

Because ratios usually should be recalculated from the totals.

For example:

## Severity

Not:

- average of averages

But:

- total claim amount / total claim count

## Loss ratio

Not:

- average of row-level loss ratios

But:

- total claim amount / total premium

That is analytically important because it keeps the group metric weighted correctly.

---

# The deeper analytical idea

What we are really doing is this:

> We are choosing the correct level at which the business should be analyzed.

That is one of the most important analyst skills.

Not just:

- “Can I code a plot?”

But:

- “At what level should I summarize the data so the metric is meaningful?”

That is real analytical thinking.

---

# Best simple summary

By rolling up to one row per:

- quarter
- line
- region

we are turning detailed operational data into **management-level performance data**.

That gives us:

- clearer trends
- better comparisons
- more meaningful KPIs
- easier Shiny filtering
- a dashboard that reflects how the business actually thinks
