CREATE DATABASE RetailSalesDB;
USE RetailSalesDB;

CREATE TABLE dim_time (
  time_id INT PRIMARY KEY,
  date DATE,
  day VARCHAR(10),
  month VARCHAR(10),
  quarter VARCHAR(10),
  year INT
);

CREATE TABLE dim_store (
  store_id INT PRIMARY KEY,
  store_name VARCHAR(100),
  location VARCHAR(100)
);

CREATE TABLE dim_product (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  brand VARCHAR(50)
);

CREATE TABLE dim_customer (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  gender VARCHAR(10),
  age INT
);

CREATE TABLE fact_sales (
  sales_id INT PRIMARY KEY,
  time_id INT,
  store_id INT,
  product_id INT,
  customer_id INT,
  quantity INT,
  total_amount DECIMAL(10, 2),
  FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
  FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
  FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);

INSERT INTO dim_time VALUES
(1, '2025-08-01', 'Friday', 'August', 'Q3', 2025),
(2, '2025-08-02', 'Saturday', 'August', 'Q3', 2025),
(3, '2025-08-03', 'Sunday', 'August', 'Q3', 2025);

INSERT INTO dim_store VALUES
(1, 'Store A', 'New York'),
(2, 'Store B', 'Los Angeles');

INSERT INTO dim_product VALUES
(1, 'Laptop', 'Electronics', 'Dell'),
(2, 'Phone', 'Electronics', 'Apple'),
(3, 'Shoes', 'Apparel', 'Nike');

INSERT INTO dim_customer VALUES
(1, 'Alice', 'Female', 30),
(2, 'Bob', 'Male', 40),
(3, 'Charlie', 'Male', 28);

INSERT INTO fact_sales VALUES
(1, 1, 1, 1, 1, 1, 900.00),
(2, 1, 1, 2, 2, 2, 2000.00),
(3, 2, 2, 3, 3, 1, 150.00),
(4, 3, 1, 1, 2, 1, 900.00),
(5, 3, 2, 2, 3, 1, 1000.00);

-- Daily sales report
SELECT dt.date, SUM(fs.total_amount) AS daily_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.date;

-- Monthly sales report
SELECT dt.month, dt.year, SUM(fs.total_amount) AS monthly_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.month, dt.year;

-- Quarterly sales report
SELECT dt.quarter, dt.year, SUM(fs.total_amount) AS quarterly_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id = dt.time_id
GROUP BY dt.quarter, dt.year;

-- Star schema performs faster joins due to denormalized dimensions
-- Snowflake schema normalizes dimensions which saves space but adds join complexity
