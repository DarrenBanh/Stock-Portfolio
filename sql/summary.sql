-- Computes cumulative portfolio performance over time to show how $1 grows based on daily portfolio returns.
CREATE TABLE portfolio_cumulative_returns AS
SELECT
    date,
    EXP(SUM(LOG(1 + portfolio_return)) OVER (ORDER BY date)) AS growth_of_1
FROM portfolio_daily_returns;

-- Stores the portfolio’s total return over the full period. This equals ending value of $1 minus 1.
CREATE TABLE portfolio_total_return AS
SELECT
    (MAX(growth_of_1) - 1) AS total_return
FROM portfolio_cumulative_returns;

-- Computes running peak value and drawdown to quantify the largest percentage drop from a historical peak.
CREATE TABLE portfolio_drawdown AS
SELECT
    date,
    growth_of_1,
    MAX(growth_of_1) OVER (ORDER BY date) AS running_peak,
    (growth_of_1 / MAX(growth_of_1) OVER (ORDER BY date)) - 1 AS drawdown
FROM portfolio_cumulative_returns;

-- Stores the worst (most negative) drawdown over the period.
CREATE TABLE portfolio_max_drawdown AS
SELECT
    MIN(drawdown) AS max_drawdown
FROM portfolio_drawdown;

-- Consolidates key portfolio metrics (daily + annualized) into one report-ready table.
CREATE TABLE portfolio_key_metrics AS
SELECT
    (SELECT avg_daily_return FROM portfolio_summary_stats) AS avg_daily_return,
    (SELECT volatility FROM portfolio_summary_stats) AS daily_volatility,
    (SELECT annualized_return FROM portfolio_risk_return) AS annualized_return,
    (SELECT annualized_volatility FROM portfolio_risk_return) AS annualized_volatility,
    (SELECT total_return FROM portfolio_total_return) AS total_return,
    (SELECT max_drawdown FROM portfolio_max_drawdown) AS max_drawdown;

-- Compares portfolio average daily return to each stock’s average daily return to show relative performance.
CREATE TABLE portfolio_vs_stocks AS
SELECT
    'PORTFOLIO' AS asset,
    AVG(portfolio_return) AS avg_daily_return
FROM portfolio_daily_returns

UNION ALL

SELECT
    ticker AS asset,
    AVG(daily_return) AS avg_daily_return
FROM daily_returns_clean
GROUP BY ticker;

-- Stores top and bottom performers by average daily return
CREATE TABLE stock_best_worst_performers (
    category VARCHAR(20),
    ticker   VARCHAR(10),
    avg_daily_return DOUBLE
);

-- Inserts the top 10 stocks by average daily return
INSERT INTO stock_best_worst_performers (category, ticker, avg_daily_return)
SELECT
    'TOP_10' AS category,
    ticker,
    AVG(daily_return) AS avg_daily_return
FROM daily_returns_clean
GROUP BY ticker
ORDER BY avg_daily_return DESC
LIMIT 10;

-- Inserts the bottom 10 stocks by average daily return
INSERT INTO stock_best_worst_performers (category, ticker, avg_daily_return)
SELECT
    'BOTTOM_10' AS category,
    ticker,
    AVG(daily_return) AS avg_daily_return
FROM daily_returns_clean
GROUP BY ticker
ORDER BY avg_daily_return ASC
LIMIT 10;

CREATE TABLE final_results AS
SELECT
  (SELECT avg_daily_return FROM portfolio_summary_stats)       AS avg_daily_return,
  (SELECT volatility FROM portfolio_summary_stats)             AS daily_volatility,
  (SELECT annualized_return FROM portfolio_risk_return)        AS annualized_return,
  (SELECT annualized_volatility FROM portfolio_risk_return)    AS annualized_volatility,
  (SELECT total_return FROM portfolio_total_return)            AS total_return,
  (SELECT max_drawdown FROM portfolio_max_drawdown)            AS max_drawdown,
  (SELECT best_day_return FROM portfolio_extremes)             AS best_day_return,
  (SELECT worst_day_return FROM portfolio_extremes)            AS worst_day_return;

SELECT * FROM final_results;