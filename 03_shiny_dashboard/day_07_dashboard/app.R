library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(scales)

app_data <- readRDS("data/dashboard_metrics.rds")

ui <- fluidPage(
  titlePanel("Insurance Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "line",
        label = "Line",
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
        label = "Quarter",
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
          "Trend Plot",
          plotOutput("severity_trend_plot", height = "400px")
        ),
        tabPanel(
          "Detail Table",
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
        title = "Average Severity by Quarter",
        x = "Quarter",
        y = "Average Severity"
      ) +
      theme_minimal()
  })
  
  output$detail_table <- renderDT({
    datatable(detail_data())
  })
}

shinyApp(ui = ui, server = server)