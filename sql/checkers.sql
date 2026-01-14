-- Load Data Checkers

-- 1. Row count exists
SELECT COUNT(*) FROM stock_prices;

-- 2. Sample rows look real
SELECT * FROM stock_prices LIMIT 5;

-- 3. Ticker column is clean
SELECT DISTINCT ticker
FROM stock_prices
LIMIT 10;

-- 4. Volume is numeric and large
SELECT
    MIN(volume) AS min_volume,
    MAX(volume) AS max_volume
FROM stock_prices;

-- 5. No duplicate (ticker, date) rows
SELECT ticker, date, COUNT(*) AS cnt
FROM stock_prices
GROUP BY ticker, date
HAVING cnt > 1;

-- 6. Primary key exists
SHOW INDEX FROM stock_prices;

-- Return Checkers

-- 1. Ensure daily_returns was populated
SELECT COUNT(*) AS daily_returns_rows
FROM daily_returns;

-- 2. Ensure clean table has fewer rows
SELECT COUNT(*) AS daily_returns_clean_rows
FROM daily_returns_clean;

-- 3. Spot-check daily returns for a single ticker
SELECT
    ticker,
    date,
    close,
    prev_close,
    daily_return
FROM daily_returns
WHERE ticker = 'AAPL'
ORDER BY date
LIMIT 10;

-- 4. Validate return magnitude
SELECT
    MIN(daily_return) AS min_return,
    MAX(daily_return) AS max_return
FROM daily_returns_clean;

-- 5. Confirm top performers table populated
SELECT *
FROM avg_daily_returns;

-- 6. Confirm multiple tickers exist
SELECT COUNT(DISTINCT ticker) AS num_stocks
FROM daily_returns_clean;

-- Portfolio Checkers

-- 1. Confirm portfolio tickers & weights look right
-- Expected: shows your chosen tickers and weights (no NULLs).
SELECT
    ticker,
    weight
FROM portfolio_weights
ORDER BY ticker;

-- 2. Confirm weights sum to 1
-- Expected: total_weight = 1.0000 (or extremely close).
SELECT
    SUM(weight) AS total_weight
FROM portfolio_weights;

-- 3. Ensure no portfolio tickers are missing from returns
-- Expected: missing_tickers = 0
SELECT
    COUNT(*) AS missing_tickers
FROM portfolio_weights pw
LEFT JOIN (SELECT DISTINCT ticker FROM daily_returns_clean) dr
  ON pw.ticker = dr.ticker
WHERE dr.ticker IS NULL;

-- 4. Confirm the portfolio has daily returns
-- Expected: portfolio_days > 0
SELECT
    COUNT(*) AS portfolio_days
FROM portfolio_daily_returns;

-- 6. Verify portfolio return for a single day equals the manual weighted sum of component returns (sample 1 day).
-- Expected: difference close to 0.
SELECT
    pdr.date,
    pdr.portfolio_return,
    SUM(drc.daily_return * pw.weight) AS manual_weighted_sum,
    pdr.portfolio_return - SUM(drc.daily_return * pw.weight) AS difference
FROM portfolio_daily_returns pdr
JOIN daily_returns_clean drc
  ON drc.date = pdr.date
JOIN portfolio_weights pw
  ON pw.ticker = drc.ticker
GROUP BY pdr.date, pdr.portfolio_return
ORDER BY pdr.date
LIMIT 1;

-- Risk Checkers

-- 1. Confirm core tables exist
-- Expected: each query returns a row count (not an error).
SELECT COUNT(*) AS stock_prices_rows FROM stock_prices;
SELECT COUNT(*) AS daily_returns_rows FROM daily_returns;
SELECT COUNT(*) AS daily_returns_clean_rows FROM daily_returns_clean;
SELECT COUNT(*) AS avg_daily_returns_rows FROM avg_daily_returns;

SELECT COUNT(*) AS portfolio_weights_rows FROM portfolio_weights;
SELECT COUNT(*) AS portfolio_daily_returns_rows FROM portfolio_daily_returns;

SELECT COUNT(*) AS stock_risk_return_rows FROM stock_risk_return;
SELECT COUNT(*) AS portfolio_risk_return_rows FROM portfolio_risk_return;

-- 2. Basic sanity of tickers
-- Expected: num_stocks should be > 1 and usually much larger.
SELECT COUNT(DISTINCT ticker) AS num_stocks
FROM stock_prices;

SELECT COUNT(DISTINCT ticker) AS num_stocks_in_returns
FROM daily_returns_clean;

-- 3. Confirm portfolio weights sum to 1.0
-- Expected: total_weight = 1.0000 (or extremely close).
SELECT SUM(weight) AS total_weight
FROM portfolio_weights;

