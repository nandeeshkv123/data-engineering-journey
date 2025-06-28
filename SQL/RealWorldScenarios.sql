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


----------------------------------------------
-- ✅ Drop if exists (safe)
IF OBJECT_ID('tempdb..#Orders') IS NOT NULL DROP TABLE #Orders;
IF OBJECT_ID('tempdb..#Customers') IS NOT NULL DROP TABLE #Customers;
IF OBJECT_ID('tempdb..#Employees') IS NOT NULL DROP TABLE #Employees;

----------------------------------------------
-- ✅ Create Orders
CREATE TABLE #Orders (
    OrderID INT,
    CustomerID INT,
    OrderDate DATE,
    OrderAmount DECIMAL(10,2),
    Region VARCHAR(50)
);

-- ✅ Create Customers
CREATE TABLE #Customers (
    CustomerID INT,
    Name VARCHAR(50)
);

-- ✅ Create Employees
CREATE TABLE #Employees (
    EmpID INT,
    EmpName VARCHAR(50),
    Department VARCHAR(50),
    Salary INT
);

----------------------------------------------
-- ✅ Insert sample Orders
INSERT INTO #Orders (OrderID, CustomerID, OrderDate, OrderAmount, Region)
VALUES 
(1, 101, '2024-01-01', 500, 'North'),
(2, 102, '2024-01-02', 2000, 'South'),
(3, 101, '2024-01-10', 300, 'North'),
(4, 103, '2024-02-01', 1500, 'West'),
(5, 102, '2024-02-05', 2500, 'South');

----------------------------------------------
-- ✅ Insert sample Customers
INSERT INTO #Customers (CustomerID, Name)
VALUES 
(101, 'Alice'),
(102, 'Bob'),
(103, 'Charlie'),
(104, 'David'); -- extra: no orders

----------------------------------------------
-- ✅ Insert sample Employees
INSERT INTO #Employees (EmpID, EmpName, Department, Salary)
VALUES 
(1, 'John', 'HR', 60000),
(2, 'Jane', 'HR', 70000),
(3, 'Mike', 'IT', 80000),
(4, 'Sara', 'IT', 90000),
(5, 'Alex', 'IT', 95000);


SELECT * FROM #Orders;
SELECT * FROM #Customers;
SELECT * FROM #Employees;

--  PATTERN #1 — Group By + Having   and HAVING works on aggregates, WHERE doesn’t."
SELECT 
  CustomerID,
  SUM(OrderAmount) AS TotalSpent
FROM 
  #Orders
GROUP BY 
  CustomerID
HAVING 
  SUM(OrderAmount) > 2000;


INSERT INTO #Orders (OrderID, CustomerID, OrderDate, OrderAmount, Region)
VALUES (6, 101, '2024-03-01', 3000, 'North');

--re run
SELECT 
  CustomerID,
  SUM(OrderAmount) AS TotalSpent
FROM 
  #Orders
GROUP BY 
  CustomerID
HAVING 
  SUM(OrderAmount) > 2000;

  --"Show each customer's name and how much they have spent in total."
  SELECT 
  c.Name,
  SUM(o.OrderAmount) AS TotalSpent
FROM 
  #Customers c
JOIN 
  #Orders o
ON 
  c.CustomerID = o.CustomerID
GROUP BY 
  c.Name;

 --  Try this:
--Add a customer CustomerID = 105, Name = 'Eve' but no orders.

--Does Eve appear in the result? (Should NOT, because it’s INNER JOIN)

  -- ✅ Insert sample Customers
INSERT INTO #Customers (CustomerID, Name)
VALUES 
(105, 'Eve')

  SELECT 
  c.Name,
  SUM(o.OrderAmount) AS TotalSpent
FROM 
  #Customers c
JOIN 
  #Orders o
ON 
  c.CustomerID = o.CustomerID
GROUP BY 
  c.Name;


  --"Find all customers who NEVER placed an order."
  --LEFT JOIN + IS NULL trick
  SELECT 
  c.CustomerID,
  c.Name,
  o.OrderAmount
FROM 
  #Customers c
LEFT JOIN 
  #Orders o
ON 
  c.CustomerID = o.CustomerID
WHERE 
  o.OrderID IS NULL;

  INSERT INTO #Customers (CustomerID, Name) VALUES (106, 'Frank');
  --Re-run above query — Frank should appear.


--PATTERN #4 — Find Duplicates
--Show orders where a customer placed more than one order on the same day — possible duplicate or fraud."
--GROUP BY + HAVING COUNT > 1

SELECT 
  CustomerID,
  OrderDate,
  COUNT(*) AS OrderCount
FROM 
  #Orders
GROUP BY 
  CustomerID, OrderDate
HAVING 
  COUNT(*) > 1;  -- --output was no duplicate

 
--insert duplicate record
  INSERT INTO #Orders (OrderID, CustomerID, OrderDate, OrderAmount, Region)
VALUES (7, 101, '2024-01-01', 1000, 'North');    -- when re-run above query you see duplicate 


--PATTERN #5 — Running Total
--OVER (ORDER BY ...)
--Show a daily cumulative revenue chart — common in BI reports, dashboards, and forecasting.
SELECT 
  OrderID,
  OrderDate,
  OrderAmount,
  SUM(OrderAmount) OVER (ORDER BY OrderDate) AS RunningTotal
FROM 
  #Orders
ORDER BY 
  OrderDate;



  -- Suppose OrderID 1 is '2024-01-01' with ₹500.
-- Let’s change it to ₹1500.
UPDATE #Orders
SET OrderAmount = 1500
WHERE OrderID = 1;

-- See how adding an earlier date affects the cumulative order.
INSERT INTO #Orders (OrderID, CustomerID, OrderDate, OrderAmount, Region)
VALUES (8, 101, '2023-12-31', 2000, 'North');

SELECT 
  OrderID,
  OrderDate,
  OrderAmount,
  SUM(OrderAmount) OVER (ORDER BY OrderDate) AS RunningTotal
FROM 
  #Orders
ORDER BY 
  OrderDate;   
  -- o/p => Running totals use ORDER BY inside OVER(). Any change to data or row order instantly updates the output. This is why proper ordering is critical for accurate financial and time-based reports.


-- PATTERN #6 — Rank Top N per Group
--Show top 2 biggest orders for each customer.

 --Why companies ask:
--Checks if you know ROW_NUMBER() OVER (PARTITION BY...)

--Real reports for top products, top sales, top performers

SELECT 
  OrderID,
  CustomerID,
  OrderAmount,
  ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderAmount DESC) AS rn
FROM 
  #Orders;

  -- To filter top 2:
  SELECT * FROM (
  SELECT 
    OrderID,
    CustomerID,
    OrderAmount,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderAmount DESC) AS rn
  FROM 
    #Orders
) sub
WHERE rn <= 2;

INSERT INTO #Orders (OrderID, CustomerID, OrderDate, OrderAmount, Region)
VALUES (9, 101, '2024-03-10', 6000, 'North');  --Re-run above query → only top 2 per customer appear!
--I use ROW_NUMBER with PARTITION BY to rank within each customer group. Wrapping in a subquery filters for the top N rows — highly useful for leaderboards and best-sellers."

 --PATTERN #7 — Pivot (Rows → Columns)
 --Show total order amount per Region — each region as a column for easy reporting

  --Why companies ask:
--Checks if you know conditional aggregation

--Common in Power BI & dashboards

SELECT 
  SUM(CASE WHEN Region = 'North' THEN OrderAmount ELSE 0 END) AS NorthTotal,
  SUM(CASE WHEN Region = 'South' THEN OrderAmount ELSE 0 END) AS SouthTotal,
  SUM(CASE WHEN Region = 'West' THEN OrderAmount ELSE 0 END) AS WestTotal
FROM 
  #Orders;

  -- pivot by CustomerID for fun:  -- works good when things are static -- like int his case if any new region comes then reports fail as we didnt include new region
  SELECT 
  CustomerID,
  SUM(CASE WHEN Region = 'North' THEN OrderAmount ELSE 0 END) AS NorthTotal,
  SUM(CASE WHEN Region = 'South' THEN OrderAmount ELSE 0 END) AS SouthTotal,
  SUM(CASE WHEN Region = 'West' THEN OrderAmount ELSE 0 END) AS WestTotal,
  SUM(CASE WHEN Region = 'East' THEN OrderAmount ELSE 0 END) AS EastTotal
FROM 
  #Orders
GROUP BY 
  CustomerID;
--I often use CASE WHEN + SUM to pivot data because it works across any database engine, is easy to read, and integrates well in BI reports. The PIVOT keyword is fine for simple cases but not always flexible for custom logic

--How experts handle DYNAMIC PIVOTS
DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

-- Step 1: Build a comma-separated list of Regions
SELECT 
  @cols = STRING_AGG(QUOTENAME(Region), ',')   ---STRING_AGG + QUOTENAME generates [North],[South],[West] dynamically.
