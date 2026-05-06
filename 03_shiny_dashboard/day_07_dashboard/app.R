library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(DT)
library(scales)
library(openxlsx)

# ============================================================
# Insurance Reporting Dashboard
# 
# Purpose:
# This app simulates a practical insurance reporting workflow:
# clean data -> interactive filters -> KPIs -> trends -> details -> Excel export
#
# Main dashboard layers:
# 1. Filter layer: user selects business line, region, quarter
# 2. KPI layer: high-level numbers recomputed from filtered data
# 3. Trend layer: quarterly business development
# 4. Detail layer: table behind the dashboard
# 5. Export layer: filtered data + summaries exported to Excel
# ============================================================


# -----------------------------
# Load prepared dashboard data
# -----------------------------

app_data <- readRDS(file.path("data", "dashboard_metrics.rds"))


# -----------------------------
# Formatting helpers
# -----------------------------

money <- label_currency(prefix = "€", accuracy = 1, big.mark = ",")
money0 <- label_currency(prefix = "€", accuracy = 1, big.mark = ",")
num <- label_comma()
pct <- label_percent(accuracy = 0.1)

fmt_value <- function(x, formatter) {
  if (length(x) == 0 || is.na(x)) {
    "n/a"
  } else {
    formatter(x)
  }
}

safe_divide <- function(numerator, denominator) {
  if_else(
    denominator > 0,
    numerator / denominator,
    NA_real_
  )
}


# -----------------------------
# Reusable ggplot theme
# -----------------------------

dashboard_theme <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(color = "#64748B"),
      axis.title = element_text(color = "#334155"),
      axis.text = element_text(color = "#475569"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "bottom",
      legend.title = element_blank()
    )
}


# -----------------------------
# UI helper for KPI cards
# -----------------------------

metric_card <- function(title, value_id, subtitle, icon = "") {
  div(
    class = "metric-card",
    div(class = "metric-icon", icon),
    div(class = "metric-label", title),
    div(class = "metric-value", textOutput(value_id, inline = TRUE)),
    div(class = "metric-subtitle", subtitle)
  )
}


# -----------------------------
# UI
# -----------------------------

