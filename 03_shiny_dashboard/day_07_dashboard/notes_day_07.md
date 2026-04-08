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