FROM 
  (SELECT DISTINCT Region FROM #Orders) AS t;

-- Step 2: Build the dynamic pivot query
SET @sql = '
SELECT ' + @cols + '
FROM 
(
  SELECT Region, OrderAmount
  FROM #Orders
) AS src
PIVOT 
(
  SUM(OrderAmount)
  FOR Region IN (' + @cols + ')
) AS pvt;';

-- Step 3: Run it!
EXEC sp_executesql @sql;


--ADD Region = 'East'
INSERT INTO #Orders (OrderID, CustomerID, OrderDate, OrderAmount, Region)
VALUES (10, 101, '2024-04-01', 4000, 'East');


--✅ When to use each
--Where	Pivot Type	How it updates
--SQ                       |  Static Pivot or Dynamic Pivot    	   | Dynamic needs Dynamic SQL, you code it.
--Power                    |  Query Editor	Manual Pivot Column	   | You must click it, new values don’t auto-show unless refreshed.
--Power BI Visual (Matrix) |  Dynamic Pivot	                       | Fully automatic, new values appear after data refresh.



--✅ Self Join — used all the time in real-world data engineering & reporting.
--📌 1️⃣ What is a Self Join?
--👉 A Self Join is when you join a table to itself.

--It helps when you want to compare one row with another row in the same table.

--Classic examples:

--Find manager & employee in the same Employee table

--Compare an order with the previous order

--Find duplicate or related rows

--| EmployeeID | EmployeeName | ManagerID |
--| ---------- | ------------ | --------- |
--| 1          | Alice        | NULL      |
--| 2          | Bob          | 1         |
--| 3          | Charlie      | 1         |
--| 4          | Dave         | 2         |

--👉 Here:

--Alice is the top boss (no manager)

--Bob & Charlie report to Alice

--Dave reports to Bob

--📌 3️⃣ Goal:
--👉 Find each employee’s manager name.

--You need to join the Employee table to itself:

--One copy = Employee

--One copy = Manager


-- Create temp table
IF OBJECT_ID('tempdb..#Employee') IS NOT NULL DROP TABLE #Employee;

CREATE TABLE #Employee (
  EmployeeID INT,
  EmployeeName NVARCHAR(50),
  ManagerID INT
);

INSERT INTO #Employee VALUES
(1, 'Alice', NULL),
(2, 'Bob', 1),
(3, 'Charlie', 1),
(4, 'Dave', 2);

-- Self Join: Employee joins to Manager (same table!)
SELECT 
  e.EmployeeID,
  e.EmployeeName,
  m.EmployeeName AS ManagerName
FROM 
  #Employee e
  LEFT JOIN #Employee m ON e.ManagerID = m.EmployeeID;    --LEFT JOIN makes sure you keep employees even if they have no manager.

--  | EmployeeID | EmployeeName | ManagerName |
--| ---------- | ------------ | ----------- |
--| 1          | Alice        | NULL        |
--| 2          | Bob          | Alice       |
--| 3          | Charlie      | Alice       |
--| 4          | Dave         | Bob         |

-------------------------------------------------------------------------------------------------------------------


-- Find “previous row” by date
--✅ What does it mean?
--👉 Suppose you have transactions for a customer, ordered by date:

--| TransactionID | CustomerID | TxnDate    | Amount |
--| ------------- | ---------- | ---------- | ------ |
--| 1             | 101        | 2024-01-01 | 1000   |
--| 2             | 101        | 2024-01-05 | 1200   |
--| 3             | 101        | 2024-01-10 | 1500   |


--✅ Task: For each row, find the previous transaction amount.

-- Sample transactions
IF OBJECT_ID('tempdb..#Txn') IS NOT NULL DROP TABLE #Txn;

CREATE TABLE #Txn (
  TransactionID INT,
  CustomerID INT,
  TxnDate DATE,
  Amount DECIMAL(10,2)
);

INSERT INTO #Txn VALUES
(1, 101, '2024-01-01', 1000),
(2, 101, '2024-01-05', 1200),
(3, 101, '2024-01-10', 1500);

-- Self Join to get previous txn
SELECT 
  t1.TransactionID,
  t1.TxnDate,
  t1.Amount,
  MAX(t2.TxnDate) AS PrevTxnDate,
  MAX(t2.Amount) AS PrevAmount
FROM 
  #Txn t1
  LEFT JOIN #Txn t2
    ON t1.CustomerID = t2.CustomerID
    AND t2.TxnDate < t1.TxnDate
GROUP BY 
  t1.TransactionID, t1.TxnDate, t1.Amount;

--  Better way: Window Function
--Modern SQL supports LAG():
  SELECT
  TransactionID,
  TxnDate,
  Amount,
  LAG(Amount) OVER (PARTITION BY CustomerID ORDER BY TxnDate) AS PrevAmount
FROM 
  #Txn; -- LAG() automatically looks backward by 1 row — same logic, no join needed.Faster, simpler, cleaner!


  --duplicate clusters — matching on some fields
--  You want to find all duplicates:
--Same CustomerID + OrderDate.


--using Self Join

  SELECT 
  a.OrderID AS Order1,
  b.OrderID AS Order2,
  a.CustomerID,
  a.OrderDate
FROM 
  #Orders a
  JOIN #Orders b 
    ON a.CustomerID = b.CustomerID 
    AND a.OrderDate = b.OrderDate
    AND a.OrderID < b.OrderID;
	--select * from  #Orders

--✅ Better way: COUNT + Window

SELECT 
  *,
  COUNT(*) OVER (PARTITION BY CustomerID, OrderDate) AS DuplicateCount
FROM 
  #Orders;
--Then filter where DuplicateCount > 1.

--✅ Faster than a self join.

--| Use case              | Old style | Modern            |
--| --------------------- | --------- | ----------------- |
--| Get previous row      | Self Join | `LAG()`           |
--| Find duplicate groups | Self Join | `COUNT() OVER ()` |


--📌 5️⃣ How to safely remove accidental duplicates
--Good method:
--1️⃣ Identify rows with same CustomerID + OrderDate + Amount.
--2️⃣ Keep only one — delete extra.

--Example:

WITH CTE AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY CustomerID, OrderDate, Amount ORDER BY OrderID) AS rn
  FROM 
    #Orders
)
DELETE FROM CTE WHERE rn > 1;
--✅ This keeps the first occurrence, removes accidental repeats.


-- Awesome — buckle up! I’ll give you a real-world, foolproof “duplicate detection & cleanup” toolkit that data engineers actually use in big companies.

--✅ 📌 1️⃣ Scenario: Orders table with possible duplicates
--Let’s build an example:

 Clean slate
IF OBJECT_ID('tempdb..#Orders') IS NOT NULL DROP TABLE #Orders;

CREATE TABLE #Orders (
  OrderID INT,
  CustomerID INT,
  OrderDate DATE,
  Amount DECIMAL(10,2)
);

INSERT INTO #Orders VALUES
(1, 101, '2024-06-20', 1200),   -- Good
(2, 101, '2024-06-20', 700),    -- Good
(3, 101, '2024-06-20', 1200),   -- Exact duplicate of OrderID 1
(4, 102, '2024-06-21', 900),    -- Good
(5, 102, '2024-06-21', 900);    -- Exact duplicate of OrderID 4



--👉 Here:

--OrderID 1 and 3: same customer, same date, same amount — so suspect duplicate.

--OrderID 4 and 5: same story.

--✅ 📌 2️⃣ Detect duplicates properly
--👉 Use all key columns except the unique key (OrderID).


SELECT 
  CustomerID,
  OrderDate,
  Amount,
  COUNT(*) AS HowMany
FROM 
  #Orders
GROUP BY 
  CustomerID, OrderDate, Amount
HAVING COUNT(*) > 1;

--✅ Result: shows you which combinations are repeated.

--✅ 📌 3️⃣ See exactly which rows are duplicates
--👉 Use ROW_NUMBER to number them within each group.


SELECT 
  *,
  ROW_NUMBER() OVER (
    PARTITION BY CustomerID, OrderDate, Amount 
    ORDER BY OrderID
  ) AS rn
FROM 
  #Orders;

--| OrderID | CustomerID | OrderDate  | Amount | rn |
--| ------- | ---------- | ---------- | ------ | -- |
--| 1       | 101        | 2024-06-20 | 1200   | 1  |
--| 3       | 101        | 2024-06-20 | 1200   | 2  |
--| 2       | 101        | 2024-06-20 | 700    | 1  |
--| 4       | 102        | 2024-06-21 | 900    | 1  |
--| 5       | 102        | 2024-06-21 | 900    | 2  |



--✅ The ones with rn = 2, 3, … are duplicates — keep rn = 1, delete the rest!

--✅ 📌 4️⃣ Delete only extra rows (safe way)
--👉 Use a CTE for this — standard & safe!

WITH CTE AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (
      PARTITION BY CustomerID, OrderDate, Amount 
      ORDER BY OrderID
    ) AS rn
  FROM 
    #Orders
)
DELETE FROM CTE WHERE rn > 1;
--✅ Now:

--Original + valid rows remain

--Extra copies are gone

--No impact on valid multiple orders that differ in Amount or Items.

--✅ 📌 5️⃣ Double check: Did it work?

SELECT * FROM #Orders;
--You should see only:



--✅ Clean and safe!

--✅ 📌 6️⃣ How to prevent this in future
--👉 Pro tip:
--Design your table with a unique key or constraint!

--Example:


ALTER TABLE #Orders
ADD CONSTRAINT UQ_CustomerDateAmount UNIQUE (CustomerID, OrderDate, Amount);
--Now, any accidental insert of exact duplicate fails with error.
--Best practice in production.

--✅ 📌 7️⃣ What to say in an interview
--“To remove duplicates safely, I use ROW_NUMBER over key columns, keep the first occurrence, and delete the rest. For future prevention, I add a UNIQUE constraint or deduplication logic in ETL. This guarantees data quality and avoids hidden errors in reports.”


