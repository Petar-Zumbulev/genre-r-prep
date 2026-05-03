# Day 12

Parsing = taking messy/unstructured text and extracting structured fields from it.


## The Validation Layer of parsing:

Need to check:

Did every row parse correctly?
Are any amounts missing?
Are any dates wrong?
Are there strange statuses?
Are there negative claim amounts?



# Day 12 — Unstructured Claims Text to Validated Report

## Main idea

Today I learned how to turn messy unstructured claim text into a structured insurance report.

Workflow:

messy text -> parsed table -> validation checks -> KPI table -> Excel report

## What parsing means

Parsing means extracting structured information from messy text.

Example raw line:

2024-01-15 | Claim C001 | Line: Health | Region: North | Amount: 1240.50 | Status: Paid

Parsed output:

- claim_date
- claim_id
- business_line
- region
- claim_amount
- status

The function `parse_claim_lines()` is not a built-in R function. It is a custom function we created.

## Why validation is important

Parsing can fail.

Common problems:

- bad line structure
- missing amount
- invalid amount
- negative claim amount
- unexpected status
- missing date

That is why the workflow creates:

- `validation_issue`
- `is_valid`

This lets us separate clean rows from problematic rows.

## Important insurance KPIs

### Claim count

Number of claims in a group.

### Total claim amount

Total cost of claims.

### Average severity

Average cost per claim.

Formula:

average severity = total claim amount / claim count

### Premium

The amount charged to cover expected losses and costs.

### Loss ratio

Formula:

loss ratio = total claim amount / premium

Interpretation:

- 0.60 means claims used 60% of premium
- 1.00 means claims used 100% of premium
- above 1.00 means claims exceeded premium

## Key R functions used today

- `str_match()` extracts parts of text using regex
- `ymd()` converts text to dates
- `case_when()` creates validation rules
- `group_by()` groups data
- `summarise()` calculates KPIs
- `createWorkbook()` creates an Excel workbook
- `writeData()` writes tables to Excel sheets
- `saveWorkbook()` saves the Excel file

## Main lesson

A real analyst workflow is not just about calculating numbers.

A better workflow is:

1. Import or receive messy data
2. Parse it
3. Validate it
4. Separate good rows from bad rows
5. Calculate business KPIs
6. Export a clear report



## Theory:

frequency = claim_count / exposure
severity = total_claim_amount / claim_count
pure_premium = frequency * severity
loss_ratio = total_claim_amount / premium
inflation_adjusted_amount = claim_amount * inflation_factor






## Insurance business logic examples

Today I added insurance business metric examples to the parsed claims workflow.

### Exposure

Exposure means the amount of risk being covered.

Examples:

- in motor insurance: vehicle-years
- in health insurance: member-months or insured lives
- in property insurance: insured property-years

Exposure matters because 10 claims from 100 policies is very different from 10 claims from 10,000 policies.

### Frequency

Formula:

frequency = claim_count / exposure

Meaning:

Frequency tells us how often claims happen relative to the amount of exposure.

Example:

If there are 20 claims and 1,000 exposure units:

frequency = 20 / 1000 = 0.02

This means 0.02 claims per exposure unit.

### Severity

Formula:

severity = total_claim_amount / claim_count

Meaning:

Severity tells us the average cost per claim.

Example:

If total claims are 50,000 and there are 25 claims:

severity = 50,000 / 25 = 2,000

The average claim costs 2,000.

### Pure premium

Formula:

pure_premium = frequency * severity

Meaning:

Pure premium is the expected claim cost per exposure unit.

It combines:

- how often claims happen
- how expensive claims are when they happen

Example:

frequency = 0.02  
severity = 2,000  

pure_premium = 0.02 * 2,000 = 40

So the expected claim cost per exposure unit is 40.

### Loss ratio

Formula:

loss_ratio = total_claim_amount / premium

Meaning:

Loss ratio shows how much of the premium is used by claims.

Example:

If total claims are 80,000 and premium is 100,000:

loss_ratio = 80,000 / 100,000 = 0.80

This means claims used 80% of the premium.

### Inflation-adjusted amount

Formula:

inflation_adjusted_amount = total_claim_amount * inflation_factor

Meaning:

Inflation adjustment shows what claim costs look like after accounting for rising prices.

Example:

If total claims are 10,000 and inflation factor is 1.04:

inflation_adjusted_amount = 10,000 * 1.04 = 10,400

So after 4% inflation, the adjusted amount is 10,400.

## Main takeaway

The core insurance logic is:

frequency = how often claims happen  
severity = how expensive claims are  
pure premium = expected claim cost per exposure unit  
loss ratio = claims compared to premium  
inflation adjustment = claim cost after price increases  

These are simple formulas, but they are very important for insurance reporting and pricing logic.



