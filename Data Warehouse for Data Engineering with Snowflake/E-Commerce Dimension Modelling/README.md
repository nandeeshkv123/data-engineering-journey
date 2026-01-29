# E-Commerce Dimensional Data Modeling (Star Schema)

## Overview
This module focuses on **dimensional data modeling** for an e-commerce analytics use case.
It demonstrates how raw transactional data is transformed into a **star schema** optimized
for reporting, BI dashboards, and analytical queries.

This modeling approach is aligned with real-world data warehouse design standards used in
enterprise analytics platforms.

---

## Architecture Context
This dimensional model is part of a larger end-to-end data engineering pipeline built using
AWS S3 and Snowflake.

![Architecture Diagram](../architecture.png)

---

## Star Schema Design
The star schema is designed to simplify analytical queries and improve query performance.

### Fact Table
**fact_order_product**
- Grain: One record per product per order
- Measures and attributes:
  - add_to_cart_order
  - reordered
- Foreign keys:
  - user_id
  - product_id
  - aisle_id
  - department_id

![Star Schema Design](../star_schema.png)

---

## Dimension Tables

### dim_users
- user_id
- Represents unique customers placing orders

### dim_products
- product_id
- product_name
- Master data for products

### dim_aisles
- aisle_id
- aisle
- Logical grouping of products

### dim_departments
- department_id
- department
- High-level product categorization

### dim_orders
- order_id
- order_number
- order_dow
- order_hour_of_day
- days_since_prior_order
- Captures order-level behavior

---

## Snowflake Implementation
The dimensional tables are implemented in Snowflake using SQL-based transformations.

![Snowflake Tables](../snowflake.png)

Key implementation highlights:
- Raw tables loaded from AWS S3 using external stages
- Dimensions created using `SELECT DISTINCT`
- Fact table built using joins between orders, products, and order line items
- Referential consistency maintained across tables

---

## Analytical Use Cases
This dimensional model enables analytics such as:
- Products ordered by department or aisle
- User ordering frequency and behavior
- Reorder analysis and product popularity
- Time-based ordering patterns

---

## Design Rationale
- Star schema chosen for simplicity and performance
- Clear separation between fact and dimension tables
- Scalable design suitable for large datasets
- Optimized for BI tools and SQL analytics

---

## Key Takeaways
- Demonstrates practical dimensional modeling skills
- Aligns with industry-standard data warehouse design
- Supports real-world analytics and reporting scenarios
