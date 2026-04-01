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

> each row represents one **unique combination** of: - a quarter - a business line - a region

So instead of many detailed rows like:

-   Policy P001, 2023-Q1, Property, South
-   Policy P002, 2023-Q1, Property, South
-   Policy P003, 2023-Q1, Property, South

you combine them into **one single summary row**:

-   2023-Q1, Property, South

And that one row contains the totals and ratios for that whole group.

------------------------------------------------------------------------

## Simple example

Imagine `report_tbl` has 3 rows:

| policy_id | year_quarter | line     | region | premium | claim_count | total_claim_amount |
|-----------|-----------|-----------|-----------|----------:|----------:|----------:|
| P001      | 2023-Q1      | Property | South  |    1000 |           1 |                500 |
| P002      | 2023-Q1      | Property | South  |    2000 |           2 |               1200 |
| P003      | 2023-Q1      | Property | South  |    1500 |           0 |                  0 |

After rolling up, you get **one row**:

| quarter | line     | region | total_premium | claim_count | total_claim_amount |
|---------|----------|--------|--------------:|------------:|-------------------:|
| 2023-Q1 | Property | South  |          4500 |           3 |               1700 |

Then you calculate:

-   `avg_severity = 1700 / 3`
-   `loss_ratio = 1700 / 4500`

------------------------------------------------------------------------

# Why do we do this business-wise?

Because dashboards are usually meant to answer **management-level questions**, not policy-level detail questions.

A manager usually asks things like:

-   How is **Property in South** doing this quarter?
-   Which region has the highest loss ratio?
-   Did severity worsen from Q1 to Q4?
-   Where do we have claims pressure building up?

They usually do **not** ask:

-   What happened on policy P001 specifically?

That second question is more detailed investigation.\
The first type is **dashboard reporting**.

So rolling up is really about matching the data structure to the business question.

------------------------------------------------------------------------

# Why do we need aggregation?

## 1. To reduce noise

Detailed data has too much detail for a dashboard.

If you show hundreds of policy rows, it becomes hard to see patterns.

But if you group them into:

-   quarter
-   line
-   region

you can immediately compare business segments.

So aggregation helps you see the **signal instead of the noise**.

------------------------------------------------------------------------

## 2. To match how businesses think

Insurance businesses often monitor performance by segments like:

-   time period
-   line of business
-   geography

Why?

Because those are common decision-making dimensions.

For example:

-   **Quarter** tells you trend over time
-   **Line** tells you which insurance business is stronger or weaker
-   **Region** tells you where experience is better or worse

So these dimensions are not random.\
They are business reporting dimensions.

------------------------------------------------------------------------

## 3. To create meaningful KPIs

Metrics like:

-   claim count
-   total claim amount
-   premium
-   severity
-   loss ratio

become more useful when computed for a business segment.

For example:

A single policy’s loss ratio is often too noisy.

But the loss ratio for:

-   Motor, North, 2023-Q2

is much more analytically useful.

Why?

Because it reflects the performance of a broader portfolio slice.

------------------------------------------------------------------------

## 4. To make filtering easy in Shiny

Shiny works best when the data is already prepared at the level you want to analyze.

If the user chooses:

-   line = Property
-   region = South

then the app can quickly show the relevant quarter rows.

That is much easier if the table is already rolled up to that level.

So the rolled-up table is really the **correct dashboard grain**.

------------------------------------------------------------------------

# What does “grain” mean here?

“Grain” means the level of detail of a row.

For example:

-   policy-level grain = one row per policy-quarter
-   dashboard grain = one row per quarter-line-region

So when we changed from `report_tbl` to `dashboard_metrics`, we changed the grain.

That is one of the most important ideas in analytics.

------------------------------------------------------------------------

# Why not just use the detailed table directly?

You could, but it is usually worse for dashboarding.

## Problems with using detailed rows directly:

-   harder to read
-   harder to compare groups
-   slower to plot and filter
-   higher chance of calculation mistakes
-   harder to explain business performance clearly

So instead, you pre-aggregate.

That gives you a cleaner and more trustworthy dashboard base.

------------------------------------------------------------------------

# Why those three dimensions specifically?

Because each one answers a different business question.

## Quarter

Shows time trend.

