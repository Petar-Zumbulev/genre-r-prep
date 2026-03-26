library(shiny)
library(dplyr)
library(ggplot2)
library(scales)

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

server <- function(input, output) {
  
  filtered_metrics <- reactive({
    df <- dashboard_metrics
    
    if (input$line != "All") {
      df <- df %>% filter(line == input$line)
    }
    
    if (input$region != "All") {
      df <- df %>% filter(region == input$region)
    }
    
    df
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
