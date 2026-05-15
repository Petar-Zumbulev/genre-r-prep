# ============================================================
# 03_calculate_metrics.R
# Calculate insurance reporting KPIs
# ============================================================

calculate_insurance_metrics <- function(clean_data) {
  
  metrics <- clean_data %>%
    group_by(report_quarter, line, region) %>%
    summarise(
      claim_count = sum(claim_count, na.rm = TRUE),
      claim_amount = sum(claim_amount, na.rm = TRUE),
      premium = sum(premium, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      severity = claim_amount / claim_count,
      loss_ratio = claim_amount / premium
    )
  
  return(metrics)
}