--data governance techniques
--📌 1️⃣ What does “fix using MERGE or UPDATE logic” mean?
--👉 Suppose you have duplicate or conflicting records — instead of deleting, you might want to merge them into a single clean record or update fields based on some rule.

--✅ Example Scenario
--Let’s say this is your messy customer table:

--| CustomerID | Name   | Email                                   | Phone      | CreatedDate |
--| ---------- | ------ | --------------------------------------- | ---------- | ----------- |
--| 1          | John   | [john@email.com](mailto:john@email.com) | 9999999999 | 2024-06-01  |
--| 2          | John A | [john@email.com](mailto:john@email.com) | NULL       | 2024-06-02  |

--👉 Here:
--Same email → probably the same customer.

--Two rows → conflicting name & phone.

--✅ Solution: Fix by MERGE
--Goal:

--Keep only one row.

--Use the best info (e.g., newer name, latest phone).

--In SQL Server you’d:
--1️⃣ Load “good” data into a staging table.
--2️⃣ MERGE staging data into the clean Customer table.

Example:

-- Assume #CleanCustomer is empty, and #Staging has deduped rows
MERGE INTO #CleanCustomer AS target
USING #Staging AS source
ON target.Email = source.Email

WHEN MATCHED THEN
  UPDATE SET
    target.Name = source.Name,
    target.Phone = COALESCE(source.Phone, target.Phone)  --COALESCE is often used in scenarios where you need to fill in missing (NULL) values with a backup or default value. For example: Merging datasets where some values might be missing in one of the datasets.



WHEN NOT MATCHED BY TARGET THEN
  INSERT (CustomerID, Name, Email, Phone)
  VALUES (source.CustomerID, source.Name, source.Email, source.Phone);
--✅ So:

--If same email → update fields.

--If no match → insert as new.

--------------------------------------------------------------------------------------------------------------------------------------------

-- In real companies, deleting data is risky:

--You may need proof of what was deleted.

--Legal & compliance teams often require an audit trail.

--✅ How to log deleted rows
--Method:
--Before deleting from main table — insert the duplicate rows into an Audit table.

Example:

-- Create an audit log table
IF OBJECT_ID('tempdb..#AuditLog') IS NOT NULL DROP TABLE #AuditLog;

CREATE TABLE #AuditLog (
  OrderID INT,
  CustomerID INT,
  OrderDate DATE,
  Amount DECIMAL(10,2),
  DeletedAt DATETIME DEFAULT GETDATE()
);

-- Use a CTE to identify duplicates
WITH CTE AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY CustomerID, OrderDate, Amount ORDER BY OrderID) AS rn
  FROM 
    #Orders
)

--| OrderID | CustomerID | OrderDate  | Amount | rn            |
--| ------- | ---------- | ---------- | ------ | ------------- |
--| 1       | 101        | 2024-06-20 | 1200   | 1 ✅ Keep      |
--| 3       | 101        | 2024-06-20 | 1200   | 2 ❌ Duplicate |
--| 2       | 101        | 2024-06-20 | 700    | 1 ✅ Keep      |
--| 4       | 102        | 2024-06-21 | 900    | 1 ✅ Keep      |
--| 5       | 102        | 2024-06-21 | 900    | 2 ❌ Duplicate |

-- First, save duplicate rows
INSERT INTO #AuditLog (OrderID, CustomerID, OrderDate, Amount)
SELECT 
  OrderID, CustomerID, OrderDate, Amount
FROM 
  CTE WHERE rn > 1;

--✅ This inserts:

--OrderID 3

--OrderID 5

--Into your #AuditLog. So now you know exactly what you removed.


--First row = rn=1 → keep

--rn > 1 → duplicates




-- Then, delete them from main table

DELETE FROM CTE WHERE rn > 1;

--✅ This safely removes:

--OrderID 3 (duplicate of 1)

--OrderID 5 (duplicate of 4)

--Only the extra rows are deleted.

--✅ Result:

--Bad rows are removed from #Orders

--But saved forever in #AuditLog with a timestamp DeletedAt.

--📌 3️⃣ Why does this matter?
--✅ Good data engineers never blindly delete.
--They:

--Prove what was removed (audit)

--Can restore if needed

--Meet compliance or rollback needs

--This is real Data Ops discipline.

--✅ Summary
--Concept	What it does	Example
--MERGE	Cleanly upserts or updates duplicate/conflicting records	Fix multiple rows for same email
--Audit Log	Saves removed data for traceability	Insert to #AuditLog before DELETE

--🚀 You now know what 95% of junior devs don’t:
--👉 Clean data
--👉 Merge smartly
--👉 Audit removals


--✅ What is Master Data?
--Master Data refers to:

--"Non-transactional, business-critical reference data that stays relatively stable over time."

--It defines who and what your business operates on.


-- Common examples of Master Data:

--| Business Entity   | Example Master Data Table |
--| ----------------- | ------------------------- |
--| Customers         | `Customer` table          |
--| Products          | `Product` table           |
--| Employees         | `Employee` table          |
--| Vendors/Suppliers | `Vendor` table            |
--| Locations         | `Region`, `Warehouse`     |
--| Accounts          | `AccountMaster`           |

--✅ Difference between Master Data & Transactional Data
--| Master Data                 | Transactional Data                |
--| --------------------------- | --------------------------------- |
--| Customer, Product, Employee | Sales, Orders, Payments, Logins   |
--| Changes slowly              | Changes frequently (daily/hourly) |
--| Stored in dimension tables  | Stored in fact tables             |
--| Used as lookup/reference    | Used for analytics, KPIs, reports |


--✅ In Data Engineering, how do we use Master Data?
--| Use Case                     | Example                                               |
--| ---------------------------- | ----------------------------------------------------- |
--| 🔍 Joining with fact tables  | `Sales.Order` → join with `Customer`                  |
--| 🏷️ Enriching reports        | Display full product name instead of just `ProductID` |
--| 📚 Building dimension tables | `dimCustomer`, `dimProduct`, etc.                     |
--| 📊 Reporting by attributes   | “Total Sales by Customer Region”                      |
--| 🔁 Implementing SCD          | Track changes to Customer Address over time           |

--✅ Real-World Data Engineering Pipeline Example

--CRM System  --->  CustomerMaster.csv
--                        |
--                (Ingest via Spark or ADF)
--                        |
--             → Clean + Deduplicate
--                        |
--             → Apply SCD Logic (Slowly Changing Dim)
--                        |
--             → Load to Data Warehouse → dimCustomer

--✅ Pro Tip for Interviews

--Q: What is Master Data?

--A: “Master data refers to stable, reference information like customers, products, and locations that provide consistent context for 
--transactional data. In Data Warehousing, we store it in dimension tables like dimCustomer, apply SCD logic to track history, and use it 
--to enrich fact tables in BI reporting.”

--✅ PART 1: Building a Customer Master Table from Raw Data

-- Raw Customer Data from 3 systems
--IF OBJECT_ID('tempdb..#RawCustomer') IS NOT NULL DROP TABLE #RawCustomer;

--CREATE TABLE #RawCustomer (
--  CustomerID INT,
--  FullName NVARCHAR(100),
--  Email NVARCHAR(100),
--  Phone NVARCHAR(20),
--  SourceSystem NVARCHAR(50),
--  CreatedDate DATE
--);

--INSERT INTO #RawCustomer VALUES
--(101, 'John A', 'john@email.com', '99999', 'CRM', '2024-01-01'),
--(101, 'John Arthur', 'john@email.com', NULL, 'SalesDB', '2024-01-03'),
--(102, 'Meena K', 'meena@gmail.com', '88888', 'WebForm', '2024-02-01'),
--(102, 'Meena Kumari', 'meena@gmail.com', NULL, 'CRM', '2024-02-02'),
--(103, 'Ravi S', 'ravi@gmail.com', '77777', 'CRM', '2024-03-01');


--Step 1: Deduplicate & Clean
--Pick latest data by CreatedDate and fill missing values:

--WITH Ranked AS (
--  SELECT *,
--         ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CreatedDate DESC) AS rn
--  FROM #RawCustomer
--)
--SELECT 
--  CustomerID,
--  COALESCE(FullName, '') AS Name,
--  Email,
--  COALESCE(Phone, '') AS Phone
--INTO #CleanedCustomer
--FROM Ranked
--WHERE rn = 1;

--✅ Step 2: Add SCD logic (track history)
--We now insert this clean data into a Customer Master Dimension Table:

--IF OBJECT_ID('tempdb..#CustomerMaster') IS NOT NULL DROP TABLE #CustomerMaster;

--CREATE TABLE #CustomerMaster (
--  CustomerSK INT IDENTITY(1,1) PRIMARY KEY,
--  CustomerID INT,
--  FullName NVARCHAR(100),
--  Email NVARCHAR(100),
--  Phone NVARCHAR(20),
--  StartDate DATE,
--  EndDate DATE,
--  IsCurrent CHAR(1)
--);


--Insert from cleaned data:

--INSERT INTO #CustomerMaster (
--  CustomerID, FullName, Email, Phone, StartDate, EndDate, IsCurrent
--)
--SELECT 
--  CustomerID, Name, Email, Phone, GETDATE(), NULL, 'Y'
--FROM 
--  #CleanedCustomer;


--✅ PART 2: Master Data Modeling (Dimensional Design)
--📌 Real-world BI/DWH Modeling
--You now want to model this Customer Master in your Data Warehouse.

