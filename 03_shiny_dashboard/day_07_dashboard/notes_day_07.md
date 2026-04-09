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