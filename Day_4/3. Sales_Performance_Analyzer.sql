-- Create and Use Database
CREATE DATABASE retail_sales_analyzer;
USE retail_sales_analyzer;

-- Tables: sales, stores, products, employees
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    employee_id INT,
    store_id INT,
    sale_date DATE,
    sale_type VARCHAR(10), -- 'online' or 'offline'
    quantity INT,
    amount DECIMAL(10, 2),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Insert Data
INSERT INTO stores VALUES 
(1, 'Store A', 'North'),
(2, 'Store B', 'South');

INSERT INTO products VALUES 
(1, 'Laptop', 'Electronics'),
(2, 'Mouse', 'Electronics'),
(3, 'Shoes', 'Fashion');

INSERT INTO employees VALUES 
(1, 'Alice', 1),
(2, 'Bob', 1),
(3, 'Charlie', 2);

INSERT INTO sales VALUES 
(1, 1, 1, 1, '2025-07-01', 'offline', 2, 2000),
(2, 2, 1, 1, '2025-07-05', 'offline', 5, 150),
(3, 1, 2, 1, '2025-07-10', 'online', 1, 1000),
(4, 3, 3, 2, '2025-07-15', 'offline', 3, 300),
(5, 1, 3, 2, '2025-07-20', 'online', 1, 1000);

-- Subquery in SELECT to show each store’s revenue as % of total
SELECT 
    s.store_id,
    s.store_name,
    SUM(sa.amount) AS store_revenue,
    ROUND(
        100.0 * SUM(sa.amount) / 
        (SELECT SUM(amount) FROM sales), 2
    ) AS revenue_percentage
FROM stores s
JOIN sales sa ON s.store_id = sa.store_id
GROUP BY s.store_id, s.store_name;

-- Correlated subquery to find top performer in each region (by sales amount)
SELECT 
    e.employee_id,
    e.name,
    st.region,
    SUM(sa.amount) AS total_sales
FROM employees e
JOIN stores st ON e.store_id = st.store_id
JOIN sales sa ON e.employee_id = sa.employee_id
GROUP BY e.employee_id, e.name, st.region
HAVING SUM(sa.amount) = (
    SELECT MAX(total_region_sales)
    FROM (
        SELECT e2.employee_id, SUM(sa2.amount) AS total_region_sales
        FROM employees e2
        JOIN stores st2 ON e2.store_id = st2.store_id
        JOIN sales sa2 ON e2.employee_id = sa2.employee_id
        WHERE st2.region = st.region
        GROUP BY e2.employee_id
    ) region_totals
);

-- UNION to combine online and offline sales
SELECT sale_id, sale_type, amount FROM sales WHERE sale_type = 'online'
UNION
SELECT sale_id, sale_type, amount FROM sales WHERE sale_type = 'offline';

-- CASE WHEN to group products as “Top Seller”, “Medium”, “Low”
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_sold,
    CASE 
        WHEN SUM(s.quantity) >= 5 THEN 'Top Seller'
        WHEN SUM(s.quantity) >= 2 THEN 'Medium'
        ELSE 'Low'
    END AS product_rank
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;

-- Use DATE, MONTH, and YEAR to track monthly sales trends
SELECT 
    MONTH(sale_date) AS sale_month,
    YEAR(sale_date) AS sale_year,
    SUM(amount) AS monthly_sales
FROM sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY sale_year, sale_month;

-- Combine JOIN + GROUP BY + SUM() to show store-level performance
SELECT 
    st.store_name,
    COUNT(s.sale_id) AS total_transactions,
    SUM(s.amount) AS total_sales,
    SUM(s.quantity) AS total_items_sold
FROM stores st
JOIN sales s ON st.store_id = s.store_id
GROUP BY st.store_id, st.store_name;