--✅ Fact Table vs Dimension Table
--| Table Type      | Example       | Purpose                           |
--| --------------- | ------------- | --------------------------------- |
--| Dimension Table | `dimCustomer` | Who/what/where — descriptive info |
--| Fact Table      | `factSales`   | Metrics: sales, quantity, revenue |


--✅ Design: dimCustomer

--CREATE TABLE #dimCustomer (
--  CustomerSK INT PRIMARY KEY,
--  CustomerID INT,
--  FullName NVARCHAR(100),
--  Email NVARCHAR(100),
--  Phone NVARCHAR(20),
--  StartDate DATE,
--  EndDate DATE,
--  IsCurrent CHAR(1)
--);


--✅ Design: factSales

--CREATE TABLE #factSales (
--  SalesID INT,
--  CustomerSK INT, -- Foreign Key from dimCustomer
--  ProductID INT,
--  SaleAmount DECIMAL(10,2),
--  SaleDate DATE
--);

--✅ So:

--You can always join factSales to dimCustomer using CustomerSK

--And you can filter only current customers (IsCurrent = 'Y')

--Or analyze sales by customer as they were in 2023 vs 2024 (using SCD)


--✅ Reporting use cases

--| Question                                              | Join Logic                                                                |
--| ----------------------------------------------------- | ------------------------------------------------------------------------- |
--| Total sales by current customer name                  | `JOIN factSales f ON f.CustomerSK = d.CustomerSK WHERE d.IsCurrent = 'Y'` |
--| Compare sales before and after customer moved address | Use `StartDate/EndDate` filter in `dimCustomer`                           |
--| Get all sales by customer email                       | Join via SK + Email in `dimCustomer`                                      |

--✅ How to explain this in interviews:

--“I designed a Customer Master Dimension (dimCustomer) by deduplicating raw CRM and WebForm data, 
--added SCD tracking using StartDate, EndDate, and IsCurrent, and linked it tofact tables via surrogate keys (CustomerSK) 
--for full history tracking. This allowed flexible reporting and change tracking over time.”


--✅ TOPIC 1: MERGE with UPSERT Logic (used in 100% of real-world pipelines)

--📌 MERGE = Update existing + Insert new → Upsert

--It’s used to load data into dimensions, handle delta changes, and avoid duplicates.

--✅ Real-World Scenario
--You are processing daily Customer feed from the CRM system.
--Some records are new, others are updates.

--🔧 Step 1: Create target table (customer dimension)

--IF OBJECT_ID('tempdb..#CustomerMaster') IS NOT NULL DROP TABLE #CustomerMaster;

--CREATE TABLE #CustomerMaster (
--  CustomerID INT PRIMARY KEY,
--  FullName NVARCHAR(100),
--  Email NVARCHAR(100),
--  Phone NVARCHAR(20),
--  LastUpdated DATE
--);

--📥 Step 2: Create today's staging table

--IF OBJECT_ID('tempdb..#StagingCustomer') IS NOT NULL DROP TABLE #StagingCustomer;

--CREATE TABLE #StagingCustomer (
--  CustomerID INT,
--  FullName NVARCHAR(100),
--  Email NVARCHAR(100),
--  Phone NVARCHAR(20),
--  FeedDate DATE
--);

--INSERT INTO #StagingCustomer VALUES
--(101, 'John A', 'john@email.com', '99999', '2024-06-20'),  -- update
--(102, 'Meena K', 'meena@gmail.com', '88888', '2024-06-20'), -- insert
--(103, 'Ravi S', 'ravi@gmail.com', '77777', '2024-06-20');   -- insert

--⚙️ Step 3: Pre-load master with older data

--INSERT INTO #CustomerMaster VALUES
--(101, 'John', 'john@email.com', '12345', '2024-01-01');

--So:

--John (101) exists → should be updated

--Others → should be inserted


--MERGE #CustomerMaster AS target
--USING #StagingCustomer AS source
--ON target.CustomerID = source.CustomerID

---- ✅ Update if exists
--WHEN MATCHED THEN 
--  UPDATE SET
--    FullName = source.FullName,
--    Phone = source.Phone,
--    LastUpdated = source.FeedDate

---- ✅ Insert if not exists
--WHEN NOT MATCHED BY TARGET THEN
--  INSERT (CustomerID, FullName, Email, Phone, LastUpdated)
--  VALUES (source.CustomerID, source.FullName, source.Email, source.Phone, source.FeedDate);

--✅ Final Output: #CustomerMaster
--| CustomerID | FullName | Email                                     | Phone | LastUpdated |
--| ---------- | -------- | ----------------------------------------- | ----- | ----------- |
--| 101        | John A   | [john@email.com](mailto:john@email.com)   | 99999 | 2024-06-20  |
--| 102        | Meena K  | [meena@gmail.com](mailto:meena@gmail.com) | 88888 | 2024-06-20  |
--| 103        | Ravi S   | [ravi@gmail.com](mailto:ravi@gmail.com)   | 77777 | 2024-06-20  |

--💬 How to answer in interviews
--“I process daily CRM files using MERGE to apply UPSERT logic — update existing customer records and insert new ones. It ensures data is up-to-date and deduplicated in the dimension.”

--🔥 This shows you understand real ingestion and Delta logic.

-- What You’ve Learned
-- | Concept            | Real-World Use                         |
--| ------------------ | -------------------------------------- |
--| `MERGE`            | Load dimensions with delta data        |
--| `WHEN MATCHED`     | Update existing records                |
--| `WHEN NOT MATCHED` | Insert new records                     |
--| `Staging Table`    | Best practice for controlled ingestion |

--📌 You originally inserted:
--INSERT INTO #CustomerMaster VALUES
--(101, 'John', 'john@email.com', '12345', '2024-01-01');

--So initially, the table had:
--| CustomerID | FullName | Email                                   | Phone | LastUpdated |
--| ---------- | -------- | --------------------------------------- | ----- | ----------- |
--| 101        | John     | [john@email.com](mailto:john@email.com) | 12345 | 2024-01-01  |

----📥 Then your staging data had:
--(101, 'John A', 'john@email.com', '99999', '2024-06-20')  -- Updated Name + Phone

--🔁 Then, in the MERGE, this happened:
--MERGE #CustomerMaster AS target
--USING #StagingCustomer AS source
--ON target.CustomerID = source.CustomerID
--💥 Since CustomerID = 101 matched, the WHEN MATCHED logic updated the existing record.

--🔧 It ran this update:
--UPDATE SET
--  FullName = source.FullName,
--  Phone = source.Phone,
--  LastUpdated = source.FeedDate

--✅ So the old record:
--| CustomerID | FullName | Phone | LastUpdated |
--| ---------- | -------- | ----- | ----------- |
--| 101        | John     | 12345 | 2024-01-01  |

--🔁 Became:
--| CustomerID | FullName | Phone | LastUpdated |
--| ---------- | -------- | ----- | ----------- |
--| 101        | John A   | 99999 | 2024-06-20  |

--✅ MERGE for SCD Type 2 (Slowly Changing Dimensions – Versioning)

--📌 SCD Type 2 keeps history. When something changes (like a customer’s address), we don’t overwrite — instead:

--Expire the old record (with EndDate)

--Insert a new one (with StartDate + IsCurrent = 'Y')


--💼 Real-world Scenario:
--You manage a CustomerDim table for reporting.
--Each change in the customer’s info (like Phone or Name) should be tracked historically.

--🔧 Step 1: Create Dimension Table with SCD Columns

--IF OBJECT_ID('tempdb..#CustomerDim') IS NOT NULL DROP TABLE #CustomerDim;

--CREATE TABLE #CustomerDim (
--  CustomerSK INT IDENTITY(1,1) PRIMARY KEY,
--  CustomerID INT,
--  FullName NVARCHAR(100),
--  Phone NVARCHAR(20),
--  StartDate DATE,
--  EndDate DATE,
--  IsCurrent CHAR(1)
--);

--📥 Step 2: Insert initial dimension data (as if from past load)
--INSERT INTO #CustomerDim (CustomerID, FullName, Phone, StartDate, EndDate, IsCurrent)
----VALUES 
----(101, 'John', '12345', '2024-01-01', NULL, 'Y'); -- current version

--📦 Step 3: Simulate incoming updated customer data from a new file

--IF OBJECT_ID('tempdb..#StagingCustomer') IS NOT NULL DROP TABLE #StagingCustomer;

--CREATE TABLE #StagingCustomer (
--  CustomerID INT,
--  FullName NVARCHAR(100),
--  Phone NVARCHAR(20),
--  FeedDate DATE
--);

---- John updated phone number
--INSERT INTO #StagingCustomer VALUES
--(101, 'John', '99999', '2024-06-27');

--💥 Step 4: MERGE with SCD Type 2 Logic

--We’ll expire the old record and insert a new one only if something changed.
-- Step A: Expire old version if data has changed
--UPDATE cd
--SET 
--  EndDate = sc.FeedDate - 1,
--  IsCurrent = 'N'
--FROM 
--  #CustomerDim cd
--JOIN 
--  #StagingCustomer sc 
--  ON cd.CustomerID = sc.CustomerID
--WHERE 
--  cd.IsCurrent = 'Y' AND (
--    cd.FullName <> sc.FullName OR
--    cd.Phone <> sc.Phone
--  );

--🔍 What this does:

--Part	What it means

