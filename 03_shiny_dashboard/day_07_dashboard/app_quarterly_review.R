library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(scales)
library(openxlsx)


# -----------------------------
# Insurance Quarterly Portfolio Review App
#
# This app is a more business-oriented version of the basic dashboard.
#
# It allows the user to:
# - filter the portfolio by business line, region, and reporting quarter
# - review top-level KPIs
# - read an executive summary
# - analyze trends dynamically
# - identify high-risk segments
# - test a simple inflation / premium scenario
# - inspect detailed results
# - export an Excel report
#
# Required input data:
# data/dashboard_metrics.rds
#
# Expected columns:
# line
# region
# quarter
# claim_count
# total_claim_amount
# total_premium
# -----------------------------


# Load prepared dashboard data
app_data <- readRDS(file.path("data", "dashboard_metrics.rds"))


# -----------------------------
# UI
# -----------------------------

ui <- fluidPage(
  titlePanel("Insurance Quarterly Portfolio Review"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Portfolio Filters"),
      
      selectInput(
        inputId = "line",
        label = "Business Line",
        choices = c("All", sort(unique(app_data$line))),
        selected = "All"
      ),
      
      selectInput(
        inputId = "region",
        label = "Region",
        choices = c("All", sort(unique(app_data$region))),
        selected = "All"
      ),
      
      selectInput(
        inputId = "quarter",
        label = "Reporting Quarter",
        choices = c("All", sort(unique(app_data$quarter))),
        selected = "All"
      ),
      
      hr(),
      
      h4("Trend Settings"),
      
      selectInput(
        inputId = "trend_metric",
        label = "Trend Metric",
        choices = c(
          "Average Severity" = "avg_severity",
          "Claim Count" = "claim_count",
          "Claims Cost" = "total_claim_amount",
          "Loss Ratio" = "loss_ratio",
          "Premium" = "total_premium"
        ),
        selected = "loss_ratio"
      ),
      
      hr(),
      
      h4("Scenario Settings"),
      
      sliderInput(
        inputId = "inflation_scenario",
        label = "Medical Inflation Scenario",
        min = 0,
        max = 20,
        value = 5,
        step = 1,
        post = "%"
      ),
      
      hr(),
      
      downloadButton(
        outputId = "download_excel",
        label = "Download Excel Report"
      )
    ),
    
    mainPanel(
      fluidRow(
        column(
          3,
          wellPanel(
            h4("Claim Count"),
            textOutput("claim_count_value")
          )
        ),
        column(
          3,
          wellPanel(
            h4("Total Claims Cost"),
            textOutput("claim_amount_value")
          )
        ),
        column(
          3,
          wellPanel(
            h4("Average Severity"),
            textOutput("avg_severity_value")
          )
        ),
        column(
          3,
          wellPanel(
            h4("Loss Ratio"),
            textOutput("loss_ratio_value")
          )
        )
      ),
      
      br(),
      
      tabsetPanel(
        tabPanel(
          "Executive Summary",
          br(),
          h3("Quarterly Portfolio Summary"),
          verbatimTextOutput("executive_summary")
        ),
        
        tabPanel(
          "Trend Analysis",
          br(),
          plotOutput("dynamic_trend_plot", height = "400px")
        ),
        
        tabPanel(
          "Portfolio Heatmap",
          br(),
          plotOutput("portfolio_heatmap", height = "450px")
        ),
        
        tabPanel(
          "Risk Flags",
          br(),
          DTOutput("risk_flags_table")
        ),
        
        tabPanel(
          "Scenario Analysis",
          br(),
          h3("Inflation and Premium Scenario"),
          p("This table estimates how claims cost and required premium change under the selected inflation scenario."),
          DTOutput("scenario_table")
        ),
        
        tabPanel(
          "Detailed Results",
          br(),
          DTOutput("detail_table")
        )
      )
    )
  )
)


# -----------------------------
# SERVER
# -----------------------------

