---
editor_options: 
  markdown: 
    wrap: 72
---

# Day 13

## Severity

severity = average claim cost

severity = total_claim_amount / claim_count

If total claim amount = 100,000 and claim count = 20

severity = 100,000 / 20 = 5,000

So each claim costs €5,000 on average

## Severity is noisy

claims are often unstable one month may have 10 small claims, and
another month may have 9 small claims and 1 huge claim

That one large claim can make severity jump a lot.

So we often smooth the trend.

## Moving average

A moving average smooths noise by averaging nearby periods.

Example: 3-month moving average.

March moving average = average of January, February, March April moving
average = average of February, March, April May moving average = average
of March, April, May

It helps answer:

Is severity really increasing, or is this just one noisy month?

## Linear trend

A linear model says:

severity = starting level + monthly change

Example interpretation:

Severity increases by about €75 per month.

## Log trend

A log model says:

log(severity) = starting level + trend over time

This is useful because insurance costs often grow by percentages.

Example interpretation:

Severity is increasing by about 1.2% per month.

This is usually more realistic than saying the increase is always the
same euro amount.

# Trend Modeling Basics

## Main idea

Today I learned how to analyze claim severity trends over time.

The workflow is:

1.  Start with monthly claims data.
2.  Calculate severity.
3.  Smooth noisy severity with a moving average.
4.  Fit a trend model.
5.  Interpret the result in business language.
6.  Export the result for reporting.

## Key insurance metrics

### Claim count

Number of claims in a period.

### Claim amount

Total cost of claims in a period.

### Severity

Average claim cost.

\`\`\`r severity = claim_amount / claim_count

built a small R workflow for claim severity trend analysis. I created
monthly claims data, calculated severity, smoothed the noisy monthly
pattern with moving averages, fitted both a linear and log trend model,
and exported the results to Excel. The main business idea is to separate
random claim volatility from the underlying cost trend, which is
important for reporting, premium logic, and inflation discussions.



We already calculated:

severity = claim_amount / claim_count

But raw severity can increase for two reasons:

1. Claims are becoming truly more expensive.
2. General inflation / medical inflation is pushing all costs upward.

So Drill 3 asks:

After adjusting for inflation, are claim costs still increasing?

Imagine severity goes from:

€3,000 → €3,300

That looks like a 10% increase.

But if inflation was also 10%, then maybe claims are not really becoming worse. 
They are just following inflation.

So inflation-adjusted severity helps answer:

Is the portfolio actually getting worse,
or are costs just rising because of inflation?


Raw severity answers:

How expensive are claims in current money?

Inflation-adjusted severity answers:

How expensive are claims after removing inflation effects?

^^ this is an important distinction




Drill 4 — Premium per claim vs severity

What this means:

Create:

premium_per_claim = premium_amount / claim_count

This tells you:

How much premium is available per claim on average?

Then compare it to:

severity = claim_amount / claim_count

Severity tells you:

How much each claim costs on average.

So now you compare:

premium per claim vs average claim cost
Why this is relevant

This is very insurance-business relevant.

If severity rises faster than premium per claim, the insurer may have a problem.

Example:

Average claim cost:     €4,000
Premium per claim:      €3,500

That means claims are more expensive than the premium available per claim.

This connects directly to:

pricing
loss ratio
premium adequacy
portfolio monitoring
What you should remember

The core business question is:

Are premiums keeping up with claims?

If not, the loss ratio gets worse.




