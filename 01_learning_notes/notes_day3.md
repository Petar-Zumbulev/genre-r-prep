# Day 3 Notes


better grasp on mutate()

feature engineering

have to practice if_else() and case_when()


## Multiple Groupings

you can have multiple groups in group_by()

group_by(manufacturer, year)

grouping changes the level of analysis


## What mutate does
mutate() creates new columns while keeping the existing table.

## What group_by does
group_by() creates groups inside the data, but does not summarise by itself.

## What summarise does
summarise() collapses each group into one output row.

## Why grouped analysis matters
Grouped analysis changes the level of analysis.
Instead of looking at each row individually, we look at averages or totals for categories.

## if_else vs case_when
if_else() is good for one simple condition.
case_when() is better for multiple categories.

## Most important idea from today
Creating new columns and grouping data are core analyst skills because they turn raw data into useful business information.