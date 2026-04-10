library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(scales)

# -----------------
# The big picture: what the app does
# load data → let user filter it → recompute summaries → show results
# 
# app_data is the starting table, the base data table the app uses
# this is a clean, prepared dataset
#
# separate data prep from dashboard display
#
# the ui is the layout
# this is what the user sees
# title, filters, tabs
# the front end
#
# the server is the brain, where the logic happens:
# what to do when filters change
# how to calculate the KPIs
# how to build the plot data
# how to build the table data
#
# ui = what the user sees
# server = what the app thinks and calculates
#
# reactive:
# a reactive object updates automatically when
# a user changes input
# filtered_data() changes automatically when
# a user chooses a specific Business Line or Region, etc
#
# so filtered_data <- reactive({
# means build me a filtered dataset that gets automatically updated
# this is the engine of the app
#
# Good dashboard design:
# 1 dataset feeds/creates many outputs thanks to reactive logic
#
# From the same filtered data, you create:
# kpi_data()
# trend_data()
# detail_data()
#
# filtered_data()  What rows are currently relevant based on the user’s filters?
#
# kpi_data() What are the big top-level numbers right now? (total claims, total claim amount, severity, loss ratio)
#
# trend_data() How is something changing over time? Usually grouped by quarter
#
# renderText() puts a text result into the UI
#
# renderPlot() takes processed data and turns it into a ggplot
#
# renderDT() Used for the interactive table, useful because business users often want both: summary view and inspectable table
#
# things like input#line, input$region, etc. represent what the user selected
# input$... is how the server knows what the user wants to look at
# this is how the app becomes interactive
#
# -----------------
'
Why validate(need()) is useful

This protects the app when filters return no data.

Instead of crashing or showing a weird error, it shows a clean message.

That is small, but very good practice.
'
app_data <- readRDS(file.path("data", "dashboard_metrics.rds"))

ui <- fluidPage(
  titlePanel("Insurance Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
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
            h4("Total Claim Amount"),
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
          "Severity Trend", # Severity Trend is a more specific tab name for this tab
          plotOutput("severity_trend_plot", height = "400px")
        ),
        tabPanel(
          "Claim Count Trend",
          plotOutput("claim_count_trend_plot", height = "400px")
        ),
        tabPanel(
          "Claims Cost Trend",
          plotOutput("claim_amount_trend_plot", height = "400px")
        ),
        tabPanel(
          "Loss Ratio Trend",
          plotOutput("loss_ratio_trend_plot", height = "400px")
        ),
        tabPanel(
          "Premium Trend",
          plotOutput("premium_trend_plot", height = "400px")
        ),
        tabPanel(
          "Detailed Results",
          DTOutput("detail_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
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
      )
  })
  
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
  
  output$severity_trend_plot <- renderPlot({
    validate(
      need(nrow(trend_data()) > 0, "No data available for this filter selection.")
    )
    
    ggplot(trend_data(), aes(x = quarter, y = avg_severity, group = 1)) +
      geom_line() +
      geom_point() +
      labs(
        title = "Average Claim Cost by Quarter", # changed this from average severity by quarter because its more understandable, they mean the same thing
        x = "Reporting Quarter",
        y = "Average Cost per Claim"
      ) +
      theme_minimal()
  })
  
  output$claim_count_trend_plot <- renderPlot({
    validate(
      need(nrow(trend_data()) > 0, "No data available for this filter selection.")
    )
    
    ggplot(trend_data(), aes(x = quarter, y = claim_count, group = 1)) +
      geom_line() +
      geom_point() +
      scale_y_continuous(labels = comma) +
      labs(
        title = "Number of Claims by Quarter",
        x = "Reporting Quarter",
        y = "Claims"
      ) +
      theme_minimal()
  })
  
  output$claim_amount_trend_plot <- renderPlot({
    validate(
      need(nrow(trend_data()) > 0, "No data available for this filter selection.")
    )
    
    ggplot(trend_data(), aes(x = quarter, y = total_claim_amount, group = 1)) +
      geom_line() +
      geom_point() +
      scale_y_continuous(labels = dollar) +
      labs(
        title = "Total Claims Cost by Quarter",
        x = "Reporting Quarter",
        y = "Total Claims Cost"
      ) +
      theme_minimal()
  })
  
  output$loss_ratio_trend_plot <- renderPlot({
    validate(
      need(nrow(trend_data()) > 0, "No data available for this filter selection.")
    )
    
    ggplot(trend_data(), aes(x = quarter, y = loss_ratio, group = 1)) +
      geom_line() +
      geom_point() +
      scale_y_continuous(labels = percent) +
      labs(
        title = "Loss Ratio by Quarter",
        x = "Reporting Quarter",
        y = "Loss Ratio"
      ) +
      theme_minimal()
  })
  
  output$premium_trend_plot <- renderPlot({
    validate(
      need(nrow(trend_data()) > 0, "No data available for this filter selection.")
    )
    
    ggplot(trend_data(), aes(x = quarter, y = total_premium, group = 1)) +
      geom_line() +
      geom_point() +
      scale_y_continuous(labels = dollar) +
      labs(
        title = "Premium by Quarter",
        x = "Reporting Quarter",
        y = "Premium"
      ) +
      theme_minimal()
  })
  
  
# -------------------------------------
#
# Here with output$detail_table... I am improving the formatting of the table
# rounding, currency, percentages
#
# -------------------------------------
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
}

# shinyApp(ui = ui, server = server)

'
Analysis structure for dashboards:

Filter layer

User picks the business slice they want.

KPI layer

You collapse filtered data into high-level metrics.

Trend layer

You show how one important metric changes over time.

Detail layer

You let the user inspect the numbers behind the summary.

Reporting logic
'


# Dashboard: structuring business logic, levels, layers, kpis, trends

# this last line is a function call
# function call that creates and returns the Shiny app object
# the app file must end by returning a Shiny app object
# and thats what this function call does

shinyApp(ui = ui, server = server)







