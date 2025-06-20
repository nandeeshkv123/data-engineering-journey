-- ====================================================
-- 📌 REAL-WORLD SQL MASTER SCENARIOS — ALL IN ONE
-- Author: nandeeshkv123 | DataEngineerJourney
-- ====================================================

-- ============================
-- ✅ SECTION 1: BASIC SELECTS
-- ============================

-- 1.1 Select all rows
SELECT * FROM employees;

-- 1.2 Select specific columns
SELECT employee_id, first_name, last_name, department_id FROM employees;

-- 1.3 Filter with WHERE
SELECT * FROM employees WHERE department_id = 10;

-- 1.4 Sort results
SELECT employee_id, salary FROM employees ORDER BY salary DESC;

-- 1.5 Limit rows
SELECT * FROM employees LIMIT 5;

-- ================================
-- ✅ SECTION 2: AGGREGATES & GROUP BY
-- ================================

-- 2.1 Count employees per department
SELECT department_id, COUNT(*) AS num_employees
FROM employees
GROUP BY department_id;

-- 2.2 Average salary per department
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;

-- 2.3 Total sales per month
SELECT DATE_TRUNC('month', sale_date) AS sale_month,
       SUM(amount) AS total_sales
FROM sales
GROUP BY sale_month
ORDER BY sale_month;

-- ===========================
-- ✅ SECTION 3: JOINS
-- ===========================

-- 3.1 INNER JOIN: Employees with department names
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- 3.2 LEFT JOIN: Orders and missing shipments
SELECT o.order_id, s.shipment_id
FROM orders o
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE s.shipment_id IS NULL;

-- ================================
-- ✅ SECTION 4: WINDOW FUNCTIONS
-- ================================

-- 4.1 Rank employees by salary in each department
SELECT employee_id, department_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM employees;

-- 4.2 Running total of daily revenue
SELECT sale_date, amount,
       SUM(amount) OVER (ORDER BY sale_date) AS running_total
FROM sales;

-- ===============================
-- ✅ SECTION 5: SUBQUERIES & CTEs
-- ===============================

-- 5.1 Employees earning above average salary
SELECT employee_id, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 5.2 Second highest salary
SELECT MAX(salary) AS second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- 5.3 CTE: Average salary then filter
WITH avg_sal AS (
    SELECT AVG(salary) AS avg_salary FROM employees
)
SELECT employee_id, salary
FROM employees, avg_sal
WHERE salary > avg_salary;

-- ======================================
-- ✅ SECTION 6: CASE, PIVOT & REPORTING
-- ======================================

-- 6.1 CASE WHEN: Tag salaries
SELECT employee_id, salary,
       CASE WHEN salary < 40000 THEN 'Low'
            WHEN salary BETWEEN 40000 AND 80000 THEN 'Medium'
            ELSE 'High'
       END AS salary_band
FROM employees;

-- 6.2 PIVOT: Monthly sales per region (syntax depends on DB)
-- Example: crosstab for PostgreSQL
-- Install tablefunc extension first
-- SELECT * FROM crosstab(
--   'SELECT region, EXTRACT(MONTH FROM sale_date), SUM(amount) FROM sales GROUP BY region, EXTRACT(MONTH FROM sale_date)',
--   'SELECT generate_series(1,12)'
-- ) AS ct(region TEXT, jan NUMERIC, feb NUMERIC, ...);

-- ================================
-- ✅ SECTION 7: DATA QUALITY CHECKS
-- ================================

-- 7.1 Duplicates
SELECT email, COUNT(*) FROM users
GROUP BY email HAVING COUNT(*) > 1;

-- 7.2 Null checks
SELECT * FROM customers WHERE email IS NULL;

-- 7.3 Negative or invalid values
SELECT * FROM products WHERE price < 0;

-- ====================================
-- ✅ SECTION 8: PERFORMANCE & TUNING
-- ====================================

-- 8.1 Explain query plan (PostgreSQL example)
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 123;

-- 8.2 Add an index
CREATE INDEX idx_customer_id ON orders(customer_id);

-- ====================================
-- ✅ SECTION 9: ADMIN TASKS
-- ====================================

-- 9.1 Check table sizes
-- For PostgreSQL:
SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- 9.2 Count rows in all tables
SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = 'public';

-- ====================================
-- ✅ SECTION 10: ADVANCED SCENARIOS
-- ====================================

-- 10.1 Retention: users active on signup + day 7
-- Example idea, adjust columns:
SELECT user_id FROM activity WHERE activity_date = signup_date
INTERSECT
SELECT user_id FROM activity WHERE activity_date = signup_date + INTERVAL '7 days';

-- 10.2 Deduplicate: keep latest record per user
SELECT *
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY updated_at DESC) AS rn
  FROM users
) t
WHERE rn = 1;

-- 10.3 Outliers: Sales > 2x average
SELECT * FROM sales
WHERE amount > 2 * (SELECT AVG(amount) FROM sales);

-- ====================================
-- ✅ END OF FILE — CONGRATS!
-- ====================================










✅ 🎯 REAL-WORLD SQL MASTER SCENARIOS — ALL IN ONE
Below are practical examples you must know.
Each shows how real companies use SQL for reporting, analytics, ETL, and troubleshooting.
Read + tweak + run with your own test data.

