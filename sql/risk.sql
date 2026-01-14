-- Computes average daily return and volatility (risk) for each individual stock based on cleaned daily returns.
CREATE TABLE stock_risk_return AS
SELECT
    ticker,
    AVG(daily_return) AS avg_daily_return,
    STDDEV(daily_return) AS volatility
FROM daily_returns_clean
GROUP BY ticker;

-- Stores the 10 stocks with the highest average daily return.
CREATE TABLE top_10_highest_return_stocks AS
SELECT
    ticker,
    avg_daily_return
FROM stock_risk_return
ORDER BY avg_daily_return DESC
LIMIT 10;

-- Stores the 10 stocks with the highest volatility (risk).
CREATE TABLE top_10_most_volatile_stocks AS
SELECT
    ticker,
    volatility
FROM stock_risk_return
ORDER BY volatility DESC
LIMIT 10;


DROP TABLE IF EXISTS portfolio_risk_return;

-- Converts daily average return and volatility to annualized metrics. Assumes ~252 trading days/year
CREATE TABLE portfolio_risk_return AS
SELECT
    AVG(portfolio_return) * 252 AS annualized_return,
    STDDEV(portfolio_return) * SQRT(252) AS annualized_volatility
FROM portfolio_daily_returns;

-- Identifies the best and worst daily returns experienced by the simulated portfolio.
CREATE TABLE portfolio_extremes AS
SELECT
    MAX(portfolio_return) AS best_day_return,
    MIN(portfolio_return) AS worst_day_return
FROM portfolio_daily_returns;

-- Compares the portfolio's risk/return against the average stock in the dataset (mean of per-stock metrics).
CREATE TABLE portfolio_vs_stock_distribution AS
SELECT
    (SELECT avg_daily_return FROM portfolio_risk_return) AS portfolio_avg_daily_return,
    (SELECT volatility FROM portfolio_risk_return) AS portfolio_volatility,
    AVG(avg_daily_return) AS avg_stock_daily_return,
    AVG(volatility) AS avg_stock_volatility
FROM stock_risk_return;

-- Checks whether the portfolio is less volatile than the average of its component stocks (diversification effect).
CREATE TABLE diversification_check AS
SELECT
    (SELECT volatility FROM portfolio_risk_return) AS portfolio_volatility,
    AVG(srr.volatility) AS avg_component_stock_volatility
FROM stock_risk_return srr
JOIN portfolio_weights pw
  ON srr.ticker = pw.ticker;