-- Defines the weights of each stock in the simulated investment portfolio. Uses an equal-weight portfolio for simplicity and interpretability.
CREATE TABLE portfolio_weights (
    ticker VARCHAR(10),
    weight DECIMAL(6,4)
);

-- Assigns equal weights to a selected group of stocks.
INSERT portfolio_weights VALUES
('AAPL', 0.20),
('MSFT', 0.20),
('AMZN', 0.20),
('GOOG', 0.20),
('TSLA', 0.20);

-- Calculates daily portfolio returns by applying portfolio weights to individual stock returns and summing them for each trading day.
CREATE TABLE portfolio_daily_returns AS
SELECT
    dr.date,
    SUM(dr.daily_return * pw.weight) AS portfolio_return
FROM daily_returns_clean dr
JOIN portfolio_weights pw
  ON dr.ticker = pw.ticker
GROUP BY dr.date
ORDER BY dr.date;

-- Computes basic summary statistics for the portfolio, including average daily return and volatility.
CREATE TABLE portfolio_summary_stats AS
SELECT
    AVG(portfolio_return) AS avg_daily_return,
    STDDEV(portfolio_return) AS volatility
FROM portfolio_daily_returns;

-- Identifies the best and worst daily returns experienced by the portfolio.
CREATE TABLE portfolio_extreme_days AS
SELECT
    MAX(portfolio_return) AS best_day_return,
    MIN(portfolio_return) AS worst_day_return
FROM portfolio_daily_returns;