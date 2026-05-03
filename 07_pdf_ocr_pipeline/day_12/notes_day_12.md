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