--UPDATE cd	We’re updating rows in #CustomerDim (existing table)
--SET EndDate = sc.FeedDate - 1	                  We’re ending the current version one day before the new one starts
--IsCurrent = 'N'	                              This record is no longer current
--JOIN sc ON cd.CustomerID = sc.CustomerID	      Match incoming record with existing ones
--WHERE cd.IsCurrent = 'Y'	                      Only update rows that are currently active
--AND (FullName OR Phone is different)	          Only update if something has actually changed!

--🎯 Example:
--Let’s say existing record is:

--| CustomerID | FullName | Phone | StartDate  | EndDate | IsCurrent |
--| ---------- | -------- | ----- | ---------- | ------- | --------- |
--| 101        | John     | 12345 | 2024-01-01 | NULL    | Y         |


--Incoming record from staging:
--| CustomerID | FullName | Phone | FeedDate   |
--| ---------- | -------- | ----- | ---------- |
--| 101        | John     | 99999 | 2024-06-27 |


--Since the Phone has changed, the logic will:

--Set EndDate = 2024-06-26 on the current row

--Set IsCurrent = 'N'

--✅ The old row is now "expired"

---- Step B: Insert new version (if data is different)
--INSERT INTO #CustomerDim (CustomerID, FullName, Phone, StartDate, EndDate, IsCurrent)
--SELECT 
--  sc.CustomerID,
--  sc.FullName,
--  sc.Phone,
--  sc.FeedDate,
--  NULL,
--  'Y'
--FROM #StagingCustomer sc
--LEFT JOIN #CustomerDim cd
--  ON sc.CustomerID = cd.CustomerID AND cd.IsCurrent = 'Y'
--WHERE 
--  cd.FullName <> sc.FullName OR
--  cd.Phone <> sc.Phone;


--🔍 What this does:
--| Part                             | What it means                                    |
--| -------------------------------- | ------------------------------------------------ |
--| `INSERT INTO #CustomerDim (...)` | We are **adding a new row** with new values      |
--| `StartDate = sc.FeedDate`        | New row becomes valid from today                 |
--| `EndDate = NULL`                 | Because this is now the "active" version         |
--| `IsCurrent = 'Y'`                | This is the current valid row                    |
--| `LEFT JOIN`                      | Join to find the **current version** (if exists) |
--| `WHERE changed`                  | Only insert if something has actually changed    |


--🧠 Why 2 steps?
--If you do only insert without expiring the old one:

--You’ll have 2 "current" rows

--That causes reporting issues, data quality errors, and wrong aggregations

--That’s why:

--First expire the old version

--Then insert the new

--✅ This is a best practice followed in large-scale systems like:

--Snowflake DWH

--Azure Synapse

--Google BigQuery pipelines

--Databricks with Delta Lake


--🔁 Final State Example After Both Steps


--✅ Final Table: #CustomerDim
--| CustomerSK | CustomerID | FullName | Phone | StartDate  | EndDate    | IsCurrent |
--| ---------- | ---------- | -------- | ----- | ---------- | ---------- | --------- |
--| 1          | 101        | John     | 12345 | 2024-01-01 | 2024-06-26 | N         |
----| 2          | 101        | John     | 99999 | 2024-06-27 | NULL       | Y         |

--🧠 When do companies use this?
--In Data Warehouses

--For dimensional modeling

--For regulatory reporting, audit trails, time-based analysis.

--🎯 Interview Answer Sample:

--“I implement SCD Type 2 using a two-step MERGE pattern. First, I expire the old dimension row by setting EndDate and IsCurrent = 'N' 
--when any key attributes change. 
--Then I insert a new row with updated values, a new StartDate, and mark it as current. This allows full historical tracking.”


--✅ NEXT TOPIC: Surrogate Keys vs Natural Keys — What, Why, and How
--This is asked in every data engineer interview, especially in DWH and ETL roles.

--🔍 What are Surrogate Keys?
--| Key Type          | Description                                                                            |
--| ----------------- | -------------------------------------------------------------------------------------- |
--| **Natural Key**   | Comes from source data (e.g., CustomerID from CRM)                                     |
--| **Surrogate Key** | System-generated ID used **only inside the Data Warehouse**, like an `IDENTITY` column |

--📊 Example: Customer Data
--🧾 Source System (CRM or Sales DB)
--| CustomerID | Name     | Email                                     |
--| ---------- | -------- | ----------------------------------------- |
--| 101        | John Doe | [john@email.com](mailto:john@email.com)   |
--| 102        | Meena K  | [meena@gmail.com](mailto:meena@gmail.com) |
--This is your natural key — CustomerID.

----🏗️ Dimension Table in Data Warehouse (dimCustomer)
--| CustomerSK | CustomerID | Name     | StartDate  | EndDate    | IsCurrent |
--| ---------- | ---------- | -------- | ---------- | ---------- | --------- |
--| 1          | 101        | John Doe | 2024-01-01 | 2024-06-26 | N         |
--| 2          | 101        | John Doe | 2024-06-27 | NULL       | Y         |
--| 3          | 102        | Meena K  | 2024-02-01 | NULL       | Y         |
--✅ CustomerSK = Surrogate Key
--✅ CustomerID = Natural Key


--🧠 Why use Surrogate Keys?
--🔥 Reason 1: Versioning (SCD Type 2)
--You can have multiple versions of the same CustomerID, but each gets a new CustomerSK.

--🔥 Reason 2: Better Joins in Fact Tables
--Fact tables reference CustomerSK, not CustomerID, for performance and consistency.

--🔥 Reason 3: Handle changes in business rules
--If business logic changes, surrogate keys remain stable — your relationships won’t break.

--🎯 Real Fact Table Using Surrogate Keys

--CREATE TABLE #factSales (
--  SalesID INT,
--  CustomerSK INT, -- surrogate key from dimCustomer
--  ProductID INT,
--  SaleDate DATE,
--  Amount DECIMAL(10,2)
----);
-- You join factSales to dimCustomer using CustomerSK, not CustomerID.

--Create Dimension with Surrogate Key
--CREATE TABLE #dimCustomer (
--  CustomerSK INT IDENTITY(1,1) PRIMARY KEY,
--  CustomerID INT,
--  Name NVARCHAR(100),
--  StartDate DATE,
--  EndDate DATE,
--  IsCurrent CHAR(1)
--);

----Insert values (like an ETL insert)
--INSERT INTO #dimCustomer (CustomerID, Name, StartDate, EndDate, IsCurrent)
--VALUES
--(101, 'John', '2024-01-01', '2024-06-26', 'N'),
--(101, 'John', '2024-06-27', NULL, 'Y'),
--(102, 'Meena', '2024-02-01', NULL, 'Y');

--🗣️ How to explain in interviews:
--“I use surrogate keys in dimension tables to handle SCD Type 2 logic. Each time an attribute changes, 
--I generate a new surrogate key (e.g., CustomerSK). Fact tables join via this key, which ensures history is maintained and 
--queries remain consistent even if natural keys change in the source system.”

--✅ Summary: When to Use What?

--| Use Case                          | Use Surrogate Key?    |
--| --------------------------------- | --------------------- |
--| Dimension tables with history     | ✅ YES                 |
--| Fact tables referencing dimension | ✅ YES                 |
--| OLTP systems (CRUD apps)          | ❌ No, use natural key |
--| Reporting with slow changes       | ✅ YES                 |

--⚡ OLTP vs OLAP Quick Table

--| Feature        | OLTP (CRM, ERP)        | OLAP (Data Warehouse, Power BI)    |
--| -------------- | ---------------------- | ---------------------------------- |
--| Purpose        | Day-to-day operations  | Reporting & analytics              |
--| Operations     | Insert, Update, Delete | Read-heavy (SELECT, Aggregation)   |
--| Data Structure | Highly normalized      | Denormalized (star schema)         |
--| Speed Focus    | Fast for transactions  | Fast for queries/aggregation       |
--| Examples       | CRM, POS, ERP          | Snowflake, Redshift, Azure Synapse |


--Star Schema Design – Build Full Model with Date, Customer, Product, and Sales

--You’ll learn:

--What a star schema is

--Why it’s used in data warehouses

--How to design and build one with fact and dimension tables

--How to write analytics queries on top of it


--⭐ What is a Star Schema?
--It’s a database modeling technique where:

--The central table is the Fact Table (e.g. Sales)

--Connected to Dimension Tables (Customer, Product, Date, etc.)

--Looks like a ⭐ = hence the name

               --dimCustomer
               --    |
               --dimProduct
               --    |
               --dimDate
               --    |
               -- factSales

--✅ Step 1: Create dimProduct

--IF OBJECT_ID('tempdb..#dimProduct') IS NOT NULL DROP TABLE #dimProduct;

--CREATE TABLE #dimProduct (
--  ProductSK INT IDENTITY(1,1) PRIMARY KEY,
--  ProductID INT,
--  ProductName NVARCHAR(100),
--  Category NVARCHAR(50)
--);

--INSERT INTO #dimProduct (ProductID, ProductName, Category) VALUES
--(201, 'iPhone 15', 'Mobile'),
--(202, 'Samsung TV', 'Electronics'),
--(203, 'Nike Shoes', 'Footwear');

--✅ Step 2: Create dimDate

--Use a date dimension — this is used in 100% of real DWH systems.

IF OBJECT_ID('tempdb..#dimDate') IS NOT NULL DROP TABLE #dimDate;

CREATE TABLE #dimDate (
  DateSK INT PRIMARY KEY,
  Date DATE,
  Day INT,
  Month INT,
  Year INT,
  Quarter INT,
  WeekdayName NVARCHAR(20)
);

