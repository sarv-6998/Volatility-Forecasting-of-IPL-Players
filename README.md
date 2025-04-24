# 📊 Volatility Forecasting of IPL Players using GARCH Model

This project applies the GARCH(1,1) model—commonly used in finance—to forecast the **consistency of IPL players' fantasy performance**. The goal is to go beyond average scores and introduce a risk-aware strategy for fantasy cricket platforms like Dream11.

## 🏏 Why GARCH in IPL?

While most fantasy players focus on averages, **volatility** in player performance can make or break a lineup. A player might score 80 points one match and 5 in the next. Using GARCH helps model and forecast this inconsistency—just like we do for stocks.

## 🔧 What We Built

- GARCH(1,1) models for 40 IPL players based on their match-wise fantasy points  
- Calculated **returns** for each player to model performance variability  
- Introduced a new metric:
Pick Score = Average Fantasy Points / (Average Volatility + ε)

- Built an **interactive R Shiny dashboard** to compare players by team, volatility trend, and pick score

## 📁 Project Structure

- `data/` - Cleaned fantasy points data  
- `scripts/` - R scripts for return calculation, GARCH modeling, and forecasting  
- `dashboard/` - R Shiny app files for visualization  
- `outputs/` - CSVs containing volatility forecasts and pick scores  

## 🚧 Current Status

- ✅ Prototype built and tested on batting data  
- 🧪 Backtesting in progress  
- 🔍 Future scope includes: bowling data, venue/opposition effects, and ensemble models

## 👥 Team

- Nirja Rajeev  
- Kartik Badkas  
- Satheesh M K  
- Sarvesh Kulkarni  
- Saket Pitale

---

**#FantasyCricket #TimeSeries #GARCH #IPL #SportsAnalytics #DataScience**
