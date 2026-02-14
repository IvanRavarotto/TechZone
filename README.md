# 🧑‍💻 Project TechZone: End-to-End Data Engineering Pipeline

## 🎯 Project Objective
**TechZone** is a comprehensive data management project designed to simulate a real-world retail environment. The goal is to build a complete data pipeline demonstrating proficiency in the **Modern Data Stack**, resolving information fragmentation through automation and structured design.

Key pillars of the project:
- **ETL (Extract, Transform, Load):** Developed Python scripts using **Pandas** and **SQLAlchemy** to clean, normalize, and load raw CSV data into a relational database.
- **Data Modeling:** Designed a robust **3NF (Third Normal Form)** SQL schema to ensure data integrity and query performance.
- **Automation & Security:** Implemented robust error handling and secure credential management for database connections.
- **Reporting (Upcoming):** Interactive **Power BI** dashboard for real-time metrics (Sales, Margins, Top Products).

## 🛠️ Tools & Technologies
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) 
![SQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white) 
![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white) 
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-D71F00?style=for-the-badge&logo=sqlalchemy&logoColor=white) 
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=power-bi&logoColor=black)

## 📂 Project Architecture
The project is organized to separate raw data, logic, and database definitions:

```text
📂 TechZone
├── 📁 data_raw         # Raw data sources (CSV/Excel)
├── 📁 etl_scripts      # Python scripts for ETL automation (Pandas/SQLAlchemy)
├── 📁 sql_db           # SQL scripts (DDL, Triggers, Stored Procedures)
└── 📄 README.md        # Project documentation
```
## ⚡ Key Features Implemented
1. Database Engineering (SQL)
Schema Design: Created tables for CLIENT, PRODUCT, SALE, and SALE_DETAIL enforcing relational integrity (Foreign Keys).

Audit System: Dedicated AUDIT_PRICE table to track historical price changes.

Data Types: Strict use of DECIMAL(10,2) for financial precision and DATETIME for temporal tracking.

2. Python ETL Pipeline
Dynamic Path Handling: Utilized os module to ensure the script runs on any operating system without path errors.

Secure Connections: Implemented urllib.parse.quote_plus to safely handle complex database passwords with special characters.

Data Transformation: Automated generation of timestamps and data type validation before loading to MySQL.

Idempotency: The script uses if_exists='append' logic to manage data ingestion.

## 🗄️ Database Design
Logic & Schema
The database follows a relational model optimized for retail transactions:

Independent Tables: CLIENT, PRODUCT (Master Data).

Transactional Tables: SALE (Header), SALE_DETAIL (Lines).

Triggers: Automated mechanisms to capture price updates (In Progress).

Schema Diagram
<div align="center">
<img src="docs/TechZone_version_3.jpg" alt="Database Diagram" width="600px">
</div>

(Note: The diagram represents the conceptual model. The physical implementation in MySQL includes additional audit tables.)

## 🚀 How to Run locally
1. Clone the repository: <br>
  ```git clone [https://github.com/IvanRavarotto/TechZone.git](https://github.com/IvanRavarotto/TechZone.git)```
2. Database Setup:
     * Execute sql_db/01_create_tables.sql in MySQL Workbench to create the schema.
3. Python Environment:
    ```
    # Create virtual env
    python -m venv .venv
    source .venv/bin/activate  # or .\.venv\Scripts\Activate in Windows

    ### Install dependencies
    pip install pandas sqlalchemy mysql-connector-python
    ```
4. Run ETL:
    ```python etl_scripts/load_products.py```

Author: Ivan Ravarotto