-- Populate with a loop (for example: 2024-01-01 to 2025-12-31)
DECLARE @start DATE = '2024-01-01', @end DATE = '2025-12-31';
WHILE @start <= @end
BEGIN
  INSERT INTO #dimDate
  SELECT 
    CAST(CONVERT(VARCHAR, @start, 112) AS INT),
    @start,
    DAY(@start),
    MONTH(@start),
    YEAR(@start),
    DATEPART(QUARTER, @start),
    DATENAME(WEEKDAY, @start);

  SET @start = DATEADD(DAY, 1, @start);
END
--✅ DateSK = YYYYMMDD format (e.g., 20240627)

--✅ Step 3: Rebuild factSales

--IF OBJECT_ID('tempdb..#factSales') IS NOT NULL DROP TABLE #factSales;

--CREATE TABLE #factSales (
--  SalesID INT,
--  CustomerSK INT,
--  ProductSK INT,
--  DateSK INT,
--  Amount DECIMAL(10,2)
--);

--Sample Load:

--INSERT INTO #factSales (SalesID, CustomerSK, ProductSK, DateSK, Amount)
--VALUES
--(1, 1, 201, 20240601, 500),
--(2, 2, 202, 20240615, 700),
--(3, 3, 203, 20240620, 900);

--✅ Now Run Some Powerful Queries

--💡 Total Sales by Product:
--SELECT 
--  dp.ProductName,
--  SUM(fs.Amount) AS TotalSales
--FROM #factSales fs
--JOIN #dimProduct dp ON fs.ProductSK = dp.ProductSK
--GROUP BY dp.ProductName;

--💡 Monthly Trend:
--SELECT 
--  dd.Year,
--  dd.Month,
--  SUM(fs.Amount) AS MonthlySales
--FROM #factSales fs
--JOIN #dimDate dd ON fs.DateSK = dd.DateSK
--GROUP BY dd.Year, dd.Month
--ORDER BY dd.Year, dd.Month;

--💡 Region-wise Sales (if added Region in dimCustomer):
--SELECT 
--  dc.Region,
--  SUM(fs.Amount) AS SalesByRegion
--FROM #factSales fs
--JOIN #dimCustomer dc ON fs.CustomerSK = dc.CustomerSK
--GROUP BY dc.Region;

--🧠 Interview Knowledge
--“In data warehousing, we use star schema for better analytics and performance. Fact tables store measurable events (e.g., sales) and
--reference surrogate keys from dimensions like customer, product, and date. This allows easier reporting and better indexing strategies.”


--Optimize Your Star Schema – Indexing, Partitioning & Performance Best Practices
--💡 The goal: Even if your dataset has 100 million rows, your queries should still run fast and efficiently.

--This is asked in 90% of senior data engineering interviews:

--“How would you optimize a slow-running query?”

--“What indexing or partitioning would you apply to a fact table?”

--🧱 1. Indexing: Speed Up Joins & Filters
--🔍 Problem:
--Joining large tables like factSales with dimCustomer and filtering by DateSK or ProductSK is slow if indexes are missing.

--✅ Solution: Add Non-Clustered Indexes

---- Index to speed up Date joins and filtering
--CREATE NONCLUSTERED INDEX idx_factSales_DateSK ON #factSales (DateSK);

---- Index to speed up Product joins
--CREATE NONCLUSTERED INDEX idx_factSales_ProductSK ON #factSales (ProductSK);

---- Index for customer joins
--CREATE NONCLUSTERED INDEX idx_factSales_CustomerSK ON #factSales (CustomerSK);


🎒 Imagine This Like a School Attendance Register

--📘 Case 1: Clustered Index (Notebook is physically sorted)
--Think of a school register sorted by Roll Number

--The pages of the notebook are arranged in increasing roll number.

--If you're looking for roll number 18, you go straight to page 18.

--Only one way to sort the pages — so only one clustered index per table.

--📌 In SQL:

--CREATE CLUSTERED INDEX idx_students_roll
--ON Students(RollNumber);

--✅ When to use?

--When you mostly filter by ID or date

--When you want range queries to be fast

--📙 Case 2: Non-Clustered Index (Notebook is NOT sorted, but you have bookmarks)

--Now imagine your register is NOT sorted
--But you keep a bookmark at the back saying:
--Rahul — Page 4  
--Anjali — Page 12  
--Deepak — Page 8

--The book is still in random order
--But you can jump to the page using the bookmarks
--These bookmarks are non-clustered indexes
--You can have many bookmarks (many non-clustered indexes)

--📌 In SQL:

--CREATE NONCLUSTERED INDEX idx_students_name ON Students(Name);

--✅ When to use?

--When you often search using non-ID fields (e.g. Name, Email)

--When you JOIN on foreign keys (e.g., CustomerID, ProductID)

--🧱 Table Summary:
--| Feature           | Clustered Index              | Non-Clustered Index                           |
--| ----------------- | ---------------------------- | --------------------------------------------- |
--| Sorts table rows  | ✅ Yes — physically sorted    | ❌ No — leaves data as is                      |
--| Number allowed    | 1 per table                  | Many per table                                |
--| Use case          | Fast range filters (ID/date) | Fast lookups, joins, filters on other columns |
--| Storage structure | Main table is ordered        | Separate index with pointers                  |
--| Analogy           | Pages sorted by roll number  | Bookmarks to jump to page                     |


--📊 Real SQL Example:
--Let's say you have a sales table:
--CREATE TABLE Sales (
--  SaleID INT,
--  CustomerID INT,
--  ProductID INT,
--  SaleDate DATE,
--  Amount DECIMAL(10,2)
--);

--✅ You want to optimize:
--Date filters:
--→ Use Clustered Index on SaleDate

--Join with Customer & Product tables:
--→ Use Non-Clustered Index on CustomerID, ProductID

-- Clustered Index on SaleDate
--CREATE CLUSTERED INDEX idx_sales_date ON Sales(SaleDate);

---- Non-Clustered Index on CustomerID
--CREATE NONCLUSTERED INDEX idx_sales_customer ON Sales(CustomerID);

---- Non-Clustered Index on ProductID
--CREATE NONCLUSTERED INDEX idx_sales_product ON Sales(ProductID);

--✅ Final Analogy Wrap-Up:

--| Situation                       | Type of Index to Use |
--| ------------------------------- | -------------------- |
--| Filter by Date range            | Clustered            |
--| Filter or join by CustomerID    | Non-Clustered        |
--| Filter by ProductID or Category | Non-Clustered        |
--| Sorting entire table by SaleID  | Clustered            |
--| Search by Email or Name         | Non-Clustered        |

--We’ll simulate a Sales table with 100,000 rows — no indexes initially.
--IF OBJECT_ID('tempdb..#Sales') IS NOT NULL DROP TABLE #Sales;

--CREATE TABLE #Sales (
--    SaleID INT IDENTITY(1,1) PRIMARY KEY, -- By default: CLUSTERED
--    CustomerID INT,
--    ProductID INT,
--    SaleDate DATE,
--    Amount DECIMAL(10, 2)
--);
----Note: The PRIMARY KEY on SaleID will automatically create a CLUSTERED INDEX unless you override it.

----🧪 Step 2: Insert 100,000 rows
--DECLARE @i INT = 0;

--WHILE @i < 100000
--BEGIN
--    INSERT INTO #Sales (CustomerID, ProductID, SaleDate, Amount)
--    VALUES (
--        ABS(CHECKSUM(NEWID())) % 1000 + 1,  -- Random CustomerID
--        ABS(CHECKSUM(NEWID())) % 50 + 1,    -- Random ProductID
--        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()), -- Random SaleDate in past year
--        ROUND(RAND() * 10000, 2)
--    );
--    SET @i = @i + 1;
--END
----✅ Let it run for 1–2 mins to fill the temp table.

----🧪 Step 3: Run a Query Without Index — See Performance
--SET STATISTICS IO ON;
--SET STATISTICS TIME ON;

--SELECT *
--FROM #Sales
--WHERE SaleDate BETWEEN '2024-07-01' AND '2024-12-31';


--CREATE NONCLUSTERED INDEX idx_Sales_SaleDate ON #Sales(SaleDate);

--SELECT *
--FROM #Sales
--WHERE SaleDate BETWEEN '2024-07-01' AND '2024-12-31';


--| Metric        | Without Index | With Index |
--| ------------- | ------------- | ---------- |
--| Rows Returned | 50,366        | 50,366     |
--| Logical Reads | 410           | 410        |
--| CPU Time      | 0 ms          | 15 ms      |
--| Elapsed Time  | 40 ms         | 29 ms      |
--| Scan Count    | 1             | 1          |


--✅ Possible Reasons and Real Fixes
--1. ❗ You are doing SELECT *
--You're requesting all columns, but your index only includes SaleDate.

--This causes "key lookups" — SQL Server has to go back to the main table (called "bookmark lookup") for other columns like CustomerID, ProductID, and Amount.

--📌 So SQL is thinking:
--"If I have to go to the base table anyway for every row, might as well just scan the whole thing."


---- Drop old index if needed
--DROP INDEX IF EXISTS idx_Sales_SaleDate ON #Sales;

---- Create a covering index
--CREATE NONCLUSTERED INDEX idx_Sales_SaleDate_covering
--ON #Sales(SaleDate)
--INCLUDE (CustomerID, ProductID, Amount);

