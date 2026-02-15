"""
Script: load_products.py
Description: ETL (Extract, Transform, Load) process to ingest product data.
             - Reads raw CSV data.
             - Normalizes column names.
             - Loads data into MySQL database securely.
Author: Ivan Ravarotto
Date: 2026-02-14
"""

import os
import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime
from urllib.parse import quote_plus  # <--- CRITICAL: Handles special characters in passwords 🔑

# =========================================
# 1. CONFIGURATION & CREDENTIALS
# =========================================
DB_USER = "root"
DB_PASSWORD_RAW = "Rava-2026@-24" 
DB_HOST = "localhost"
DB_NAME = "TechZone"

# --- PASSWORD ENCODING ---
# We use quote_plus to URL-encode the password. 
# This ensures that special characters (like '@') are interpreted correctly 
# by the connection string and don't break the syntax.
db_password_encoded = quote_plus(DB_PASSWORD_RAW)

# --- CONNECTION STRING BUILDER ---
print("🔌 Connecting to the database...")
# Format: mysql+driver://user:password@host/database
connection_string = f"mysql+mysqlconnector://{DB_USER}:{db_password_encoded}@{DB_HOST}/{DB_NAME}"

try:
    # Create the SQLAlchemy engine (the bridge to MySQL)
    engine = create_engine(connection_string)
    
    # Quick connection health check
    with engine.connect() as connection:
        print("✅ Connection to database successful!")

    # =========================================
    # 2. EXTRACTION (Read Data)
    # =========================================
    print(f"📍 Current directory: {os.getcwd()}")
    
    # We construct the path dynamically using os.path.join.
    # This ensures the script works on both Windows ('\') and Mac/Linux ('/') without errors.
    file_path = os.path.join(os.getcwd(), "data_raw", "products.csv")

    print(f"📂 Searching for file in: {file_path}")

    # Validation: Check if file exists before trying to read it
    if not os.path.exists(file_path):
        print(f"⚠️ File not found. Files visible in 'data_raw': {os.listdir(os.path.join(os.getcwd(), 'data_raw'))}")
        raise FileNotFoundError("Check that the filename is exactly: 'products.csv'")

    # Read the CSV file into a Pandas DataFrame
    df = pd.read_csv(file_path)
    
    # =========================================
    # 3. TRANSFORMATION (Clean & Prepare)
    # =========================================
    # Best Practice: Remove potential whitespace from column headers
    df.columns = df.columns.str.strip()

    # Add audit timestamp if it doesn't exist in the source file
    if 'product_datetime' not in df.columns:
        df['product_datetime'] = datetime.now()

    # =========================================
    # 4. LOAD (Write to Database)
    # =========================================
    print(f"📊 Loading {len(df)} products to MySQL...")
    
    # to_sql parameters:
    # - name: Target table name in MySQL
    # - if_exists='append': Adds new rows without deleting the table (safe mode)
    # - index=False: Prevents Pandas from uploading the DataFrame index as a separate column
    df.to_sql('product', con=engine, if_exists='append', index=False)
    
    print("🚀 Mission accomplished! Data successfully inserted into 'product' table.")

except Exception as e:
    # Error handling to provide clear feedback
    print(f"\n❌ FATAL ERROR: {e}")
    print("Tip: If the error is 'Access denied', verify your password in MySQL Workbench.")