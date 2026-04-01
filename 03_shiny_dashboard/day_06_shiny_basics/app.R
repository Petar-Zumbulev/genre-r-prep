library(shiny)
library(dplyr)
library(ggplot2)
library(scales)
# with source, we run another script "dashboard_metrics_prep.R" in this script 
# so that we have the table for the server
source("03_shiny_dashboard/day_06_shiny_basics/dashboard_metrics_prep.R")

ui <- fluidPage(
  titlePanel("Mini Insurance Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "line",
        label = "Select line",
        choices = c("All", sort(unique(dashboard_metrics$line))),
        selected = "All"
      ),
      
      selectInput(
        inputId = "region",
        label = "Select region",
        choices = c("All", sort(unique(dashboard_metrics$region))),
        selected = "All"
      ),
      
      selectInput(
        inputId = "quarter",
        label = "Select quarter",
        choices = c("All", sort(unique(dashboard_metrics$quarter))),
        selected = "All"
      )
    ),
    
    mainPanel(
      h3("Overall selected view"),
      tableOutput("kpi_table"),
      
      h3("Quarterly summary"),
      tableOutput("summary_table"),
      
      h3("Average severity by quarter"),
      plotOutput("severity_plot"),
      
      h3("Loss ratio by quarter"),
      plotOutput("loss_ratio_plot")
    )
  )
)
'
The server has 2 very important reactive objects.

filtered_metrics

This is your filtered dataset.

It says:

start from dashboard_metrics
if the user selected a line, filter to that
if the user selected a region, filter to that

This is the core reactive dataset.

This is very important because all outputs use the same filtered base.

That is good dashboard design.

overall_metrics

This creates one high-level summary from the filtered data.

So after filtering, it calculates:

total claims
total claim amount
average severity
total premium
overall loss ratio
'
server <- function(input, output) {
  
  filtered_metrics <- reactive({
    df <- dashboard_metrics
    
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
  
  quarter_summary <- reactive({
    filtered_metrics() %>%
      group_by(quarter) %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        total_premium = sum(total_premium, na.rm = TRUE),
        avg_severity = if_else(
          claim_count > 0,
          total_claim_amount / claim_count,
          0
        ),
        loss_ratio = if_else(
          total_premium > 0,
          total_claim_amount / total_premium,
          NA_real_
        ),
        .groups = "drop"
      )
  })
  
  overall_metrics <- reactive({
    filtered_metrics() %>%
      summarise(
        total_claims = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(total_claim_amount, na.rm = TRUE),
        avg_severity = if_else(
          total_claims > 0,
          total_claim_amount / total_claims,
          0
        ),
        total_premium = sum(total_premium, na.rm = TRUE),
        overall_loss_ratio = if_else(
          total_premium > 0,
          total_claim_amount / total_premium,
          NA_real_
        )
      )
  })
  
  output$kpi_table <- renderTable({
    overall_metrics() %>%
      mutate(
        total_claim_amount = round(total_claim_amount, 2),
        avg_severity = round(avg_severity, 2),
        total_premium = round(total_premium, 2),
        overall_loss_ratio = percent(overall_loss_ratio, accuracy = 0.1)
      )
  })
  
  output$summary_table <- renderTable({
    filtered_metrics() %>%
      arrange(quarter)
  })
  
  output$severity_plot <- renderPlot({
    ggplot(filtered_metrics(),
           aes(x = quarter, y = avg_severity, group = 1)) +
      geom_line() +
      geom_point() +
      labs(
        x = "Quarter",
        y = "Average severity",
        title = "Average severity trend"
      ) +
      theme_minimal()
  })
  
  output$loss_ratio_plot <- renderPlot({
    ggplot(filtered_metrics(),
           aes(x = quarter, y = loss_ratio, group = 1)) +
      geom_line() +
      geom_point() +
      scale_y_continuous(labels = percent) +
      labs(
        x = "Quarter",
        y = "Loss ratio",
        title = "Loss ratio trend"
      ) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)

'
Shiny is not “new analytics”

It is mostly:

analytics you already know, wrapped in user inputs and reactive logic
'

'
Good dashboards start before Shiny

The real work is often:

choosing the correct granularity
preparing the data cleanly
defining the right KPIs

The app is only the front end of that logic.
'

'
One filtered dataset should drive many outputs

This is one of the best habits you can build early.

Instead of repeating filtering logic separately in every output, use one:

filtered_metrics <- reactive({ ... })

Then reuse it.

That makes the app:

cleaner
easier to debug
easier to extend tomorrow
'




