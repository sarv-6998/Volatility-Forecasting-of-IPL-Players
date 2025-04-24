library(tidyverse)
library(rugarch)

# Load your full dataset
data <- read.csv("/Users/sarveshkulkarni/Batting_data.csv") |> 
  filter(season == 2023)

# List of unique teams in 2023 data
teams <- unique(data$batting_team)

# Select top 4 players per team with proper grouping
players_to_model <- data %>%
  group_by(batting_team, fullName) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(desc(n)) %>%
  group_by(batting_team) %>%
  slice_head(n = 8) %>%
  pull(fullName)

# Initialize list to store results
all_forecasts <- list()
player_stats <- data.frame()
player_stats

garch_spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)
garch_spec

# Loop through players
for (player in players_to_model) {
  tryCatch({
    player_df <- data %>%
      filter(fullName == player) %>%
      arrange(match_id) %>%
      mutate(match_seq = row_number(),
             ZeroInd = ifelse(lag(Batting_FP) == 0, 1, 0),
             Returns = ifelse(ZeroInd, Batting_FP, (Batting_FP - lag(Batting_FP))/lag(Batting_FP))) %>%
      filter(!is.na(Returns) & is.finite(Returns))
    
    returns <- player_df$Returns
    fantasy_points <- player_df$Batting_FP
    
    if (length(returns) < 10) {
      message(paste("Skipped (insufficient data):", player))
      next
    }
    
    garch_fit <- ugarchfit(spec = garch_spec, data = returns)
    sigma_actual <- sigma(garch_fit)
    
    if (length(sigma_actual) != length(returns)) {
      message(paste("Skipped (sigma mismatch):", player))
      next
    }
    
    avg_points <- mean(fantasy_points, na.rm = TRUE)
    avg_volatility <- mean(sigma_actual)
    pick_score <- avg_points / (avg_volatility + 1e-6)
    
    player_stats <- bind_rows(player_stats, data.frame(
      fullName = player,
      avg_points = avg_points,
      avg_volatility = avg_volatility,
      pick_score = pick_score
    ))
    
    actual_vol <- data.frame(
      fullName = player,
      batting_team = unique(player_df$batting_team),
      match_id = tail(player_df$match_id, length(sigma_actual)),
      match_seq = tail(player_df$match_seq, length(sigma_actual)),
      volatility = sigma_actual,
      type = "Actual"
    )
    
    
    garch_forecast <- ugarchforecast(garch_fit, n.ahead = 5)
    sigma_forecast <- as.numeric(sigma(garch_forecast))
    last_id <- max(actual_vol$match_id)
    last_seq <- max(actual_vol$match_seq)
    
    forecast_df <- data.frame(
      fullName = player,
      batting_team = unique(player_df$batting_team),
      match_id = (last_id + 1):(last_id + 5),
      match_seq = (last_seq + 1):(last_seq + 5),
      volatility = sigma_forecast,
      type = "Forecast"
    )
    
    
    all_forecasts[[player]] <- bind_rows(actual_vol, forecast_df)
    message(paste("Successfully processed:", player))
    
  }, error = function(e) {
    message(paste("Error processing", player, ":", e$message))
  })
}

# Combine and write to CSV
volatility_data <- bind_rows(all_forecasts)
write.csv(volatility_data, "volatility_data.csv", row.names = FALSE)
write.csv(player_stats, "player_stats.csv", row.names = FALSE)




# Optional scatter plot for strategy
if (nrow(player_stats) > 0) {
  ggplot(player_stats, aes(x = avg_points, y = avg_volatility, label = fullName)) +
    geom_point(aes(color = pick_score), size = 3) +
    geom_text(vjust = 1.5, size = 3) +
    scale_color_gradient(low = "red", high = "green") +
    labs(title = "Player Evaluation: Performance vs Volatility",
         x = "Average Fantasy Points",
         y = "Average Volatility",
         color = "Pick Score") +
    theme_minimal()
}

library(ggplot2)