Business question:

-   Are we improving or worsening over time?

## Line

Shows portfolio type.

Business question:

-   Which insurance product area is performing poorly?

## Region

Shows geographic difference.

Business question:

-   Is one market or region driving bad results?

When you combine them, you can ask:

-   How did **Motor in West** perform in **2023-Q3**?

That is a very realistic insurance reporting question.

------------------------------------------------------------------------

# Why do we recalculate severity and loss ratio after grouping?

Because ratios usually should be recalculated from the totals.

For example:

## Severity

Not:

-   average of averages

But:

-   total claim amount / total claim count

## Loss ratio

Not:

-   average of row-level loss ratios

But:

-   total claim amount / total premium

That is analytically important because it keeps the group metric weighted correctly.

------------------------------------------------------------------------

# The deeper analytical idea

What we are really doing is this:

> We are choosing the correct level at which the business should be analyzed.

That is one of the most important analyst skills.

Not just:

-   “Can I code a plot?”

But:

-   “At what level should I summarize the data so the metric is meaningful?”

That is real analytical thinking.

------------------------------------------------------------------------

# Best simple summary

By rolling up to one row per:

-   quarter
-   line
-   region

we are turning detailed operational data into **management-level performance data**.

That gives us:

-   clearer trends
-   better comparisons
-   more meaningful KPIs
-   easier Shiny filtering
-   a dashboard that reflects how the business actually thinks

# Day 6 libraries, main functions, and what they do

## 1. `shiny`

### What we use `shiny` for

We use `shiny` to build the interactive app itself.

It helps us: - create the app layout - add filters like dropdown menus - show tables and plots - react automatically when a user changes an input

So `shiny` is the library that turns normal R analysis into an interactive dashboard.

------------------------------------------------------------------------

### Main `shiny` functions and attributes we used

#### `fluidPage()`

Creates the main page layout of the app.

It helps us: - make the overall app page - hold all other UI elements inside it - create a flexible page that adjusts to screen size

Example role: - this is the outer container of the whole app

------------------------------------------------------------------------

#### `titlePanel()`

Adds the title at the top of the app.

It helps us: - name the dashboard clearly - make the app feel structured and professional

------------------------------------------------------------------------

#### `sidebarLayout()`

Splits the app into two main areas: - sidebar - main content area

It helps us: - put filters on one side - put tables and plots on the other side

This is a very common dashboard layout.

------------------------------------------------------------------------

#### `sidebarPanel()`

Creates the sidebar section.

It helps us: - place user controls there - keep filters organized

In our app, this is where the dropdown filters go.

------------------------------------------------------------------------

#### `mainPanel()`

Creates the main display area.

It helps us: - show the outputs of the app - place tables and plots in the main area

------------------------------------------------------------------------

#### `selectInput()`

Creates a dropdown menu.

It helps us: - let the user choose a value - filter the dashboard interactively

In our app, we used it for: - `line` - `region`

Main arguments we used: - `inputId` = the internal name of the input - `label` = what the user sees - `choices` = the dropdown options - `selected` = the default selected value

------------------------------------------------------------------------

#### `tableOutput()`

Creates a placeholder for a table in the UI.

It helps us: - reserve space where a table will appear later

Important idea: - `tableOutput()` is in the UI - `renderTable()` is in the server

They work together.

------------------------------------------------------------------------

#### `plotOutput()`

Creates a placeholder for a plot in the UI.

It helps us: - reserve space where a chart will appear later

Important idea: - `plotOutput()` is in the UI - `renderPlot()` is in the server

They work together.

------------------------------------------------------------------------

#### `reactive()`

Creates a reactive object.

It helps us: - store a calculation that updates automatically when inputs change - avoid repeating the same filtering logic in many places - keep the app clean and reusable

In our app, `reactive()` was used for: - `filtered_metrics` - `overall_metrics`

Simple meaning: - when the user changes a filter, the reactive object recalculates

This is one of the most important ideas in Shiny.

------------------------------------------------------------------------

#### `renderTable()`

Creates a table in the server that gets sent to the UI.

It helps us: - display summary tables - show updated results based on filters

In our app, it was used for: - the KPI table - the quarterly summary table

------------------------------------------------------------------------

