CREATE DATABASE EcommerceSales;

USE EcommerceSales;

CREATE TABLE Products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100)
);

CREATE TABLE Sales (
  sale_id INT PRIMARY KEY,
  product_id INT,
  sale_date DATE,
  quantity INT,
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Products VALUES 
(1, 'Smartphone'), 
(2, 'Laptop'), 
(3, 'Headphones'), 
(4, 'Smartwatch');

INSERT INTO Sales VALUES 
(101, 1, '2025-07-01', 20),
(102, 2, '2025-07-02', 10),
(103, 3, '2025-07-02', 30),
(104, 1, '2025-07-03', 25),
(105, 2, '2025-07-10', 40),
(106, 4, '2025-07-15', 15),
(107, 3, '2025-07-15', 35),
(108, 1, '2025-08-01', 60),
(109, 2, '2025-08-02', 50),
(110, 4, '2025-08-05', 30);

-- Track top products in sales weekly/monthly
WITH WeeklySales AS (
  SELECT 
    DATEPART(WEEK, sale_date) AS sale_week,
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_qty
  FROM Sales s
  JOIN Products p ON p.product_id = s.product_id
  GROUP BY DATEPART(WEEK, sale_date), p.product_id, p.product_name
),
RankedWeekly AS (
  SELECT *,
    RANK() OVER (PARTITION BY sale_week ORDER BY total_qty DESC) AS rank_weekly,
    DENSE_RANK() OVER (PARTITION BY sale_week ORDER BY total_qty DESC) AS dense_rank_weekly,
    LAG(total_qty) OVER (PARTITION BY product_id ORDER BY sale_week) AS prev_qty
  FROM WeeklySales
)
SELECT * FROM RankedWeekly;

-- Use CTEs to track product performance over time
WITH MonthlySales AS (
  SELECT 
    FORMAT(sale_date, 'yyyy-MM') AS sale_month,
    p.product_id,
    p.product_name,
    SUM(quantity) AS total_qty
  FROM Sales s
  JOIN Products p ON p.product_id = s.product_id
  GROUP BY FORMAT(sale_date, 'yyyy-MM'), p.product_id, p.product_name
),
PerformanceOverTime AS (
  SELECT *,
    LAG(total_qty) OVER (PARTITION BY product_id ORDER BY sale_month) AS prev_month_qty
  FROM MonthlySales
)
SELECT * FROM PerformanceOverTime;
