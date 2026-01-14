import pandas as pd
import glob
import os

# Path where your CSV files are located
data = glob.glob("/Users/darren/Downloads/stock_data/stocks/*.csv")

all_dfs = []

for file in data:
    # Extract ticker from filename (AAPL.csv → AAPL)
    stock = os.path.basename(file).replace(".csv", "")
    
    # Read CSV
    df = pd.read_csv(file)
    
    # Standardize column names (recommended)
    df.columns = df.columns.str.strip().str.lower()
    
    # Add ticker column
    df["stock"] = stock
    
    all_dfs.append(df)

# Combine all stocks into one DataFrame
combined_df = pd.concat(all_dfs, ignore_index = True)

# Optional: sort for cleanliness
combined_df.sort_values(["stock", "date"], inplace = True)

# Save combined CSV
combined_df.to_csv(
    "/Users/darren/Downloads/stock_data/combined_stock_data.csv",
    index = False
)