library(shiny)
library(ggplot2)
library(dplyr)
library(readr)

# Load the volatility and player stats data
vol_data <- read_csv("volatility_data.csv")
player_stats <- read_csv("player_stats.csv")

# UI
ui <- fluidPage(
  titlePanel("📈 GARCH Volatility Forecasts – Enhanced IPL Fantasy Player Evaluation"),
  sidebarLayout(
    sidebarPanel(
      selectInput("team", "Select Batting Team:", choices = unique(vol_data$batting_team)),
      uiOutput("player1_ui"),
      uiOutput("player2_ui")
    ),
    mainPanel(
      plotOutput("compare_plot"),
      br(),
      plotOutput("performance_plot"),
      br(),
      tableOutput("player_scores"),
      br(),
      textOutput("note")
    )
  )
)

# Server
server <- function(input, output, session) {
  
  observeEvent(input$team, {
    players <- unique(vol_data$fullName[vol_data$batting_team == input$team])
    updateSelectInput(session, "player1", choices = players)
    updateSelectInput(session, "player2", choices = players, selected = players[2])
  })
  
  output$player1_ui <- renderUI({
    selectInput("player1", "Select Player 1:", choices = NULL)
  })
  
  output$player2_ui <- renderUI({
    selectInput("player2", "Select Player 2:", choices = NULL)
  })
  
  filtered_data <- reactive({
    vol_data %>%
      filter(fullName %in% c(input$player1, input$player2),
             batting_team == input$team)
  })
  
  output$compare_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = match_seq, y = volatility, color = fullName, linetype = type)) +
      geom_line(size = 1.2) +
      geom_point(size = 2) +
      labs(
        title = paste("Volatility Comparison:", input$player1, "vs", input$player2),
        x = "Match Sequence", y = "Volatility",
        color = "Player", linetype = "Type"
      ) +
      theme_minimal(base_size = 14)
  })
  
  output$performance_plot <- renderPlot({
    player_stats %>%
      filter(fullName %in% c(input$player1, input$player2)) %>%
      ggplot(aes(x = avg_points, y = avg_volatility, label = fullName)) +
      geom_point(aes(color = pick_score), size = 5) +
      geom_text(vjust = -1.2, size = 4) +
      scale_color_gradient(low = "red", high = "green") +
      labs(
        title = "Performance vs Volatility with Pick Score",
        x = "Average Fantasy Points",
        y = "Average Volatility",
        color = "Pick Score"
      ) +
      theme_minimal(base_size = 14)
  })
  
  output$player_scores <- renderTable({
    player_stats %>%
      filter(fullName %in% c(input$player1, input$player2)) %>%
      arrange(desc(pick_score))
  })
  
  output$note <- renderText({
    paste("Showing comparison and metrics for", input$player1, "and", input$player2, "from team", input$team)
  })
}

shinyApp(ui = ui, server = server)