📌 1️⃣ Core Data Retrieval — Always Asked
Scenario	Sample Query
✅ Get active customers who purchased in last 30 days  
=> 	 SELECT customer_id, name FROM customers WHERE last_purchase_date >= CURRENT_DATE - INTERVAL '30 days';
✅ Find top 10 best-selling products by revenue	
=>  SELECT product_id, SUM(amount) AS total_revenue FROM orders GROUP BY product_id ORDER BY total_revenue DESC LIMIT 10;
✅ Get orders placed on weekends	
=> SELECT order_id, order_date FROM orders WHERE EXTRACT(DOW FROM order_date) IN (0, 6);

📌 2️⃣ Business KPIs — Dashboards Use
Scenario	Sample Query
✅ Monthly revenue trend for last 12 months 
=> SELECT DATE_TRUNC('month', order_date) AS month, SUM(amount) AS revenue FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '12 months' GROUP BY month ORDER BY month;
✅ Conversion rate: leads vs actual buyers	
=> SELECT COUNT(DISTINCT lead_id) AS total_leads, COUNT(DISTINCT customer_id) AS buyers, 100.0 * COUNT(DISTINCT customer_id)/COUNT(DISTINCT lead_id) AS conversion_rate FROM leads LEFT JOIN orders ON leads.lead_id = orders.lead_id;
✅ Average basket size per user	
=> SELECT customer_id, SUM(amount)/COUNT(order_id) AS avg_basket_size FROM orders GROUP BY customer_id;

📌 3️⃣ Joins — Real World Lookups
Scenario	Sample Query
✅ Show each order with customer name & region
	=> SELECT o.order_id, o.amount, c.name, r.region_name FROM orders o JOIN customers c ON o.customer_id = c.customer_id JOIN regions r ON c.region_id = r.region_id;
✅ Orders with missing shipments (LEFT JOIN)
	=> SELECT o.order_id, s.shipment_id FROM orders o LEFT JOIN shipments s ON o.order_id = s.order_id WHERE s.shipment_id IS NULL;

📌 4️⃣ Data Quality Checks — Real ETL
Scenario	Sample Query
✅ Find duplicate emails in user table	
=> SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;
✅ Check for negative prices (bad data)
 => SELECT * FROM products WHERE price < 0;
✅ Null check for mandatory fields	
=> SELECT * FROM customers WHERE email IS NULL;

📌 5️⃣ Window Functions — Real Analytics
Scenario	Sample Query
✅ Rank customers by total spend	
=> SELECT customer_id, SUM(amount) AS total_spend, RANK() OVER (ORDER BY SUM(amount) DESC) AS spend_rank FROM orders GROUP BY customer_id;
✅ Running total of daily revenue
=> SELECT order_date, amount, SUM(amount) OVER (ORDER BY order_date) AS running_revenue FROM orders;
✅ Compare each day’s revenue to previous day	
=>  SELECT order_date, amount, LAG(amount, 1) OVER (ORDER BY order_date) AS previous_day, amount - LAG(amount, 1) OVER (ORDER BY order_date) AS daily_diff FROM daily_revenue;

📌 6️⃣ Nested Queries — Real Tasks
Scenario	Sample Query
✅ Find products costing above average	
=> SELECT product_id, price FROM products WHERE price > (SELECT AVG(price) FROM products);
✅ Find employees earning more than department average	
=>  SELECT e.employee_id, e.salary, e.department_id FROM employees e WHERE e.salary > (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id);

📌 7️⃣ Complex CASE & PIVOT — Reporting
Scenario	Sample Query
✅ Tag orders as High/Medium/Low value	
=> SELECT order_id, amount, CASE WHEN amount >= 1000 THEN 'High' WHEN amount >= 500 THEN 'Medium' ELSE 'Low' END AS order_value_band FROM orders;
✅ Pivot monthly sales per product	(PostgreSQL crosstab example)

📌 8️⃣ Real-Time Troubleshooting — Ad Hoc
Scenario	Sample Query
✅ Find orders stuck in 'Processing' for over 3 days	
=>  SELECT order_id, status, order_date FROM orders WHERE status = 'Processing' AND order_date < CURRENT_DATE - INTERVAL '3 days';
✅ Slow query: Find missing indexes (Postgres example)	
=>  EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 123; (then check the query plan for Seq Scan)

📌 9️⃣ Common Admin & Debug
Scenario	Sample Query
✅ How many rows in each table	
=> SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = 'public';
✅ Size of a table	
=> SELECT pg_size_pretty(pg_total_relation_size('orders'));
✅ Get top 5 biggest tables	
=> SELECT relname AS table_name, pg_size_pretty(pg_total_relation_size(relid)) AS size FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC LIMIT 5;

📌 10️⃣ Real DDL + Views + Index — Production Use
Scenario	Sample SQL
✅ Create table
 => CREATE TABLE sales (id SERIAL PRIMARY KEY, customer_id INT, amount DECIMAL, sale_date DATE);
✅ Add index for faster queries	
=> CREATE INDEX idx_customer_id ON sales(customer_id);
✅ Create a reusable view	
=> CREATE VIEW monthly_revenue AS SELECT DATE_TRUNC('month', sale_date) AS month, SUM(amount) FROM sales GROUP BY month;

✅ ✅ BONUS: 5 PRO INTERVIEW TASKS
✅ Write SQL to deduplicate a table: keep only latest record per user
✅ Write SQL to calculate retention: users active on signup + 7th day
✅ Write SQL to identify outliers: sales 2x higher than average
✅ Write SQL to calculate % growth month over month
✅ Write SQL to flatten nested JSON or arrays (Postgres: jsonb_each, unnest)


