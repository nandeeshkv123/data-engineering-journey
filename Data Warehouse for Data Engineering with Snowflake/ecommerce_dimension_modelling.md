# Data Engineering Data Warehouse with Snowflake and AWS (Instacart Analytics)

## Overview
This project demonstrates an end-to-end **Data Engineering Data Warehouse** implementation using **AWS S3** and **Snowflake**, built on the publicly available **Instacart dataset from Kaggle**.  
The goal is to design and implement a **scalable, analytics-ready data warehouse** using a **star schema** that supports business intelligence, reporting, and ad-hoc analytics.

This repository is designed to be **recruiter-ready** and clearly communicates architectural decisions, data modeling strategy, and business value to:
- HR Managers  
- Data Engineering Managers  
- Senior Technical Leaders  

---

## Tech Stack
- **Cloud Provider:** AWS  
- **Storage Layer:** Amazon S3  
- **Data Warehouse:** Snowflake  
- **Data Format:** CSV  
- **Modeling Approach:** Star Schema  
- **SQL Engine:** Snowflake SQL  


---

## Architecture & End-to-End Data Flow

### 1. Data Ingestion
- Source data obtained from the **Instacart Market Basket Analysis dataset** on Kaggle.
- Dataset includes orders, products, aisles, departments, and user purchase behavior.

### 2. Raw Data Storage (AWS S3)
- All raw CSV files are uploaded to an **Amazon S3 bucket**.
- S3 acts as the **landing zone / raw layer** in the data architecture.

### 3. Secure Cloud Access (IAM)
- A dedicated **IAM user** is created for Snowflake access.
- Access follows security best practices:
  - Programmatic access only
  - Least-privilege permissions
  - No hardcoded credentials committed to GitHub
- Credentials are conceptually used to allow Snowflake to read data from S3 via an external stage.

### 4. Snowflake External Stage
- An external **Snowflake stage** is created pointing to the S3 bucket.
- This allows Snowflake to load data directly from cloud storage without intermediate compute.

### 5. File Formats & Data Loading
- A reusable **CSV file format** is defined in Snowflake.
- `COPY INTO` commands are used to load data from S3 into Snowflake raw tables.
- This approach is scalable, efficient, and production-aligned.

### 6. Raw → Curated Transformation
- Raw tables represent source-aligned structures.
- Data is transformed into **dimension tables** and a **fact table** using SQL.
- The curated layer follows a **star schema** optimized for analytics.

### 7. Analytics & Insights
- Business-friendly analytical queries are executed on the curated schema.
- The warehouse supports aggregation, slicing, and trend analysis.

---

## Data Modeling Strategy

### Dimension Tables
- **dim_users** – Unique users placing orders  
- **dim_products** – Product master data  
- **dim_aisles** – Aisle-level categorization  
- **dim_departments** – Department-level categorization  
- **dim_orders** – Order-level attributes  

### Fact Table
- **fact_order_product**
  - Grain: One row per product per order
  - Captures user, product, aisle, department, and reorder behavior

### Why Star Schema?
- Simplifies analytical queries
- Optimized for BI tools and reporting
- Reduces join complexity
- Scales efficiently with large fact tables
- Industry-standard design for enterprise data warehouses

---

## SQL & Engineering Implementation

### Snowflake Features Used
- Databases and schemas for logical separation
- External stages for cloud-native ingestion
- File formats for reusable ingestion logic
- `COPY INTO` for bulk data loading
- SQL-based transformations for dimensional modeling

### Raw Layer Tables
- aisles  
- departments  
- products  
- orders  
- order_products  

### Curated Layer Tables
- dim_users  
- dim_products  
- dim_aisles  
- dim_departments  
- dim_orders  
- fact_order_product  

### Fact Table Join Strategy
The fact table is built by joining:
- `order_products` (transactional grain)
- `orders` (user and order context)
- `products` (product, aisle, department attributes)

This ensures:
- Correct grain alignment
- Referential consistency
- Analytics-ready structure

### Example Analytical Query
```sql
SELECT
    d.department,
    COUNT(*) AS total_products_ordered
FROM fact_order_product f
JOIN dim_departments d
    ON f.department_id = d.department_id
GROUP BY d.department
ORDER BY total_products_ordered DESC;
