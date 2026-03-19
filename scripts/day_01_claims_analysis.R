library(tidyverse)
library(lubridate)

claims_raw <- tibble(
  claim_id = 1:10,
  date = c("2025-01-15", "2025-01-20", "2025-02-05", "2025-02-18", "2025-03-02",
           "2025-03-10", "2025-03-14", "2025-04-01", "2025-04-08", "2025-04-20"),
  segment = c("Retail", "Corporate", "Retail", "SME", "Corporate",
              "Retail", "SME", "Corporate", "Retail", "SME"),
  claim_amount = c(1200, 3400, 800, NA, 4200, 1500, 2100, 3900, 1100, 2500),
  premium = c(3000, 7000, 2800, 3200, 7500, 3100, 3300, 7200, 2950, 3400)
)

claims_clean <- claims_raw %>%
  mutate(
    date = ymd(date),
    quarter = quarter(date, with_year = TRUE),
    claim_amount = replace_na(claim_amount, median(claim_amount, na.rm = TRUE))
  )

summary_table <- claims_clean %>%
  group_by(segment, quarter) %>%
  summarise(
    n_claims = n(),
    total_claim_amount = sum(claim_amount),
    avg_claim_amount = mean(claim_amount),
    total_premium = sum(premium),
    loss_ratio = total_claim_amount / total_premium,
    .groups = "drop"
  )

print(summary_table)

plot1 <- claims_clean %>%
  ggplot(aes(x = segment, y = claim_amount)) +
  geom_boxplot() +
  labs(
    title = "Claim Amount by Segment",
    x = "Segment",
    y = "Claim Amount"
  )

plot2 <- summary_table %>%
  ggplot(aes(x = factor(quarter), y = loss_ratio, fill = segment)) +
  geom_col(position = "dodge") +
  labs(
    title = "Loss Ratio by Segment and Quarter",
    x = "Quarter",
    y = "Loss Ratio"
  )

print(plot1)
print(plot2)
