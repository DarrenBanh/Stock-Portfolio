# Stock Portfolio Risk & Return Analysis (SQL)

## Project Overview
This project simulates an equal-weight stock portfolio using historical price data and evaluates its performance and risk using SQL.

The analysis pipeline:
1. Load stock price data  
2. Compute daily returns  
3. Clean extreme outliers  
4. Construct a portfolio  
5. Measure risk and performance  
6. Validate results  

All analysis is performed using MySQL with materialized tables (no views).

---

## Data
- Input: CSV files with daily stock prices  
- Key fields: ticker, date, close  
- Returns calculated using previous trading day prices  
- Extreme outliers filtered to maintain realistic behavior  

---

## Portfolio Construction
The portfolio uses equal weights:

| Ticker | Weight |
|--------|--------|
| AAPL | 0.20 |
| MSFT | 0.20 |
| AMZN | 0.20 |
| GOOG | 0.20 |
| META | 0.20 |

---

## Key Results

| Metric | Value |
|--------|-------|
| Avg Daily Return | 0.000798 |
| Daily Volatility | 0.0133 |
| Annualized Return | 20.1% |
| Annualized Volatility | 21.15% |
| Total Return | 1524% |
| Max Drawdown | -49.2% |
| Best Day | +11.5% |
| Worst Day | -12.5% |

---

## Insights
- The portfolio achieved strong long-term performance with a 20% annualized return  
- Diversification reduced volatility compared to individual stocks  
- Large drawdowns highlight the importance of risk management  
- Returns were driven by consistent growth, not single-day spikes  