#### `renderPlot()`

Creates a plot in the server that gets sent to the UI.

It helps us: - display charts - update visuals automatically when the user changes filters

In our app, it was used for: - the severity trend plot - the loss ratio trend plot

------------------------------------------------------------------------

#### `input$line` and `input$region`

These are reactive input values.

They help us: - read the user’s current selection - use that selection inside filtering logic

Example meaning: - `input$line` = whatever line the user selected - `input$region` = whatever region the user selected

So `input$...` is how the server reads user choices.

------------------------------------------------------------------------

#### `shinyApp(ui = ui, server = server)`

Launches the app.

It helps us: - connect the UI and server together - actually run the Shiny application

------------------------------------------------------------------------

### Simple summary of `shiny`

We use `shiny` to build the whole interactive dashboard.

It helps us: - create layout - add filters - define outputs - connect user inputs to calculations - make tables and plots update automatically

------------------------------------------------------------------------

## 2. `dplyr`

### What we use `dplyr` for

We use `dplyr` for data manipulation.

It helps us: - filter rows - create new columns - group data - summarize metrics - sort results - build clean reporting tables

This is one of the most important libraries for analyst work in R.

------------------------------------------------------------------------

### Main `dplyr` functions and attributes we used

#### `%>%`

This is the pipe operator.

It helps us: - pass the result of one step into the next step - write code as a readable sequence of actions

Instead of nesting many functions inside each other, we can write the logic step by step.

Simple meaning: - “take this result, then do the next thing”

------------------------------------------------------------------------

#### `mutate()`

Creates or changes columns.

It helps us: - add derived features - transform existing columns

In our code, we used it to create: - `quarter` - formatted KPI values

------------------------------------------------------------------------

#### `group_by()`

Groups rows before summarizing.

It helps us: - tell R at what level we want calculations done

In our prep table, we grouped by: - `quarter` - `line` - `region`

That means: - compute one result for each quarter-line-region combination

------------------------------------------------------------------------

#### `summarise()`

Collapses many rows into a smaller summary table.

It helps us: - calculate totals - calculate averages - roll data up into reporting-level outputs

In our app, we used it to create: - claim counts - total claim amount - average severity - total premium - loss ratio

This is one of the most important reporting functions in R.

------------------------------------------------------------------------

#### `filter()`

Keeps only rows that match a condition.

It helps us: - subset the data - apply dashboard filters

In our app, we used it inside the reactive object to filter by: - selected line - selected region

------------------------------------------------------------------------

#### `arrange()`

Sorts rows.

It helps us: - order a table in a meaningful way - make quarterly output easier to read

In our app, we used it to arrange by: - `quarter`

------------------------------------------------------------------------

#### `if_else()`

Creates a conditional result.

It helps us: - apply logic like “if this is true, do X, otherwise do Y” - avoid errors such as division by zero

In our code, we used it for: - average severity only when claim count is greater than zero - loss ratio only when premium is greater than zero

------------------------------------------------------------------------

#### `n()`

Counts rows inside `summarise()`.

It helps us: - count how many observations are in each group

In our prep script, it was used for: - `claim_count = n()`

------------------------------------------------------------------------

#### `sum(..., na.rm = TRUE)`

Adds values together while ignoring missing values.

It helps us: - compute totals without breaking because of `NA` values

We used it for: - total claim amount - total premium - total claims in KPI summaries

------------------------------------------------------------------------

#### `.groups = "drop"`

This is an argument inside `summarise()`.

It helps us: - remove the grouping after the summary is created - return a normal tibble instead of a still-grouped object

This is useful because it avoids confusion later in the script.

------------------------------------------------------------------------

### Simple summary of `dplyr`

We use `dplyr` to clean, filter, transform, group, summarize, and sort data.

It helps us: - turn raw data into reporting tables - create business metrics - prepare data for Shiny outputs

------------------------------------------------------------------------

## 3. `ggplot2`

### What we use `ggplot2` for

We use `ggplot2` to make charts.

It helps us: - visualize trends - compare values over time - communicate business results clearly

In our app, it creates the dashboard plots.

------------------------------------------------------------------------

### Main `ggplot2` functions and attributes we used

#### `ggplot()`

Starts a plot.

