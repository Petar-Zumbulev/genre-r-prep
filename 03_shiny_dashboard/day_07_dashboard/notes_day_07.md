# notes_day7

## Main goal
Today I learned how to turn a prepared reporting table into a small Shiny dashboard.

## Main concepts
- reactive filtering
- KPI summaries
- trend plots
- detail tables
- one filtered data object feeding many outputs

## Most important analytical lesson
When filters change, I should usually recompute metrics from totals.
Example:
- better: total_claim_amount / claim_count
- worse: mean(avg_severity)

## Main reactive objects
- filtered_data(): base filtered rows
- kpi_data(): one-row KPI summary
- trend_data(): grouped trend over quarter
- detail_data(): grouped table for inspection

## Business logic
A dashboard should answer:
1. what is happening now?
2. how is it changing over time?
3. what details explain the summary?

## Why this matters for the role
This matches R reporting + Shiny + insurance metric workflows.



# Shiny dashboard mental model

## The whole app logic in one flow

1. **Load data**
   - Start with the base dataset.
   - Example:
     app_data

2. **Read user choices**
   - The app checks what the user selected in the filters.
   - Examples:
     input$line
     input$region
     input$quarter

3. **Build filtered data**
   - Use the user choices to keep only the relevant rows.
   - Example:
     filtered_data()
   - This is the current working dataset for the app.

4. **Build summary layers**
   - From the filtered data, create the different business views:
   - `kpi_data()` = top summary numbers
   - `trend_data()` = trend over time
   - `detail_data()` = detailed table

5. **Send results to the screen**
   - Display the results in the UI.
   - Examples:
     renderText()
     renderPlot()
     renderDT()

## One-line memory trick

**Load data -> read inputs -> filter data -> calculate summaries -> display outputs**

## What each part means in simple words

- `app_data` = the full starting dataset
- `input$...` = what the user wants to see
- `filtered_data()` = the rows that match the user’s choice
- `kpi_data()`, `trend_data()`, `detail_data()` = the business results built from the filtered rows
- `render...()` = the functions that show those results on the screen

## Big idea

A Shiny app is not random code.

It is a pipeline:

- start with data
- react to user choices
- recalculate the right summaries
- show them clearly

That is the core dashboard logic.






## What I had most trouble with: Average-of-averages trap


Remember: “Do not average averages — recompute from totals.”


# Average-of-averages trap

## Main idea

Sometimes a table already contains group-level averages.

Example:
- one row for Motor
- one row for Property
- each row already has its own average severity

Then later, when I filter or combine groups, it is tempting to do:

mean(avg_severity)

But that is often wrong.

## Why it is wrong

Because not every row represents the same amount of underlying data.

Example:
- one row may represent 2 claims
- another row may represent 100 claims

If I take the simple mean of the two group averages, I give both rows equal weight.

That is usually not correct.

## Correct thinking

When combining groups, I should usually go back to the underlying totals and recompute the metric.

For severity, the correct logic is:

severity = total_claim_amount / claim_count

So if I combine rows, I should usually calculate:

sum(total_claim_amount) / sum(claim_count)

not:

mean(avg_severity)

## Why totals matter

Totals preserve the real weight behind the data.

A row with 100 claims should influence the final result much more than a row with only 2 claims.

That is why recomputing from totals is usually the correct business logic.

## Easy example

Suppose I have:

- Motor: 2 claims, 200 total claim amount, avg severity = 100
- Property: 100 claims, 20000 total claim amount, avg severity = 200

Wrong:
mean(c(100, 200)) = 150

Correct:
(200 + 20000) / (2 + 100) = 198.04

So the simple average gives the wrong answer because it ignores the different claim counts.

## The question I should always ask

Before averaging averages, ask:

"Do these rows represent the same amount of underlying data?"

If yes, averaging averages may be okay.

If no, it is usually wrong, and I should recompute from totals.

## Why this matters in dashboards and reporting

In Shiny apps, reports, and grouped summary tables, rows often have very different sizes:
- different claim counts
- different exposures
- different premium volumes

So when filters change, I should usually recompute the metric from totals inside the filtered subset.

## Memory phrase

Average-of-averages trap

## Rule to remember

Do not average averages — recompute from totals.

## What I mean when I say this later

If I say "average-of-averages trap," I mean:

I have a grouped table with precomputed averages, and I must be careful not to combine those averages with a simple mean when the groups have different weights or sizes.


Do not average averages. Recompute the overall average from the underlying totals, because the groups may have different numbers of observations.







# Shiny app execution context and file.path notes

## 1. Running the whole script vs clicking Run App

### Running the whole script
When I do Ctrl + A and then Ctrl + Enter, R runs the script inside my **current R session**.

That means it uses:
- the current working directory
- the current Global Environment
- any objects that are already loaded
- any packages I may already have loaded

So the script may work partly because my session is already prepared.

### Clicking Run App
When I click **Run App**, Shiny tries to launch the app more like a **standalone app**.

That means the app should be **self-contained**:
- it should load its own packages
- it should load its own data
- it should not depend on objects already sitting in the Global Environment
- its file paths should work from the app's own folder context

### Main lesson
A Shiny app should work after:
1. restarting R
2. opening only `app.R`
3. clicking **Run App**

If it only works when I manually run the whole script first, then the app is probably still depending on my current session setup.

---

## 2. Why `file.path()` is useful

### What it does
`file.path()` takes separate path pieces and joins them into one file path.

Example:

```r
file.path("data", "dashboard_metrics.rds")


This builds a path like:

"data/dashboard_metrics.rds"


It is useful because:

the path pieces are clearer
R handles the path separator for me
there is less risk of missing a slash or typing a wrong one
it is easier to read when a path has many parts
it is more portable across systems
Why it is more portable

Different operating systems can handle file paths a bit differently.

With file.path(), I give R the pieces of the path, and R builds the path in a 
system-friendly way. That makes the code more likely to work cleanly across different machines and setups.



