# Project Plan — Insurance Reporting Dashboard

## Project goal

The goal is to build a practical R/Shiny dashboard for insurance reporting.

The dashboard should take claims and premium data, clean it, calculate important insurance KPIs, visualize trends, and allow the user to export reporting outputs.

## Target user

The target user is an analyst, manager, or business stakeholder who wants to monitor insurance portfolio performance.

## Input data

The planned input data will contain:

- report date
- business line
- region
- claim count
- claim amount
- premium

Optional later columns:

- inflation index
- policy count
- exposure
- segment
- product

## Data flow

The planned data flow is:

```text
raw data
→ clean data
→ calculate KPIs
→ create plots
→ show results in Shiny
→ export Excel report


