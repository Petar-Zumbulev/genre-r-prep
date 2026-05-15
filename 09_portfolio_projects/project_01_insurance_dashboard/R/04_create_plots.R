# ============================================================
# 04_create_plots.R
# Create reusable plots
# ============================================================

create_severity_plot <- function(metrics_data) {
  
  severity_plot <- metrics_data %>%
    group_by(report_quarter, line) %>%
    summarise(
      severity = sum(claim_amount, na.rm = TRUE) / sum(claim_count, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    ggplot(aes(x = report_quarter, y = severity, group = line, color = line)) +
    geom_line(linewidth = 1) +
    geom_point() +
    scale_y_continuous(labels = scales::euro) +
    labs(
      title = "Severity Trend by Business Line",
      x = "Quarter",
      y = "Average Severity",
      color = "Line"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  return(severity_plot)
}


create_loss_ratio_plot <- function(metrics_data) {
  
  loss_ratio_plot <- metrics_data %>%
    group_by(report_quarter, line) %>%
    summarise(
      claim_amount = sum(claim_amount, na.rm = TRUE),
      premium = sum(premium, na.rm = TRUE),
      loss_ratio = claim_amount / premium,
      .groups = "drop"
    ) %>%
    ggplot(aes(x = report_quarter, y = loss_ratio, group = line, color = line)) +
    geom_line(linewidth = 1) +
    geom_point() +
    scale_y_continuous(labels = scales::percent) +
    labs(
      title = "Loss Ratio Trend by Business Line",
      x = "Quarter",
      y = "Loss Ratio",
      color = "Line"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  return(loss_ratio_plot)
}