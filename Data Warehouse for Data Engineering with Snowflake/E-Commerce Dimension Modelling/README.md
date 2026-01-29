# E-Commerce Dimensional Data Modeling (Star Schema)

## Overview
This module focuses on **dimensional data modeling** for an e-commerce analytics use case
using the Instacart dataset. It demonstrates how raw transactional data is transformed
into an **analytics-ready star schema** optimized for reporting, BI dashboards, and
ad-hoc analytical queries.

This design follows industry-standard data warehouse modeling practices used in
production analytics systems.

---

## Architecture Context
This dimensional model is part of a larger end-to-end data engineering pipeline built
using **AWS S3** and **Snowflake**.

![Architecture Diagram](../Architecture%20Diagram.png)

---

## Star Schema Design
The data warehouse is modeled using a **star schema** to improve query performance and
simplify analytics.

### Fact Table: `fact_order_product`
- **Grain:** One record per product per order
- **Measures & attributes:**
  - add_to_cart_order
  - reordered
- **Foreign keys:**
  - user_id
  - product_id
  - aisle_id
  - department_id

![Star Schema Design](../Star%20schema%20.png)


---

## Dimension Tables

### `dim_users`
- user_id  
- Represents unique customers placing orders

### `dim_products`
- product_id  
- product_name  
- Product master data

### `dim_aisles`
- aisle_id  
- aisle  
- Logical grouping of products

### `dim_departments`
- department_id  
- department  
- High-level product categorization

### `dim_orders`
- order_id  
- order_number  
- order_dow  
- order_hour_of_day  
- days_since_prior_order  
- Captures order-level behavior

---

## Snowflake Implementation
The dimensional model is implemented using **Snowflake SQL** transformations.

![Snowflake Tables](../snowflake%20tables%20.png)

Key implementation details:
- Raw data loaded from AWS S3 using external stages
- Dimension tables created using `SELECT DISTINCT`
- Fact table built using optimized joins between orders, products, and order line items
- Referential consistency maintained across fact and dimension tables

---

## Analytical Use Cases
This dimensional model enables analytics such as:
- Products ordered by department and aisle
- User purchase frequency and behavior
- Reorder rate and product popularity analysis
- Time-based ordering patterns

---

## Design Rationale
- Star schema chosen for simplicity and performance
- Clear separation of fact and dimension tables
- Scalable design suitable for large datasets
- Optimized for BI tools and SQL-based analytics

---

## Key Takeaways
- Demonstrates real-world dimensional modeling skills
- Aligns with enterprise data warehouse design standards
- Supports scalable and analytics-ready data pipelines
