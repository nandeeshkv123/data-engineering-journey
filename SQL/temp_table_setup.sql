-- ==============================================================
-- 📌 TEMP TABLE SETUP — Company-safe sandbox for SQL practice
-- Author: nandeeshkv123 | DataEngineerJourney
-- ==============================================================

-- ⚡ This script uses TEMP tables (PostgreSQL) or #tables (SQL Server)
-- so you can practice in your work DB without creating permanent objects.

-- ===============================
-- ✅ SECTION 1: EMPLOYEES
-- ===============================

-- For SQL Server: use #
IF OBJECT_ID('tempdb..#employees') IS NOT NULL DROP TABLE #employees;
CREATE TABLE #employees (
    employee_id INT PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    department_id INT,
    salary DECIMAL(10,2)
);

INSERT INTO #employees VALUES 
(1, 'John', 'Doe', 10, 50000),
(2, 'Jane', 'Smith', 10, 60000),
(3, 'Alice', 'Brown', 20, 40000),
(4, 'Bob', 'Johnson', 20, 75000),
(5, 'Carol', 'White', 30, 90000);

-- ===============================
-- ✅ SECTION 2: DEPARTMENTS
-- ===============================

IF OBJECT_ID('tempdb..#departments') IS NOT NULL DROP TABLE #departments;
CREATE TABLE #departments (
    department_id INT PRIMARY KEY,
    department_name NVARCHAR(50)
);

INSERT INTO #departments VALUES 
(10, 'HR'),
(20, 'Engineering'),
(30, 'Sales');

-- ===============================
-- ✅ SECTION 3: SALES
-- ===============================

IF OBJECT_ID('tempdb..#sales') IS NOT NULL DROP TABLE #sales;
CREATE TABLE #sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    amount DECIMAL(10,2),
    region NVARCHAR(50)
);

INSERT INTO #sales VALUES 
(1, '2024-01-01', 500.00, 'North'),
(2, '2024-01-02', 700.00, 'North'),
(3, '2024-01-05', 300.00, 'South'),
(4, '2024-01-07', 450.00, 'West'),
(5, '2024-01-10', 800.00, 'North');

-- ===============================
-- ✅ SECTION 4: TEST QUERIES
-- ===============================

-- Example 1: Simple SELECT
SELECT * FROM #employees;

-- Example 2: JOIN
SELECT 
    e.employee_id,
    e.first_name,
    d.department_name
FROM 
    #employees e
JOIN 
    #departments d
ON 
    e.department_id = d.department_id;

-- Example 3: GROUP BY
SELECT 
    department_id,
    AVG(salary) AS avg_salary
FROM 
    #employees
GROUP BY 
    department_id;

-- Example 4: Window Function (SQL Server uses OVER)
SELECT 
    employee_id,
    department_id,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM 
    #employees;

-- ✅ These temp tables vanish when you close the session.

-- ========================================
-- ✅ NOTE for PostgreSQL users:
-- Replace #tables with CREATE TEMP TABLE
-- Example:
-- CREATE TEMP TABLE employees ( ... );
-- Then use `employees` (no #) in queries.
-- ========================================
