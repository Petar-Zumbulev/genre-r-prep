---
editor_options: 
  markdown: 
    wrap: 72
---

## Basic Concepts

claim count

total claim amount

severity = average cost per claim

severity = total claim amount / claim count

premium = amount insured person paid for insurance

loss ratio = claims divided by premium

loss ratio = total claim amount / premium

a higher severity means each claim is more expensive

a higher loss ratio means claims are eating up more of the premium

a loss ratio above 1 means claims are greater than premium in that
segment/group

## Real data work often starts by building structure

We're not “analyzing” yet.

First create a clean structure that later analysis can use.

That is actually very realistic.

A lot of analyst work is:

define the unit of observation (feature engineering) create clean
identifiers (feature engineering) create time periods (feature
engineering) join base information create business variables

Only after that do you report or model

## Difference between a master table and a reporting table

master table:

policy_master

One row per policy.

Static information:

policy ID line region

reporting table:

policies

One row per policy per quarter.

Time-based reporting information:

policy ID quarter exposure premium

# Combinations

crossing() is a powerful way to create repeated time records

crossing() creates combinations - used for making observations in each
quarter

## Feature Engineering:

mutate() is how you create useful business variables

Here you used mutate() to create:

year qtr year_quarter exposure premium

## quarter() and year()

These come from lubridate.

They let you turn dates into business reporting periods.

Which line has the highest loss ratio overall? - property

Which quarter looks worst for claims? - Q2

Which region seems riskiest? - West

Does the severity look stable, or does it spike in some quarter? -
Relatively stable, some spikes for health in Q4

# Day 5 Notes

## Main concepts

-   claim count = number of claims
-   severity = average cost per claim
-   premium = money collected
-   loss ratio = claims / premium

## New R ideas today

-   lubridate::year()
-   lubridate::quarter()
-   left_join()
-   coalesce()
-   factor() for correct ordering

## What I learned

-   We often join claim data to premium/policy data
-   Policies with no claims can become NA after a join, and coalesce()
    can turn those into 0
-   Quarters are very important for business reporting
-   Loss ratio is one of the most useful business metrics

## My interpretation of today’s output

-   to create reports which give use useful information, we need to
    first do feature engineering with dates, business metrics such as
    loss ratio, and also use joins because one table doesnt have all the
    information

## What felt confusing

-   Working with the dates and lubridate requires more of my time and
    energy

## What I can now explain aloud

-   severity
-   loss ratio
-   why we use quarters
-   why left_join is useful

## Line-Region Report

Which line-region combination looks worst?

Property - West looks worst because it has the highest loss ratio and
avg. severity

## Day 05 Part 02

Insurance-reporting

Actual job code: reusable, cleaner, and exportable

reporting/tool-building workflow

Real-world analyst code:

cleaner
reusable
easier to explain in an interview
exportable to Excel

which for us means:

turn your reporting logic into functions
create a reusable segment summary function
create reusable plotting functions
export the outputs to Excel


3 big reasons to use a function:

reuse
cleaner code
same logic every time

And that third one is very important in analyst/reporting work



## Day 5 Part 2

### New concepts
- functions make code reusable
- one function can summarise different report views
- group_by(across(all_of(...))) allows dynamic grouping
- .data[[...]] allows dynamic plotting
- openxlsx can export multiple report tables into one Excel workbook

### Why this matters
- this feels more like real analyst code than one long script
- reusable code is easier to explain in interviews
- reusable report functions are useful for quarterly reporting
- Excel export makes the workflow more practical for business users

### What I should be able to explain
- why functions are better than repeating code
- how dynamic grouping works
- how I can create one summary function for different business cuts
- why Excel export is relevant in insurance/reporting workflows














