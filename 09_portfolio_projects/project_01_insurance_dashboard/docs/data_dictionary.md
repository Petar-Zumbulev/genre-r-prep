# Data Dictionary — Insurance Reporting Dashboard

## Main dataset

The main dataset represents monthly insurance claims and premium data.

| Column         | Meaning                   | Example                      |
|----------------|---------------------------|------------------------------|
| `report_date`  | Reporting month/date      | `2024-01-01`                 |
| `line`         | Business line             | `Health`, `Accident`, `Life` |
| `region`       | Region or portfolio group | `North`, `South`, `West`     |
| `claim_count`  | Number of claims          | `52`                         |
| `claim_amount` | Total claim cost          | `125000`                     |
| `premium`      | Premium amount            | `180000`                     |

## Derived columns

| Column           | Meaning                            |
|------------------|------------------------------------|
| `report_month`   | Month extracted from report date   |
| `report_quarter` | Quarter extracted from report date |
| `report_year`    | Year extracted from report date    |
| `severity`       | Average claim cost                 |
| `loss_ratio`     | Claims divided by premium          |

## Important formulas

### Severity

\`\`\`text severity = claim_amount / claim_count
