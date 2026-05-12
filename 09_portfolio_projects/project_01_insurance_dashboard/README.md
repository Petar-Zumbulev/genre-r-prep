# Insurance Reporting Dashboard in R/Shiny

## Project overview

This project simulates a practical insurance analytics workflow in R.

The goal is to build an interactive Shiny dashboard that takes claims and premium data, cleans it, calculates important insurance KPIs, visualizes business trends, and exports reporting outputs.

This project is designed as a portfolio project for an R-based analyst/coder role in insurance or reinsurance.

## Main business problem

Insurance analysts often need to understand how claim costs, premium, severity, and loss ratio develop over time.

This dashboard helps answer questions such as:

- How many claims were reported?
- How much premium was earned?
- What is the average claim severity?
- Which business line or region has the highest loss ratio?
- How are claims and premium changing over time?
- Which segments should be monitored more closely?

## Planned features

The dashboard will include:

- synthetic insurance-style claims and premium data
- data cleaning workflow in R
- quarterly reporting logic
- KPI cards
- line and region filters
- severity trend chart
- loss ratio trend chart
- summary table
- Excel export

## Main KPIs

The main KPIs are:

- claim count
- total claim amount
- total premium
- average severity
- loss ratio
- quarterly trend

## Tools used

- R
- tidyverse
- dplyr
- lubridate
- ggplot2
- Shiny
- DT
- openxlsx

## Project structure

```text
project_1_insurance_dashboard/
│
├── app.R
├── README.md
│
├── R/
│   ├── 00_packages.R
│   ├── 01_generate_sample_data.R
│   ├── 02_clean_data.R
│   ├── 03_calculate_metrics.R
│   ├── 04_create_plots.R
│   └── 05_export_outputs.R
│
├── data_raw/
├── data_processed/
├── outputs/
│   ├── figures/
│   └── excel/
├── docs/
│   ├── project_plan.md
│   └── data_dictionary.md
└── www/



Why this project is relevant

This project is relevant for insurance analytics because it combines:

data cleaning
reporting
business KPIs
Shiny dashboard development
Excel export
insurance interpretation

It reflects practical analyst work rather than purely theoretical actuarial modeling.