--SELECT *
--FROM #Sales
--WHERE SaleDate BETWEEN '2024-12-01' AND '2024-12-10';

--🔍 What You Should Now See:
--Logical reads should drop drastically — maybe 10–30 pages

--Execution plan should say Index Seek ✅ (instead of scan)

--Elapsed time and CPU time should reduce

--📘 Interview Explanation (Pro-Level):
--"I noticed that even with an index on SaleDate, SQL Server was doing a scan. That's because I was selecting all columns, so SQL still had to do a key lookup for each row. I fixed this by creating a covering index using INCLUDE, so the query could be satisfied entirely from the index. 
--That dropped logical reads and improved performance."

--SELECT SaleDate
--FROM #Sales
--WHERE SaleDate BETWEEN '2024-12-01' AND '2024-12-10';

--You’ll see the original index is now used and logical reads drop — because only SaleDate is needed .


--✅ Pro Interview Tip
--If you're in a SQL/Data Engineer interview and asked:

--"How do you troubleshoot a query that’s scanning a table despite having an index?"

--Say:

--"I’d first check the execution plan. If an index exists but is not used, I’d consider whether stats are outdated — and
--run UPDATE STATISTICS to refresh row distribution so SQL can make better choices."

---- 1. Create your temp table
--CREATE TABLE #Sales (
--    SaleID INT IDENTITY(1,1),
--    CustomerID INT,
--    ProductID INT,
--    SaleDate DATE,
--    Amount DECIMAL(10,2)
--);

---- 2. Insert data (simulated loop or bulk insert)
---- (skip code for brevity if already done)

---- 3. Create index on SaleDate (optional but smart)
--CREATE NONCLUSTERED INDEX idx_SaleDate ON #Sales(SaleDate);

---- ✅ 4. Update stats after data + index
--UPDATE STATISTICS #Sales;

---- 5. Now your query will use best plan!
--SELECT *
--FROM #Sales
--WHERE SaleDate BETWEEN '2024-12-01' AND '2024-12-10';


--🧠 Scenario:
--You're working on a reporting system, and you often run queries like this:

--SELECT * FROM #Sales WHERE CustomerID = 102 AND SaleDate BETWEEN '2024-12-01' AND '2024-12-10';

--Currently, you may only have an index on SaleDate. But now you're filtering on both CustomerID and SaleDate.

--👉 Time to use a composite index (multi-column index).

--CREATE NONCLUSTERED INDEX idx_Customer_SaleDate
--ON #Sales(CustomerID, SaleDate)
--INCLUDE (Amount, ProductID);

--🔑 This means:

--SQL Server will seek first on CustomerID

--Then it will filter/sort by SaleDate

--No need for lookups because yes goi next of INCLUDE

--📘 In Interviews, You Might Be Asked:
--"We already have indexes but queries are still slow. What would you do?"

--🧠 Your Pro Answer:

--"I’d analyze the WHERE clause patterns. If we often filter on multiple columns like CustomerID + SaleDate, I’d use a composite index. I’d also use INCLUDE to cover all selected columns and avoid lookups.
--Then I’d verify performance improvement through logical reads and execution plans."


--🔍 How to Optimize Queries with Multiple JOINS (4–5+ tables)

--SELECT 
--    c.CustomerName,
--    p.ProductName,
--    d.FullDate,
--    r.RegionName,
--    sf.Amount
--FROM #SalesFact sf
--JOIN #CustomerDim c ON sf.CustomerID = c.CustomerID
--JOIN #ProductDim p  ON sf.ProductID = p.ProductID
--JOIN #DateDim d     ON sf.DateKey = d.DateKey
--JOIN #RegionDim r   ON c.RegionID = r.RegionID
--WHERE d.FullDate BETWEEN '2024-12-01' AND '2024-12-10';

--✅ Golden Rules to Optimize Multi-Join Queries

--1. Filter early using dimension tables

--In the example above, WHERE d.FullDate BETWEEN... is a selective filter.

--That helps SQL prune data before joining, which is fast.

--2. Ensure indexes exist on all foreign key columns

--Create indexes in the fact table (child side of the join):

---- In SalesFact

--CREATE NONCLUSTERED INDEX idx_SalesFact_Customer ON SalesFact(CustomerID);

--CREATE NONCLUSTERED INDEX idx_SalesFact_Product ON SalesFact(ProductID);

--CREATE NONCLUSTERED INDEX idx_SalesFact_Date ON SalesFact(DateKey);

---- In CustomerDim

--CREATE NONCLUSTERED INDEX idx_CustomerDim_Region ON CustomerDim(RegionID);

--3. Use Covering Indexes for Composite Filters
--If you filter on DateKey and select Amount frequently:

--CREATE NONCLUSTERED INDEX idx_SalesFact_Date_Amount
--ON SalesFact(DateKey)
--INCLUDE (Amount);

--4. Use INNER JOIN instead of LEFT JOIN if possible

--INNER JOIN is faster and easier to optimize

--LEFT JOIN can’t prune as easily unless there's a filter on the right table

--| Symbol              | Meaning              |
--| ------------------- | -------------------- |
--| 🔍 Index Seek       | ✅ Good — uses index  |
--| 📖 Index/Table Scan | 🚫 Bad — may be slow |
--| 🔁 Hash/Loop Join   | Strategy used        |

--6. Avoid functions in JOIN or WHERE clauses
--These block index usage:

---- 🚫 Bad: function in join condition
--JOIN DateDim d ON CONVERT(VARCHAR, sf.DateKey) = d.DateKey

--🔍 In Practice: What Goes Wrong Without Indexes
--SQL Server will scan entire SalesFact table

--Joins become Hash Joins, not Loop Joins

--You’ll see high logical reads

--Query runs in seconds/minutes instead of milliseconds

--✅ Pro Interview Talk
--“Whenever I work with 4+ table joins — especially in reporting queries — I index the fact table’s foreign keys and use selective filters early in dimension tables. I also ensure indexes are covering if those columns are heavily selected. 
--I analyze the execution plan for scan vs seek and adjust stats or indexes accordingly.”


--| Feature            | `INNER JOIN`                        | `LEFT JOIN`                                   |
--| ------------------ | ----------------------------------- | --------------------------------------------- |
--| Match required     | ✅ Yes — must match on both sides    | ❌ No — returns all from left even if no match |
--| Row count behavior | Only matching records               | Always all rows from left table               |
--| Index usage        | **Optimized (seeks)** when possible | Sometimes blocks optimization                 |
--| Join strategy      | Usually **Nested Loop / Merge**     | Often **Hash Join** if many nulls             |
--| Performance        | ✅ Faster (if keys/indexed well)     | ⚠️ Slower, needs more memory                  |

--🧠 Interview Talk
--If asked:

--"When do you use INNER JOIN vs LEFT JOIN?"

--Say:

--"I prefer INNER JOIN when I only care about matching rows — it's more efficient and easier to optimize. I use LEFT JOIN only when I need all rows from the left side, even if the right side is missing. 
--I always check if business logic really needs a LEFT JOIN, or if INNER JOIN is enough'

Next Topic 
--To log which part of query is taking time in sp in sssm 

---- Drop temp log table if exists
--IF OBJECT_ID('tempdb..#step_log') IS NOT NULL DROP TABLE #step_log;
--CREATE TABLE #step_log (
--    step_name VARCHAR(100),
--    log_time DATETIME,
--    message VARCHAR(400)
--);

--DECLARE @sp_name VARCHAR(200) = 'usp_invoice_line_merge_simulation';
--DECLARE @current_time DATETIME;

---- Step: Start
--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Start ' + @sp_name;
--INSERT INTO #step_log VALUES ('Start', @current_time, 'Procedure Started');

----------------------------------------------------------------------------------
---- Step 1: Create #invoice_line with dummy data
--IF OBJECT_ID('tempdb..#invoice_line') IS NOT NULL DROP TABLE #invoice_line;
--CREATE TABLE #invoice_line (
--    invoicecompany VARCHAR(10),
--    invoice_currency VARCHAR(5),
--    srcsys_supplier_nbr VARCHAR(20),
--    invoicerefnbr VARCHAR(50),
--    invoice_nbr VARCHAR(20),
--    invoice_line_nbr VARCHAR(10),
--    po_nbr VARCHAR(20),
--    po_line_nbr VARCHAR(10),
--    invoice_line_amount_local FLOAT,
--    payment_line_amount FLOAT,
--    payment_line_amount_local FLOAT,
--    invoice_line_key VARCHAR(100),
--    composite_primary_key_id VARCHAR(100),
--    po_line_key VARCHAR(100),
--    is_header_record CHAR(1)
--);

--INSERT INTO #invoice_line VALUES
--('IN01','INR','SUP1','INVREF1','INV001','0001','PO001','01',1000,1000,1000,'INV001-0001','KEY001','PO001-01','K'),
--('IN01','INR','SUP1','INVREF1','INV001','0002','PO002','02',500,500,500,'INV001-0002','KEY002','PO002-02','L');

--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Created #invoice_line';
--INSERT INTO #step_log VALUES ('Step 1', @current_time, 'Created #invoice_line');

----------------------------------------------------------------------------------
---- Step 2: Create #fpledg with dummy data
--IF OBJECT_ID('tempdb..#fpledg') IS NOT NULL DROP TABLE #fpledg;
--CREATE TABLE #fpledg (
--    divi VARCHAR(10),
--    inyr VARCHAR(4),
--    suno VARCHAR(10),
--    sino VARCHAR(10),
--    trcd INT
--);

