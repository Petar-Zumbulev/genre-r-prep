# Day 10 Notes — API and JSON workflow in R

## Big idea
An API is a way for one system to send data to another system.

In practice, the workflow is often:

request -> response -> parse -> clean -> structure -> report

## JSON
JSON is a common data format used by APIs.
It often contains:
- named fields
- lists
- nested objects
- nested arrays

So API data is often not immediately a clean table.

## My job in R
My job is usually to:
1. get the response
2. inspect the structure
3. extract the useful fields
4. turn them into a tibble/data frame
5. clean the result
6. create a reporting output

## Why this matters for Gen Re-style work
In an insurance analytics or reporting workflow, data may come from:
- APIs
- PDFs
- OCR pipelines
- Excel files
- internal systems

The key skill is turning messy or nested input into a structured output that 
can be used in reporting, dashboards, or further analysis.


notice how the .json file has a {[]} nested data structure

also notice the dictionary style, key:value format in the .json file

in the .json file:
the main idea:
the useful table is buried inside a nested object called records



API workflow in R:

1. get the response
2. inspect the structure
3. extract the useful nested part
4. convert it to a tibble
5. clean and enrich it
6. summarise it for reporting
7. export the result