server <- function(input, output, session) {
  
  # -----------------------------
  # Filter layer
  # -----------------------------
  # This is the main reactive dataset.
  # It updates whenever the user changes a filter.
  
  filtered_data <- reactive({
    df <- app_data
    
    if (input$line != "All") {
      df <- df %>% filter(line == input$line)
    }
    
    if (input$region != "All") {
      df <- df %>% filter(region == input$region)
    }
    
    if (input$quarter != "All") {
      df <- df %>% filter(quarter == input$quarter)
    }
    
    df
  })
  
  
  # -----------------------------
  # KPI layer
  # -----------------------------
  # This collapses the filtered data into top-level business KPIs.
  
  kpi_data <- reactive({
    filtered_data() %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        total_premium = sum(total_premium, na.rm = TRUE)
      ) %>%
      mutate(
        avg_severity = if_else(
          claim_count > 0,
          total_claim_amount / claim_count,
          NA_real_
        ),
        loss_ratio = if_else(
          total_premium > 0,
          total_claim_amount / total_premium,
          NA_real_
        )
      )
  })
  
  
  # -----------------------------
  # Trend layer
  # -----------------------------
  # This creates quarterly trend data for plots.
  
  trend_data <- reactive({
    filtered_data() %>%
      group_by(quarter) %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        total_premium = sum(total_premium, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        avg_severity = if_else(
          claim_count > 0,
          total_claim_amount / claim_count,
          NA_real_
        ),
        loss_ratio = if_else(
          total_premium > 0,
          total_claim_amount / total_premium,
          NA_real_
        )
      ) %>%
      arrange(quarter)
  })
  
  
  # -----------------------------
  # Detail layer
  # -----------------------------
  # This creates a grouped detail table for business review.
  
  detail_data <- reactive({
    filtered_data() %>%
      group_by(line, region, quarter) %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        total_premium = sum(total_premium, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        avg_severity = if_else(
          claim_count > 0,
          total_claim_amount / claim_count,
          NA_real_
        ),
        loss_ratio = if_else(
          total_premium > 0,
          total_claim_amount / total_premium,
          NA_real_
        )
      ) %>%
      arrange(desc(total_claim_amount))
  })
  
  
  # -----------------------------
  # Heatmap data
  # -----------------------------
  # This groups by business line and region to identify portfolio hotspots.
  
  heatmap_data <- reactive({
    filtered_data() %>%
      group_by(line, region) %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        total_premium = sum(total_premium, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        avg_severity = if_else(
          claim_count > 0,
          total_claim_amount / claim_count,
          NA_real_
        ),
        loss_ratio = if_else(
          total_premium > 0,
          total_claim_amount / total_premium,
          NA_real_
        )
      )
  })
  
  
  # -----------------------------
  # Risk flag logic
  # -----------------------------
  # This identifies segments that need business review.
  #
  # Example logic:
  # - Critical: loss ratio >= 100%
  # - Warning: loss ratio >= 80%
  # - Review: severity is in the top 25% of selected data
  # -----------------------------
  
  risk_flags <- reactive({
    df <- detail_data()
    
    if (nrow(df) == 0) {
      return(df)
    }
    
    severity_values <- df$avg_severity[!is.na(df$avg_severity)]
    
    severity_threshold <- if (length(severity_values) > 0) {
      quantile(severity_values, 0.75, na.rm = TRUE, names = FALSE)
    } else {
      NA_real_
    }
    
    df %>%
      mutate(
        risk_flag = case_when(
          !is.na(loss_ratio) & loss_ratio >= 1 ~ "Critical: claims exceed premium",
          !is.na(loss_ratio) & loss_ratio >= 0.8 ~ "Warning: high loss ratio",
          !is.na(avg_severity) & !is.na(severity_threshold) & avg_severity >= severity_threshold ~ "Review: high severity",
          TRUE ~ "Normal"
        )
      ) %>%
      filter(risk_flag != "Normal") %>%
      arrange(desc(loss_ratio), desc(avg_severity))
  })
  
  
  # -----------------------------
  # Scenario analysis
  # -----------------------------
  # This applies the selected inflation scenario to claims cost.
  #
  # Example:
  # If inflation_scenario = 5,
  # then selected_inflation = 0.05
  #
  # Required premium is calculated using a target loss ratio of 75%.
  # This is simplified business logic for portfolio review.
  # -----------------------------
  
  scenario_data <- reactive({
    selected_inflation <- input$inflation_scenario / 100
    
    detail_data() %>%
      mutate(
        inflation_scenario = selected_inflation,
        inflation_adjusted_claim_amount = total_claim_amount * (1 + selected_inflation),
        required_premium_for_75_lr = inflation_adjusted_claim_amount / 0.75,
        premium_gap = required_premium_for_75_lr - total_premium
      )
  })
  
  
  # -----------------------------
  # KPI outputs
  # -----------------------------
  
  output$claim_count_value <- renderText({
    comma(kpi_data()$claim_count)
  })
  
  output$claim_amount_value <- renderText({
    dollar(kpi_data()$total_claim_amount)
  })
  
  output$avg_severity_value <- renderText({
    dollar(kpi_data()$avg_severity)
  })
  
  output$loss_ratio_value <- renderText({
    percent(kpi_data()$loss_ratio, accuracy = 0.1)
  })
  
  
  # -----------------------------
  # Executive summary
  # -----------------------------
  # This turns KPI values into a short business interpretation.
  
  output$executive_summary <- renderText({
    kpis <- kpi_data()
    
    loss_ratio_comment <- ifelse(
      is.na(kpis$loss_ratio),
      "Loss ratio cannot be calculated because premium is missing or zero.",
      ifelse(
        kpis$loss_ratio >= 1,
        "The selected portfolio slice is critical because claims exceed premium.",
        ifelse(
          kpis$loss_ratio >= 0.8,
          "The selected portfolio slice shows a high loss ratio and should be reviewed more closely.",
          "The selected portfolio slice appears to be within a manageable loss ratio range."
        )
      )
    )
    
    paste0(
      "Portfolio overview for the selected filters:\n\n",
      "- Total claims: ", comma(kpis$claim_count), "\n",
      "- Total claims cost: ", dollar(kpis$total_claim_amount), "\n",
      "- Average cost per claim: ", dollar(kpis$avg_severity), "\n",
      "- Total premium: ", dollar(kpis$total_premium), "\n",
      "- Loss ratio: ", percent(kpis$loss_ratio, accuracy = 0.1), "\n\n",
      "Business interpretation:\n",
      loss_ratio_comment, "\n\n",
      "Analyst note:\n",
      "Use the Risk Flags tab to identify segments with unusually high loss ratios or severity levels. ",
      "Use the Scenario Analysis tab to estimate how medical inflation could affect required premium."
    )
  })
  
  
  # -----------------------------
  # Dynamic trend plot
  # -----------------------------
  # This plot changes based on input$trend_metric.
  
  output$dynamic_trend_plot <- renderPlot({
    validate(
      need(nrow(trend_data()) > 0, "No data available for this filter selection.")
    )
    
    metric_labels <- c(
      avg_severity = "Average Cost per Claim",
      claim_count = "Claim Count",
      total_claim_amount = "Total Claims Cost",
      loss_ratio = "Loss Ratio",
      total_premium = "Premium"
    )
    
    selected_metric <- input$trend_metric
    
    p <- ggplot(
      trend_data(),
      aes(x = quarter, y = .data[[selected_metric]], group = 1)
    ) +
      geom_line() +
      geom_point() +
      labs(
        title = paste(metric_labels[[selected_metric]], "by Quarter"),
        x = "Reporting Quarter",
        y = metric_labels[[selected_metric]]
      ) +
      theme_minimal()
    
    if (selected_metric %in% c("avg_severity", "total_claim_amount", "total_premium")) {
      p <- p + scale_y_continuous(labels = dollar)
    }
    
    if (selected_metric == "loss_ratio") {
      p <- p + scale_y_continuous(labels = percent)
    }
    
    if (selected_metric == "claim_count") {
      p <- p + scale_y_continuous(labels = comma)
    }
    
    p
  })
  
  
  # -----------------------------
  # Portfolio heatmap
  # -----------------------------
  # This shows where loss ratio is highest across business line and region.
  
  output$portfolio_heatmap <- renderPlot({
    validate(
      need(nrow(heatmap_data()) > 0, "No data available for this filter selection.")
    )
    
    ggplot(
      heatmap_data(),
      aes(x = region, y = line, fill = loss_ratio)
    ) +
      geom_tile() +
      geom_text(
        aes(label = percent(loss_ratio, accuracy = 0.1)),
        size = 4
      ) +
      scale_fill_continuous(labels = percent) +
      labs(
        title = "Loss Ratio Heatmap by Business Line and Region",
        x = "Region",
        y = "Business Line",
        fill = "Loss Ratio"
      ) +
      theme_minimal()
  })
  
  
  # -----------------------------
  # Risk flags table
  # -----------------------------
  
  output$risk_flags_table <- renderDT({
    risk_flags() %>%
      mutate(
        `Total Claims Cost` = dollar(total_claim_amount),
        Premium = dollar(total_premium),
        `Avg Cost per Claim` = dollar(avg_severity),
        `Loss Ratio` = percent(loss_ratio, accuracy = 0.1)
      ) %>%
      select(
        line,
        region,
        quarter,
        claim_count,
        `Total Claims Cost`,
        Premium,
        `Avg Cost per Claim`,
        `Loss Ratio`,
        risk_flag
      ) %>%
      rename(
        `Business Line` = line,
        Region = region,
        `Reporting Quarter` = quarter,
        Claims = claim_count,
        `Risk Flag` = risk_flag
      ) %>%
      datatable(
        options = list(pageLength = 8),
        rownames = FALSE
      )
  })
  
  
  # -----------------------------
  # Scenario analysis table
  # -----------------------------
  
  output$scenario_table <- renderDT({
    scenario_data() %>%
      mutate(
        `Inflation Scenario` = percent(inflation_scenario, accuracy = 0.1),
        `Current Claims Cost` = dollar(total_claim_amount),
        `Inflation Adjusted Claims Cost` = dollar(inflation_adjusted_claim_amount),
        `Current Premium` = dollar(total_premium),
        `Required Premium for 75% LR` = dollar(required_premium_for_75_lr),
        `Premium Gap` = dollar(premium_gap),
        `Current Loss Ratio` = percent(loss_ratio, accuracy = 0.1)
      ) %>%
      select(
        line,
        region,
        quarter,
        `Inflation Scenario`,
        `Current Claims Cost`,
        `Inflation Adjusted Claims Cost`,
        `Current Premium`,
        `Required Premium for 75% LR`,
        `Premium Gap`,
        `Current Loss Ratio`
      ) %>%
      rename(
        `Business Line` = line,
        Region = region,
        `Reporting Quarter` = quarter
      ) %>%
      datatable(
        options = list(pageLength = 8),
        rownames = FALSE
      )
  })
  
  
  # -----------------------------
  # Detailed results table
  # -----------------------------
  
  output$detail_table <- renderDT({
    detail_data() %>%
      mutate(
        `Total Claims Cost` = dollar(total_claim_amount),
        Premium = dollar(total_premium),
        `Avg Cost per Claim` = dollar(avg_severity),
        `Loss Ratio` = percent(loss_ratio, accuracy = 0.1)
      ) %>%
      select(
        line,
        region,
        quarter,
        claim_count,
        `Total Claims Cost`,
        Premium,
        `Avg Cost per Claim`,
        `Loss Ratio`
      ) %>%
      rename(
        `Business Line` = line,
        Region = region,
        `Reporting Quarter` = quarter,
        Claims = claim_count
      ) %>%
      datatable(
        options = list(pageLength = 8),
        rownames = FALSE
      )
  })
  
  
  # -----------------------------
  # Excel export
  # -----------------------------
  # The export now includes:
  # - filtered raw data
  # - quarter summary
  # - detailed results
  # - risk flags
  # - scenario analysis
  # -----------------------------
  
  output$download_excel <- downloadHandler(
    filename = function() {
      paste0("quarterly_portfolio_review_", Sys.Date(), ".xlsx")
    },
    
    content = function(file) {
      export_filtered_data <- filtered_data()
      export_quarter_summary <- trend_data()
      export_detail_data <- detail_data()
      export_risk_flags <- risk_flags()
      export_scenario_data <- scenario_data()
      
      wb <- createWorkbook()
      
      addWorksheet(wb, "filtered_data")
      addWorksheet(wb, "quarter_summary")
      addWorksheet(wb, "detailed_results")
      addWorksheet(wb, "risk_flags")
      addWorksheet(wb, "scenario_analysis")
      
      writeData(wb, "filtered_data", export_filtered_data, withFilter = TRUE)
      writeData(wb, "quarter_summary", export_quarter_summary, withFilter = TRUE)
      writeData(wb, "detailed_results", export_detail_data, withFilter = TRUE)
      writeData(wb, "risk_flags", export_risk_flags, withFilter = TRUE)
      writeData(wb, "scenario_analysis", export_scenario_data, withFilter = TRUE)
      
      freezePane(wb, "filtered_data", firstRow = TRUE)
      freezePane(wb, "quarter_summary", firstRow = TRUE)
      freezePane(wb, "detailed_results", firstRow = TRUE)
      freezePane(wb, "risk_flags", firstRow = TRUE)
      freezePane(wb, "scenario_analysis", firstRow = TRUE)
      
      setColWidths(wb, "filtered_data", cols = 1:ncol(export_filtered_data), widths = "auto")
      setColWidths(wb, "quarter_summary", cols = 1:ncol(export_quarter_summary), widths = "auto")
      setColWidths(wb, "detailed_results", cols = 1:ncol(export_detail_data), widths = "auto")
      
      if (ncol(export_risk_flags) > 0) {
        setColWidths(wb, "risk_flags", cols = 1:ncol(export_risk_flags), widths = "auto")
      }
      
      setColWidths(wb, "scenario_analysis", cols = 1:ncol(export_scenario_data), widths = "auto")
      
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
}


# -----------------------------
# Run app
# -----------------------------

shinyApp(ui = ui, server = server)