--INSERT INTO #fpledg VALUES
--('IN01','2025','SUP1','INVREF1',40);

--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Created #fpledg';
--INSERT INTO #step_log VALUES ('Step 2', @current_time, 'Created #fpledg');

----------------------------------------------------------------------------------
---- Step 3: Join #invoice_line and #fpledg into #invoice_line_po_header_temp
--IF OBJECT_ID('tempdb..#invoice_line_po_header_temp') IS NOT NULL DROP TABLE #invoice_line_po_header_temp;
--SELECT i.*
--INTO #invoice_line_po_header_temp
--FROM #invoice_line i
--JOIN #fpledg f
--  ON f.inyr + f.suno + f.sino = i.invoicerefnbr
-- AND f.divi = i.invoicecompany
--WHERE f.trcd = 40 AND i.is_header_record = 'K';

--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Created #invoice_line_po_header_temp';
--INSERT INTO #step_log VALUES ('Step 3', @current_time, 'Created #invoice_line_po_header_temp');

----------------------------------------------------------------------------------
---- Step 4: Simulate final union temp table
--IF OBJECT_ID('tempdb..#invoice_line_history_temp') IS NOT NULL DROP TABLE #invoice_line_history_temp;
--SELECT * INTO #invoice_line_history_temp FROM #invoice_line_po_header_temp;

--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Created #invoice_line_history_temp';
--INSERT INTO #step_log VALUES ('Step 4', @current_time, 'Created #invoice_line_history_temp');

----------------------------------------------------------------------------------
---- Step 5: Simulate "incremental" #invoice_line_inc_temp
--IF OBJECT_ID('tempdb..#invoice_line_inc_temp') IS NOT NULL DROP TABLE #invoice_line_inc_temp;
--SELECT * INTO #invoice_line_inc_temp FROM #invoice_line WHERE invoice_line_nbr = '0002';

--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Created #invoice_line_inc_temp';
--INSERT INTO #step_log VALUES ('Step 5', @current_time, 'Created #invoice_line_inc_temp');

----------------------------------------------------------------------------------
---- Step 6: Simulate final merge (FULL OUTER JOIN into #invoice_line_final)
--IF OBJECT_ID('tempdb..#invoice_line_final') IS NOT NULL DROP TABLE #invoice_line_final;
--SELECT 
--    ISNULL(I.invoicecompany, H.invoicecompany) AS invoicecompany,
--    ISNULL(I.invoice_line_nbr, H.invoice_line_nbr) AS invoice_line_nbr,
--    ISNULL(I.composite_primary_key_id, H.composite_primary_key_id) AS composite_primary_key_id
--INTO #invoice_line_final
--FROM #invoice_line_history_temp H
--FULL OUTER JOIN #invoice_line_inc_temp I
--  ON H.composite_primary_key_id = I.composite_primary_key_id;

--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': Created #invoice_line_final (simulated merge)';
--INSERT INTO #step_log VALUES ('Step 6', @current_time, 'Created #invoice_line_final');

----------------------------------------------------------------------------------
---- Step: End
--SET @current_time = GETDATE();
--PRINT FORMAT(@current_time, 'yyyy-MM-dd HH:mm:ss') + ': End ' + @sp_name;
--INSERT INTO #step_log VALUES ('End', @current_time, 'Procedure Ended');

----------------------------------------------------------------------------------
---- Final Output
--SELECT * FROM #step_log ORDER BY log_time;

--step_name	       log_time	                    message
--Start	       2025-06-28 02:09:31.153	   Procedure Started
--Step 1	   2025-06-28 02:09:31.157	   Created #invoice_line
--Step 2	   2025-06-28 02:09:31.157	   Created #fpledg
--Step 3	   2025-06-28 02:09:31.163	   Created #invoice_line_po_header_temp
--Step 4	   2025-06-28 02:09:31.167	   Created #invoice_line_history_temp
--Step 5	   2025-06-28 02:09:31.170	   Created #invoice_line_inc_temp
--Step 6	   2025-06-28 02:09:31.177	   Created #invoice_line_final
--End	       2025-06-28 02:09:31.177	   Procedure Ended


-- real-world examples for logging execution steps clearly with timestamps and step names, across both SQL Server (SSMS) and Redshift, in 4 cases:

--✅ Why this helps:
--You now have a clear and structured way to debug real stored procedures by tracking which step takes time — just like production patterns using RAISE INFO or temporary log tables.
--CASE 1: SQL Server (SSMS) — Inside a Stored Procedure

--CREATE PROCEDURE usp_log_steps_ssms
--AS
--BEGIN
--    CREATE TABLE #LogSteps (
--        step_name NVARCHAR(100),
--        log_time DATETIME,
--        message NVARCHAR(255)
--    );

--    INSERT INTO #LogSteps VALUES ('Start', GETDATE(), 'Procedure Started');

--    -- Step 1
--    SELECT 1 AS dummy INTO #invoice_line;
--    INSERT INTO #LogSteps VALUES ('Step 1', GETDATE(), 'Created #invoice_line');

--    -- Step 2
--    SELECT * INTO #invoice_line_final FROM #invoice_line;
--    INSERT INTO #LogSteps VALUES ('Step 2', GETDATE(), 'Created #invoice_line_final');

--    INSERT INTO #LogSteps VALUES ('End', GETDATE(), 'Procedure Ended');

--    SELECT * FROM #LogSteps;
--END;

--📤 Output
--| step_name | log_time               | message                       |
--| ---------- | ----------------------- | ----------------------------- |
--| Start      | 2025-06-28 13:00:00.123 | Procedure Started             |
--| Step 1     | 2025-06-28 13:00:00.128 | Created #invoice_line        |
--| Step 2     | 2025-06-28 13:00:00.134 | Created #invoice_line_final |
--| End        | 2025-06-28 13:00:00.139 | Procedure Ended               |


--✅ CASE 2: SQL Server – Outside SP (Script Execution)

--CREATE TABLE #LogSteps (
--    step_name NVARCHAR(100),
--    log_time DATETIME,
--    message NVARCHAR(255)
--);

--INSERT INTO #LogSteps VALUES ('Start', GETDATE(), 'Script Started');

---- Step 1
--SELECT 1 AS dummy INTO #tmp_table;
--INSERT INTO #LogSteps VALUES ('Step 1', GETDATE(), 'Created #tmp_table');

---- Step 2
--SELECT * INTO #tmp2 FROM #tmp_table;
--INSERT INTO #LogSteps VALUES ('Step 2', GETDATE(), 'Created #tmp2');

--INSERT INTO #LogSteps VALUES ('End', GETDATE(), 'Script Ended');

--SELECT * FROM #LogSteps;

--📤 Output

--| step_name | log_time               | message             |
--| ---------- | ----------------------- | ------------------- |
--| Start      | 2025-06-28 13:05:00.050 | Script Started      |
--| Step 1     | 2025-06-28 13:05:00.054 | Created #tmp_table |
--| Step 2     | 2025-06-28 13:05:00.060 | Created #tmp2       |
--| End        | 2025-06-28 13:05:00.063 | Script Ended        |


--✅ CASE 3: Redshift – Inside Stored Procedure

--CREATE OR REPLACE PROCEDURE usp_log_steps_redshift()
--LANGUAGE plpgsql
--AS $$
--DECLARE
--    log_ts TIMESTAMP;
--BEGIN
--    log_ts := GETDATE();
--    RAISE INFO 'Start | % | Procedure Started', log_ts;

--    -- Step 1
--    CREATE TEMP TABLE invoice_line(dummy INT);
--    INSERT INTO invoice_line VALUES (1);
--    RAISE INFO 'Step 1 | % | Created invoice_line', GETDATE();

--    -- Step 2
--    CREATE TEMP TABLE invoice_line_final AS SELECT * FROM invoice_line;
--    RAISE INFO 'Step 2 | % | Created invoice_line_final', GETDATE();

--    RAISE INFO 'End | % | Procedure Ended', GETDATE();
--END;
--$$;

--📤 Output (in Redshift Console)

--INFO: Start   | 2025-06-28 13:10:00.000  | Procedure Started
--INFO: Step 1  | 2025-06-28 13:10:00.045  | Created invoice_line
--INFO: Step 2  | 2025-06-28 13:10:00.070  | Created invoice_line_final
--INFO: End     | 2025-06-28 13:10:00.080  | Procedure Ended


--✅ CASE 4: Redshift – Outside SP (DO block)

--DO $$
--DECLARE
--    log_ts TIMESTAMP;
--BEGIN
--    log_ts := GETDATE();
--    RAISE INFO 'Start | % | Manual block started', log_ts;

--    -- Step 1
--    CREATE TEMP TABLE t1(dummy INT);
--    INSERT INTO t1 VALUES (1);
--    RAISE INFO 'Step 1 | % | Created t1', GETDATE();

--    -- Step 2
--    CREATE TEMP TABLE t2 AS SELECT * FROM t1;
--    RAISE INFO 'Step 2 | % | Created t2', GETDATE();

--    RAISE INFO 'End | % | Manual block ended', GETDATE();
--END
--$$;

--📤 Output (in Redshift Console)

--INFO: Start  | 2025-06-28 13:15:00.000   | Manual block started
--INFO: Step 1 | 2025-06-28 13:15:00.040   | Created t1
--INFO: Step 2 | 2025-06-28 13:15:00.055   | Created t2
--INFO: End    | 2025-06-28 13:15:00.065   | Manual block ended























