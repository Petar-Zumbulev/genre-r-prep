# ============================================================
# 05_export_outputs.R
# Export reporting outputs
# ============================================================

export_insurance_report <- function(metrics_data, file_path) {
  
  openxlsx::write.xlsx(
    x = list(
      "quarterly_metrics" = metrics_data
    ),
    file = file_path,
    overwrite = TRUE
  )
  
  message("Excel report exported to: ", file_path)
}