# Day 08

## Main Idea: Data in R -> excel output

In real work, analysis often is not finished when the plot looks nice.
It is finished when somebody else can open the file, read it, filter it, and use it


read_excel() 
- read excel into R

openxlsx
- used for writing polished Excel files from R
- main functions:

createWorkbook()
addWorksheet()
writeData()
saveWorkbook()
setColWidths()
freezePane()
createStyle()
addStyle()


Whenever you create an R object, create it in a project-level data folder

The data should always be in a project-level data folder for easier access

Do not save it under another folder because that makes the R object and/or 
data retrieval more difficult


# Day 8 — Excel integration and export-ready reporting

## Main idea
Today I learned how to turn R analysis into business-ready Excel output.

## Why this matters
In real work, analysis is often not finished when the table looks good in R.
It is finished when someone else can open the file, read it, filter it, and use it.

## Main packages
- `readxl`: read Excel files into R
- `openxlsx`: write polished Excel files from R

## Main functions
- `read_excel()`
- `createWorkbook()`
- `addWorksheet()`
- `writeData()`
- `saveWorkbook()`
- `setColWidths()`
- `freezePane()`
- `createStyle()`
- `addStyle()`

## Shiny concept
`downloadHandler()` is Shiny’s file export mechanism.
It defines the file name and how the file is created when the user clicks download.

## Business logic reminder
Do not average averages.
Recompute summary metrics from totals.

Examples:
- average severity = total claim amount / total claim count
- loss ratio = total claim amount / total premium

## Day 8 outcome
I can now:
- export multi-sheet Excel workbooks from R
- create business-friendly summary tables
- connect Shiny outputs to downloadable Excel files




## My 2 Files

day_08_excel_reporting.R creates an excel workbook using aggregate data and a table

app.R now includes a download button in the UI section and a download handler in the
server section and with these two functions the app now has a download button that
gives you an excel workbook, using the logic we built in day_08_excel_reporting.R