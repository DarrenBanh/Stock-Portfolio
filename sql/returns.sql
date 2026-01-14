-- Calculates daily stock returns for each ticker using the previous trading day's closing price.
CREATE TABLE daily_returns AS
SELECT
    ticker,
    date,
    close,
    LAG(close) OVER (PARTITION BY ticker ORDER BY date) AS prev_close,
    (close - LAG(close) OVER (PARTITION BY ticker ORDER BY date))
        / NULLIF(LAG(close) OVER (PARTITION BY ticker ORDER BY date), 0) 
        AS daily_return
FROM stock_prices;

-- Removes rows with NULL daily returns (first trading day per stock) to create a clean dataset for portfolio and risk analysis.
CREATE TABLE daily_returns_clean AS
SELECT
    ticker,
    date,
    daily_return
FROM daily_returns
WHERE daily_return IS NOT NULL
  AND daily_return > -0.5
  AND daily_return < 5;

-- Provides a quick performance comparison across stocks based on mean daily return.
CREATE TABLE avg_daily_returns AS
SELECT
    ticker,
    AVG(daily_return) AS avg_daily_return
FROM daily_returns_clean
GROUP BY ticker
ORDER BY avg_daily_return DESC
LIMIT 10;