ui <- fluidPage(
  
  tags$head(
    tags$style(
      HTML("
        body {
          background: #F8FAFC;
          color: #0F172A;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        .dashboard-wrapper {
          max-width: 1450px;
          margin: 0 auto;
          padding: 22px 18px 40px 18px;
        }

        .dashboard-header {
          background: linear-gradient(135deg, #0F172A 0%, #1E3A8A 55%, #2563EB 100%);
          color: white;
          padding: 28px 32px;
          border-radius: 22px;
          margin-bottom: 22px;
          box-shadow: 0 18px 35px rgba(15, 23, 42, 0.18);
        }

        .dashboard-header h1 {
          margin-top: 0;
          margin-bottom: 8px;
          font-size: 34px;
          font-weight: 750;
          letter-spacing: -0.03em;
        }

        .dashboard-header p {
          margin-bottom: 16px;
          color: #DBEAFE;
          font-size: 16px;
          max-width: 900px;
        }

        .header-badge {
          display: inline-block;
          background: rgba(255, 255, 255, 0.14);
          border: 1px solid rgba(255, 255, 255, 0.25);
          color: #EFF6FF;
          padding: 7px 12px;
          border-radius: 999px;
          margin-right: 8px;
          margin-bottom: 8px;
          font-size: 13px;
          font-weight: 600;
        }

        .sidebar-panel {
          background: white;
          border-radius: 18px;
          padding: 20px;
          box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08);
          border: 1px solid #E2E8F0;
        }

        .sidebar-title {
          font-size: 16px;
          font-weight: 750;
          margin-bottom: 12px;
          color: #0F172A;
        }

        .filter-summary {
          background: #EFF6FF;
          border: 1px solid #BFDBFE;
          color: #1E3A8A;
          padding: 12px;
          border-radius: 14px;
          font-size: 13px;
          margin-top: 16px;
        }

        .btn {
          border-radius: 10px;
          font-weight: 600;
        }

        .metric-card {
          background: white;
          border-radius: 18px;
          padding: 19px 18px;
          margin-bottom: 18px;
          min-height: 145px;
          border: 1px solid #E2E8F0;
          box-shadow: 0 10px 24px rgba(15, 23, 42, 0.07);
          position: relative;
          overflow: hidden;
        }

        .metric-card:before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 5px;
          background: linear-gradient(90deg, #2563EB, #14B8A6);
        }

        .metric-icon {
          font-size: 22px;
          margin-bottom: 7px;
        }

        .metric-label {
          color: #64748B;
          font-size: 13px;
          text-transform: uppercase;
          font-weight: 750;
          letter-spacing: 0.04em;
          margin-bottom: 8px;
        }

        .metric-value {
          font-size: 27px;
          font-weight: 800;
          color: #0F172A;
          letter-spacing: -0.03em;
          margin-bottom: 7px;
        }

        .metric-subtitle {
          color: #64748B;
          font-size: 13px;
        }

        .content-card {
          background: white;
          border-radius: 18px;
          padding: 20px;
          margin-bottom: 18px;
          border: 1px solid #E2E8F0;
          box-shadow: 0 10px 24px rgba(15, 23, 42, 0.07);
        }

        .content-card h3 {
          margin-top: 0;
          font-size: 20px;
          font-weight: 750;
          letter-spacing: -0.02em;
        }

        .insight-box {
          background: #F8FAFC;
          border-left: 5px solid #2563EB;
          padding: 16px 18px;
          border-radius: 14px;
          color: #334155;
          line-height: 1.55;
        }

        .insight-box ul {
          padding-left: 18px;
          margin-bottom: 0;
        }

        .nav-tabs {
          border-bottom: 1px solid #CBD5E1;
        }

        .nav-tabs > li > a {
          border-radius: 12px 12px 0 0;
          color: #334155;
          font-weight: 650;
        }

        .nav-tabs > li.active > a,
        .nav-tabs > li.active > a:focus,
        .nav-tabs > li.active > a:hover {
          color: #1D4ED8;
          font-weight: 750;
        }

        .selectize-input {
          border-radius: 10px;
          border-color: #CBD5E1;
          min-height: 40px;
        }

        label {
          color: #334155;
          font-weight: 700;
          font-size: 13px;
        }

        .download-button {
          width: 100%;
          background: #2563EB !important;
          border-color: #2563EB !important;
          color: white !important;
          margin-top: 8px;
        }

        .reset-button {
          width: 100%;
          margin-top: 4px;
          background: #F8FAFC !important;
          border-color: #CBD5E1 !important;
          color: #334155 !important;
        }
      ")
    )
  ),
  
  div(
    class = "dashboard-wrapper",
    
    div(
      class = "dashboard-header",
      h1("Insurance Performance Dashboard"),
      p(
        "Interactive R/Shiny dashboard for insurance-style reporting: ",
        "claims, premium, severity, loss ratio, quarterly trends, and Excel export."
      ),
      span(class = "header-badge", "R/Shiny"),
      span(class = "header-badge", "tidyverse"),
      span(class = "header-badge", "ggplot2"),
      span(class = "header-badge", "Excel Reporting"),
      span(class = "header-badge", "Business KPIs")
    ),
    
    sidebarLayout(
      
      sidebarPanel(
        width = 3,
        class = "sidebar-panel",
        
        div(class = "sidebar-title", "Dashboard Filters"),
        
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
        
        actionButton(
          inputId = "reset_filters",
          label = "Reset filters",
          class = "reset-button"
        ),
        
        downloadButton(
          outputId = "download_excel",
          label = "Download Excel report",
          class = "download-button"
        ),
        
        uiOutput("filter_summary")
      ),
      
      mainPanel(
        width = 9,
        
        fluidRow(
          column(
            3,
            metric_card(
              title = "Claim Count",
              value_id = "claim_count_value",
              subtitle = "Total claims in selected view",
              icon = "📄"
            )
          ),
          column(
            3,
            metric_card(
              title = "Total Claims Cost",
              value_id = "claim_amount_value",
              subtitle = "Aggregated claim amount",
              icon = "€"
            )
          ),
          column(
            3,
            metric_card(
              title = "Avg Cost per Claim",
              value_id = "avg_severity_value",
              subtitle = "Severity = cost / claims",
              icon = "📊"
            )
          ),
          column(
            3,
            metric_card(
              title = "Loss Ratio",
              value_id = "loss_ratio_value",
              subtitle = "Claims cost / premium",
              icon = "⚖️"
            )
          )
        ),
        
        div(
          class = "content-card",
          h3("Business Insights"),
          div(
            class = "insight-box",
            uiOutput("business_insights")
          )
        ),
        
        div(
          class = "content-card",
          
          tabsetPanel(
            tabPanel(
              "Overview",
              br(),
              fluidRow(
                column(
                  6,
                  plotOutput("cost_premium_plot", height = "390px")
                ),
                column(
                  6,
                  plotOutput("loss_ratio_trend_plot", height = "390px")
                )
              )
            ),
            
            tabPanel(
              "Severity Trend",
              br(),
              plotOutput("severity_trend_plot", height = "430px")
            ),
            
            tabPanel(
              "Claim Count",
              br(),
              plotOutput("claim_count_trend_plot", height = "430px")
            ),
            
            tabPanel(
              "Claims Cost",
              br(),
              plotOutput("claim_amount_trend_plot", height = "430px")
            ),
            
            tabPanel(
              "Premium",
              br(),
              plotOutput("premium_trend_plot", height = "430px")
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
  )
)


# -----------------------------
# Server
# -----------------------------

server <- function(input, output, session) {
  
  observeEvent(input$reset_filters, {
    updateSelectInput(session, "line", selected = "All")
    updateSelectInput(session, "region", selected = "All")
    updateSelectInput(session, "quarter", selected = "All")
  })
  
  
  # -----------------------------
  # Filter layer
  # -----------------------------
  
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
  
  kpi_data <- reactive({
    filtered_data() %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        total_premium = sum(total_premium, na.rm = TRUE)
      ) %>%
      mutate(
        avg_severity = safe_divide(total_claim_amount, claim_count),
        loss_ratio = safe_divide(total_claim_amount, total_premium)
      )
  })
  
  
  # -----------------------------
  # Trend layer
  # -----------------------------
  
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
        avg_severity = safe_divide(total_claim_amount, claim_count),
        loss_ratio = safe_divide(total_claim_amount, total_premium)
      ) %>%
      arrange(quarter)
  })
  
  
  # -----------------------------
  # Detail layer
  # -----------------------------
  
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
        avg_severity = safe_divide(total_claim_amount, claim_count),
        loss_ratio = safe_divide(total_claim_amount, total_premium)
      ) %>%
      arrange(desc(total_claim_amount))
  })
  
  
  # -----------------------------
  # Filter summary
  # -----------------------------
  
  output$filter_summary <- renderUI({
    df <- filtered_data()
    
    div(
      class = "filter-summary",
      strong("Current view"),
      br(),
      paste("Rows:", comma(nrow(df))),
      br(),
      paste("Business lines:", comma(n_distinct(df$line))),
      br(),
      paste("Regions:", comma(n_distinct(df$region))),
      br(),
      paste("Quarters:", comma(n_distinct(df$quarter)))
    )
  })
  
  
  # -----------------------------
  # KPI outputs
  # -----------------------------
  
  output$claim_count_value <- renderText({
    fmt_value(kpi_data()$claim_count, num)
  })
  
  output$claim_amount_value <- renderText({
    fmt_value(kpi_data()$total_claim_amount, money0)
  })
  
  output$avg_severity_value <- renderText({
    fmt_value(kpi_data()$avg_severity, money0)
  })
  
  output$loss_ratio_value <- renderText({
    fmt_value(kpi_data()$loss_ratio, pct)
  })
  
  
  # -----------------------------
  # Business insights
  # -----------------------------
  
  output$business_insights <- renderUI({
    td <- trend_data()
    kd <- kpi_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    latest_quarter <- td %>%
      arrange(quarter) %>%
      slice_tail(n = 1)
    
    highest_cost_quarter <- td %>%
      slice_max(total_claim_amount, n = 1, with_ties = FALSE)
    
    loss_ratio_value <- kd$loss_ratio[1]
    
    loss_ratio_message <- if (!is.na(loss_ratio_value) && loss_ratio_value >= 0.8) {
      "The selected portfolio has an elevated loss ratio and may require closer review."
    } else {
      "The selected portfolio has a moderate loss ratio based on the current reporting view."
    }
    
    if (nrow(td) >= 2) {
      last_two <- td %>%
        arrange(quarter) %>%
        slice_tail(n = 2)
      
      previous_cost <- last_two$total_claim_amount[1]
      latest_cost <- last_two$total_claim_amount[2]
      
      cost_change <- if (!is.na(previous_cost) && previous_cost > 0) {
        (latest_cost - previous_cost) / previous_cost
      } else {
        NA_real_
      }
      
      cost_change_text <- if (!is.na(cost_change)) {
        paste0(
          "Claims cost changed by ",
          pct(cost_change),
          " from the previous quarter to the latest quarter."
        )
      } else {
        "Quarter-over-quarter cost change cannot be calculated for the selected view."
      }
    } else {
      cost_change_text <- "Only one quarter is visible, so quarter-over-quarter movement is not available."
    }
    
    tags$ul(
      tags$li(
        strong("Latest quarter: "),
        latest_quarter$quarter,
        " with average cost per claim of ",
        money0(latest_quarter$avg_severity),
        "."
      ),
      tags$li(
        strong("Highest claims cost quarter: "),
        highest_cost_quarter$quarter,
        " with total claims cost of ",
        money0(highest_cost_quarter$total_claim_amount),
        "."
      ),
      tags$li(
        strong("Loss ratio view: "),
        loss_ratio_message
      ),
      tags$li(
        strong("Trend movement: "),
        cost_change_text
      )
    )
  })
  
  
  # -----------------------------
  # Plots
  # -----------------------------
  
  output$cost_premium_plot <- renderPlot({
    td <- trend_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    plot_data <- td %>%
      select(quarter, total_claim_amount, total_premium) %>%
      pivot_longer(
        cols = c(total_claim_amount, total_premium),
        names_to = "metric",
        values_to = "amount"
      ) %>%
      mutate(
        metric = recode(
          metric,
          total_claim_amount = "Claims Cost",
          total_premium = "Premium"
        )
      )
    
    ggplot(plot_data, aes(x = quarter, y = amount, group = metric, color = metric)) +
      geom_line(linewidth = 1.15) +
      geom_point(size = 2.8) +
      scale_y_continuous(labels = money0) +
      labs(
        title = "Claims Cost vs Premium",
        subtitle = "Comparison of outgoing claim cost and earned premium by quarter",
        x = "Reporting Quarter",
        y = "Amount"
      ) +
      dashboard_theme()
  })
  
  
  output$severity_trend_plot <- renderPlot({
    td <- trend_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    ggplot(td, aes(x = quarter, y = avg_severity, group = 1)) +
      geom_col(fill = "#DBEAFE", width = 0.65) +
      geom_line(color = "#1D4ED8", linewidth = 1.15) +
      geom_point(color = "#1D4ED8", size = 3) +
      scale_y_continuous(labels = money0) +
      labs(
        title = "Average Claim Cost by Quarter",
        subtitle = "Severity trend based on total claims cost divided by claim count",
        x = "Reporting Quarter",
        y = "Average Cost per Claim"
      ) +
      dashboard_theme()
  })
  
  
  output$claim_count_trend_plot <- renderPlot({
    td <- trend_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    ggplot(td, aes(x = quarter, y = claim_count, group = 1)) +
      geom_col(fill = "#BFDBFE", width = 0.65) +
      geom_line(color = "#1E40AF", linewidth = 1.15) +
      geom_point(color = "#1E40AF", size = 3) +
      scale_y_continuous(labels = num) +
      labs(
        title = "Number of Claims by Quarter",
        subtitle = "Claim volume trend for the selected business view",
        x = "Reporting Quarter",
        y = "Claims"
      ) +
      dashboard_theme()
  })
  
  
  output$claim_amount_trend_plot <- renderPlot({
    td <- trend_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    ggplot(td, aes(x = quarter, y = total_claim_amount, group = 1)) +
      geom_area(fill = "#DBEAFE", alpha = 0.65) +
      geom_line(color = "#2563EB", linewidth = 1.2) +
      geom_point(color = "#1D4ED8", size = 3) +
      scale_y_continuous(labels = money0) +
      labs(
        title = "Total Claims Cost by Quarter",
        subtitle = "Total claim amount after applying the current filters",
        x = "Reporting Quarter",
        y = "Total Claims Cost"
      ) +
      dashboard_theme()
  })
  
  
  output$loss_ratio_trend_plot <- renderPlot({
    td <- trend_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    ggplot(td, aes(x = quarter, y = loss_ratio, group = 1)) +
      geom_hline(
        yintercept = 0.8,
        linetype = "dashed",
        color = "#DC2626",
        linewidth = 0.8
      ) +
      geom_line(color = "#0F766E", linewidth = 1.2) +
      geom_point(color = "#0F766E", size = 3) +
      scale_y_continuous(labels = pct) +
      labs(
        title = "Loss Ratio by Quarter",
        subtitle = "Dashed line marks an 80% reference threshold",
        x = "Reporting Quarter",
        y = "Loss Ratio"
      ) +
      dashboard_theme()
  })
  
  
  output$premium_trend_plot <- renderPlot({
    td <- trend_data()
    
    validate(
      need(nrow(td) > 0, "No data available for this filter selection.")
    )
    
    ggplot(td, aes(x = quarter, y = total_premium, group = 1)) +
      geom_col(fill = "#CCFBF1", width = 0.65) +
      geom_line(color = "#0F766E", linewidth = 1.15) +
      geom_point(color = "#0F766E", size = 3) +
      scale_y_continuous(labels = money0) +
      labs(
        title = "Premium by Quarter",
        subtitle = "Premium volume for the selected reporting view",
        x = "Reporting Quarter",
        y = "Premium"
      ) +
      dashboard_theme()
  })
  
  
  # -----------------------------
  # Detailed table
  # -----------------------------
  
  output$detail_table <- renderDT({
    table_data <- detail_data() %>%
      rename(
        `Business Line` = line,
        Region = region,
        `Reporting Quarter` = quarter,
        Claims = claim_count,
        `Total Claims Cost` = total_claim_amount,
        Premium = total_premium,
        `Avg Cost per Claim` = avg_severity,
        `Loss Ratio` = loss_ratio
      )
    
    datatable(
      table_data,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        scrollX = TRUE,
        dom = "Bfrtip"
      ),
      rownames = FALSE,
      class = "stripe hover compact"
    ) %>%
      formatCurrency(
        columns = c("Total Claims Cost", "Premium", "Avg Cost per Claim"),
        currency = "€",
        digits = 0
      ) %>%
      formatPercentage(
        columns = "Loss Ratio",
        digits = 1
      )
  })
  
  
  # -----------------------------
  # Excel export
  # -----------------------------
  
  output$download_excel <- downloadHandler(
    filename = function() {
      paste0("insurance_dashboard_report_", Sys.Date(), ".xlsx")
    },
    
    content = function(file) {
      export_tbl <- filtered_data()
      kpi_tbl <- kpi_data()
      quarter_summary <- trend_data()
      detail_summary <- detail_data()
      
      wb <- createWorkbook()
      
      addWorksheet(wb, "kpi_summary")
      addWorksheet(wb, "quarter_summary")
      addWorksheet(wb, "detail_summary")
      addWorksheet(wb, "filtered_data")
      
      writeData(wb, "kpi_summary", kpi_tbl, withFilter = TRUE)
      writeData(wb, "quarter_summary", quarter_summary, withFilter = TRUE)
      writeData(wb, "detail_summary", detail_summary, withFilter = TRUE)
      writeData(wb, "filtered_data", export_tbl, withFilter = TRUE)
      
      header_style <- createStyle(
        textDecoration = "bold",
        fgFill = "#DBEAFE",
        border = "bottom"
      )
      
      sheet_names <- c(
        "kpi_summary",
        "quarter_summary",
        "detail_summary",
        "filtered_data"
      )
      
      for (sheet in sheet_names) {
        data_written <- switch(
          sheet,
          "kpi_summary" = kpi_tbl,
          "quarter_summary" = quarter_summary,
          "detail_summary" = detail_summary,
          "filtered_data" = export_tbl
        )
        
        if (ncol(data_written) > 0) {
          addStyle(
            wb,
            sheet = sheet,
            style = header_style,
            rows = 1,
            cols = 1:ncol(data_written),
            gridExpand = TRUE
          )
          
          freezePane(wb, sheet, firstRow = TRUE)
          setColWidths(wb, sheet, cols = 1:ncol(data_written), widths = "auto")
        }
      }
      
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
}


# -----------------------------
# Run app
# -----------------------------

shinyApp(ui = ui, server = server)