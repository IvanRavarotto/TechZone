import os
import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime
from urllib.parse import quote_plus  # <--- CRITICAL: Handles special characters in passwords 🔑

# --- CONFIGURATION ---
DB_USER = "root"
DB_PASSWORD_RAW = "Rava-2026@-24" 
DB_HOST = "localhost"
DB_NAME = "TechZone"

# --- PASSWORD ENCODING ---
# We encode the password to ensure special characters (like @) don't break the connection string
db_password_encoded = quote_plus(DB_PASSWORD_RAW)

# --- CONNECTION STRING ---
print("🔌 Connecting to the database...")
connection_string = f"mysql+mysqlconnector://{DB_USER}:{db_password_encoded}@{DB_HOST}/{DB_NAME}"

try:
    engine = create_engine(connection_string)
    
    # Quick connection test before continuing
    with engine.connect() as connection:
        print("✅ Connection to database successful!")

    # --- READING CSV ---
    print(f"📍 Current directory: {os.getcwd()}")
    
    # We construct the path dynamically to avoid errors
    file_path = os.path.join(os.getcwd(), "data_raw", "products.csv")

    print(f"📂 Searching for file in: {file_path}")

    if not os.path.exists(file_path):
        # If it fails, we show which files ARE visible to help debug
        print(f"⚠️ File not found. Files in 'data_raw': {os.listdir(os.path.join(os.getcwd(), 'data_raw'))}")
        raise FileNotFoundError("Check that the filename is exactly: 'products.csv'")

    df = pd.read_csv(file_path)
    
    # Clean column names (remove extra spaces)
    df.columns = df.columns.str.strip()

    # --- TRANSFORMATION ---
    # Add timestamp if it doesn't exist in the source file
    if 'product_datetime' not in df.columns:
        df['product_datetime'] = datetime.now()

    # --- LOAD ---
    print(f"📊 Loading {len(df)} products...")
    
    # if_exists='append': Adds data without deleting the table
    # index=False: Prevents pandas from uploading the row number as a column
    df.to_sql('product', con=engine, if_exists='append', index=False)
    
    print("🚀 Mission accomplished! Data inserted into 'product' table.")

except Exception as e:
    print(f"\n❌ FATAL ERROR: {e}")
    print("Tip: If the error is 'Access denied', verify your password in MySQL Workbench.")