It helps us: - define the dataset for the chart - begin the chart-building process

------------------------------------------------------------------------

#### `aes()`

Defines aesthetic mappings.

It helps us: - tell the plot what goes on the x-axis - tell the plot what goes on the y-axis - define groups or other visual mappings

In our app, we used: - `x = quarter` - `y = avg_severity` or `loss_ratio` - `group = 1`

------------------------------------------------------------------------

#### `geom_line()`

Draws a line chart.

It helps us: - show trends over time - connect values across quarters

In our app, it was used for: - severity trend - loss ratio trend

------------------------------------------------------------------------

#### `geom_point()`

Adds points to the chart.

It helps us: - show the actual observed values - make each quarter easier to see

Using `geom_line()` + `geom_point()` together is very common for business time trends.

------------------------------------------------------------------------

#### `labs()`

Adds labels and titles.

It helps us: - name the axes - give the chart a title - make the chart easier to interpret

In our app, we used it for: - x-axis label - y-axis label - plot title

------------------------------------------------------------------------

#### `theme_minimal()`

Applies a clean visual style.

It helps us: - remove clutter - make the chart look professional - keep the focus on the data

------------------------------------------------------------------------

#### `scale_y_continuous(labels = percent)`

Formats the y-axis.

It helps us: - display loss ratio as percentages instead of decimals

Example: - `0.35` becomes `35%`

This is especially useful in insurance/business reporting.

------------------------------------------------------------------------

### Simple summary of `ggplot2`

We use `ggplot2` to build charts.

It helps us: - visualize trends - communicate metrics clearly - make the dashboard easier to understand

------------------------------------------------------------------------

## 4. `scales`

### What we use `scales` for

We use `scales` for formatting numbers.

It helps us: - display percentages nicely - make outputs more business-friendly - improve readability in plots and tables

------------------------------------------------------------------------

### Main `scales` functions we used

#### `percent()`

Formats a decimal as a percentage.

It helps us: - display values in a business format - make ratios easier to interpret

Examples: - `0.25` becomes `25%` - `0.347` becomes `34.7%` depending on settings

In our app, it was used for: - formatting `overall_loss_ratio` - formatting the y-axis for the loss ratio plot

------------------------------------------------------------------------

#### `accuracy = 0.1`

This is an argument inside `percent()`.

It helps us: - control rounding precision

Example: - `accuracy = 0.1` means one decimal place of precision in percentage formatting

------------------------------------------------------------------------

### Simple summary of `scales`

We use `scales` to format numbers, especially percentages.

It helps us: - make ratios easier to read - make charts and tables feel more polished and business-ready

------------------------------------------------------------------------

# Final simple overview

## `shiny`

**Use:** build the interactive app\
**Helps us do:** layout, filters, tables, plots, reactivity, dashboard behavior

Main functions we used: - `fluidPage()` - `titlePanel()` - `sidebarLayout()` - `sidebarPanel()` - `mainPanel()` - `selectInput()` - `tableOutput()` - `plotOutput()` - `reactive()` - `renderTable()` - `renderPlot()` - `shinyApp()` - `input$line` - `input$region`

------------------------------------------------------------------------

## `dplyr`

**Use:** manipulate and summarize data\
**Helps us do:** filtering, grouping, summarizing, creating metrics, sorting, table prep

Main functions we used: - `%>%` - `mutate()` - `group_by()` - `summarise()` - `filter()` - `arrange()` - `if_else()` - `n()` - `sum(..., na.rm = TRUE)` - `.groups = "drop"`

------------------------------------------------------------------------

## `ggplot2`

**Use:** create charts\
**Helps us do:** visualize trends and communicate results clearly

Main functions we used: - `ggplot()` - `aes()` - `geom_line()` - `geom_point()` - `labs()` - `theme_minimal()` - `scale_y_continuous()`

------------------------------------------------------------------------

## `scales`

**Use:** format numbers nicely\
**Helps us do:** show percentages clearly in tables and plots

Main functions we used: - `percent()` - `accuracy = 0.1`

------------------------------------------------------------------------

# One-sentence big picture

-   `shiny` builds the app\
-   `dplyr` prepares the data\
-   `ggplot2` makes the charts\
-   `scales` formats the numbers nicely
