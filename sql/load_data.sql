-- Create table
CREATE TABLE stock_prices (
    ticker VARCHAR(10),
    date DATE,
    open DECIMAL(10,2),
    high DECIMAL(10,2),
    low DECIMAL(10,2),
    close DECIMAL(10,2),
    volume BIGINT
);

-- Load CSV and match up variables with cols
LOAD DATA LOCAL INFILE '/Users/darren/Downloads/stock_data/combined_stock_data.csv'
INTO TABLE stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(date, open, high, low, close, @adj_close, volume, ticker);

-- Add primary key
ALTER TABLE stock_prices
ADD PRIMARY KEY (ticker, date);