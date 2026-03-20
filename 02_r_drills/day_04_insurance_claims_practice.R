library(tidyverse)

claims_data <- tibble(
  quarter = c("Q1", "Q1", "Q2", "Q2", "Q3", "Q3", "Q4", "Q4"),
  segment = c("Retail", "Corporate", "Retail", "Corporate",
              "Retail", "Corporate", "Retail", "Corporate"),
  claim_count = c(120, 80, 140, 90, 135, 95, 150, 100),
  claim_amount = c(24000, 22000, 30000, 26000, 29000, 27000, 33000, 31000)
) %>%
  mutate(severity = claim_amount / claim_count)
# this is an already aggregated, synthetic dataset
# Usually I would recieve ungrouped data which looks like individual
# observations, and then I'd group by claim count and segment
print(claims_data)

claims_data %>%
  ggplot(aes(x = quarter, y = severity, fill = segment)) +
  geom_col(position = "dodge") +
  labs(
    title = "Claim Severity by Quarter and Segment",
    x = "Quarter",
    y = "Severity"
  ) +
  theme_minimal()
