library(tidyverse)

claim_amounts <- c(1200, 3400, 800, 1500, 4200)
segments <- c("Retail", "Corporate", "Retail", "SME", "Corporate")
is_large_claim <- claim_amounts > 2000

claim_info <- list(
  claim_amounts = claim_amounts,
  segments = segments,
  is_large_claim = is_large_claim
)

claims_df <- tibble(
  claim_id = 1:5,
  segment = segments,
  claim_amount = claim_amounts,
  is_large_claim = is_large_claim
)

claims_df

mean(claims_df$claim_amount)
max(claims_df$claim_amount)

claims_df[claims_df$claim_amount > 1500, ]

claims_df %>%
  filter(segment == "Retail")

claims_df %>%
  mutate(claim_amount_eur_k = claim_amount / 1000)

claims_df %>%
  arrange(desc(claim_amount))

claims_df %>%
  group_by(segment) %>%
  summarise(
    n_claims = n(),
    avg_claim = mean(claim_amount),
    total_claim = sum(claim_amount)
  )
