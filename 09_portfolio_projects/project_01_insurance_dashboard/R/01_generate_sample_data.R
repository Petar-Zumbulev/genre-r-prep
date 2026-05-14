# ============================================================
# 01_generate_sample_data.R
# Create synthetic insurance data
# ============================================================

generate_sample_insurance_data <- function() {
  
  set.seed(123)
  
  months <- seq.Date(
    from = as.Date("2022-01-01"),
    to = as.Date("2024-12-01"),
    by = "month"
  )
  
  sample_data <- tidyr::expand_grid(
    report_date = months,
    line = c("Health", "Accident", "Life"),
    region = c("North", "South", "West")
  ) %>%
    mutate(
      claim_count = case_when(
        line == "Health" ~ rpois(n(), lambda = 80),
        line == "Accident" ~ rpois(n(), lambda = 45),
        line == "Life" ~ rpois(n(), lambda = 20),
        TRUE ~ rpois(n(), lambda = 40)
      ),
      
      avg_claim_size = case_when(
        line == "Health" ~ 1200,
        line == "Accident" ~ 2500,
        line == "Life" ~ 7000,
        TRUE ~ 2000
      ),
      
      claim_amount = claim_count * avg_claim_size * runif(n(), 0.75, 1.25),
      
      premium = claim_amount / runif(n(), 0.55, 0.85)
    ) %>%
    select(
      report_date,
      line,
      region,
      claim_count,
      claim_amount,
      premium
    )
  
  return(sample_data)
}