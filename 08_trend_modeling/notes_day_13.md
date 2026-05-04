# Day 13

## Severity 

severity = average claim cost

severity = total_claim_amount / claim_count

If total claim amount = 100,000
and claim count = 20

severity = 100,000 / 20 = 5,000

So each claim costs €5,000 on average

## Severity is noisy

claims are often unstable
one month may have 10 small claims, and
another month may have 9 small claims and 1 huge claim

That one large claim can make severity jump a lot.

So we often smooth the trend.


## Moving average

A moving average smooths noise by averaging nearby periods.

Example: 3-month moving average.

March moving average = average of January, February, March
April moving average = average of February, March, April
May moving average = average of March, April, May

It helps answer:

Is severity really increasing,
or is this just one noisy month?