-- 4. Ensure portfolio calculation is not dropping all dates
-- Expected: portfolio_daily_returns_rows should be > 0.
SELECT COUNT(*) AS portfolio_days
FROM portfolio_daily_returns;

-- 5. Portfolio return range sanity
-- Expected: returns should be reasonable decimals (not huge). If max is extremely large, something is wrong with data/weights.
SELECT
    MIN(portfolio_return) AS min_portfolio_return,
    MAX(portfolio_return) AS max_portfolio_return
FROM portfolio_daily_returns;

-- 6. Daily return bounds sanity (based on cleaning)
-- Expected: min_return > -0.5 and max_return < 5
SELECT
    MIN(daily_return) AS min_return,
    MAX(daily_return) AS max_return
FROM daily_returns_clean;

-- 7. Quick spot-check returns for one ticker
-- Expected:
--   - Many rows returned
--   - daily_return values are small decimals
SELECT
    ticker,
    date,
    daily_return
FROM daily_returns_clean
WHERE ticker = 'AAPL'
ORDER BY date
LIMIT 20;

-- 8. Portfolio summary stats sanity
-- Expected:
--   - avg_daily_return is small (near 0)
--   - volatility is positive and usually < 1
SELECT *
FROM portfolio_summary_stats;

-- 9. Portfolio risk/return table exists and has values
-- Expected: 1 row returned, volatility not NULL.
SELECT *
FROM portfolio_risk_return;

-- 10. Diversification effect (portfolio vs component stocks)
-- Expected: portfolio_volatility <= avg_component_stock_volatility (not guaranteed, but often true and a good sanity check).
SELECT *
FROM diversification_check;

-- 11. Top lists have correct row counts
-- Expected: each returns 10 rows (unless dataset is smaller).
SELECT COUNT(*) AS top_return_rows FROM top_10_highest_return_stocks;
SELECT COUNT(*) AS top_volatility_rows FROM top_10_most_volatile_stocks;

-- Summary Checkers

-- 1. Cumulative growth sanity
-- Expected:
--   - growth_of_1 >= 0
--   - final value usually > 1 for a positive-return portfolio
SELECT
    MIN(growth_of_1) AS min_growth,
    MAX(growth_of_1) AS max_growth
FROM portfolio_cumulative_returns;

-- 2. Final cumulative value matches total return
-- Expected:
--   growth_of_1 - 1 ≈ total_return
SELECT
    pcr.growth_of_1 - 1 AS implied_total_return,
    ptr.total_return,
    (pcr.growth_of_1 - 1) - ptr.total_return AS difference
FROM portfolio_cumulative_returns pcr
JOIN portfolio_total_return ptr
ORDER BY pcr.date DESC
LIMIT 1;

-- 3. Drawdown sanity
-- Expected:
--   - drawdown <= 0
--   - running_peak >= growth_of_1
SELECT
    MIN(drawdown) AS worst_drawdown,
    MAX(drawdown) AS best_drawdown
FROM portfolio_drawdown;

-- 4. Max drawdown consistency
-- Expected:
--   portfolio_max_drawdown equals minimum drawdown
SELECT
    pmd.max_drawdown,
    pd.recomputed_max_drawdown,
    pmd.max_drawdown - pd.recomputed_max_drawdown AS difference
FROM portfolio_max_drawdown pmd
CROSS JOIN (
    SELECT MIN(drawdown) AS recomputed_max_drawdown
    FROM portfolio_drawdown
) pd;

-- 5. Portfolio key metrics sanity
-- Expected:
--   - daily_volatility > 0
--   - annualized_volatility > daily_volatility
--   - total_return > -1
SELECT *
FROM portfolio_key_metrics;

-- 6. Portfolio vs stocks table integrity
-- Expected:
--   - Exactly one row labeled 'PORTFOLIO'
SELECT
    asset,
    COUNT(*) AS count_rows
FROM portfolio_vs_stocks
GROUP BY asset
HAVING asset = 'PORTFOLIO';

-- 7. Best/Worst performers table integrity
-- Expected:
--   - 10 TOP_10 rows
--   - 10 BOTTOM_10 rows
SELECT
    category,
    COUNT(*) AS num_rows
FROM stock_best_worst_performers
GROUP BY category;

-- 8. Portfolio return magnitude check
-- Expected:
--   - Average portfolio daily return is small (near 0)
SELECT
    AVG(portfolio_return) AS avg_portfolio_return,
    STDDEV(portfolio_return) AS portfolio_volatility
FROM portfolio_daily_returns;