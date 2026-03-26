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
