CREATE DATABASE EcomWarehouse;
USE EcomWarehouse;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    gender VARCHAR(10),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES 
(1, 'Alice', 'alice@gmail.com', 'Female', 'South'),
(2, 'Bob', 'bob@gmail.com', 'Male', 'North'),
(3, 'Charlie', 'charlie@gmail.com', 'Male', 'East');

INSERT INTO products VALUES 
(101, 'Phone A', 'Electronics', 'BrandX', 299.99),
(102, 'Phone B', 'Electronics', 'BrandY', 399.99),
(103, 'Laptop A', 'Computers', 'BrandZ', 899.99);

INSERT INTO orders VALUES 
(1001, 1, '2023-01-15', 'Delivered'),
(1002, 2, '2023-02-20', 'Delivered'),
(1003, 1, '2023-03-05', 'Pending');

INSERT INTO order_items VALUES 
(1, 1001, 101, 2, 299.99),
(2, 1002, 102, 1, 399.99),
(3, 1003, 103, 1, 899.99);

-- Design a Snowflake Schema with normalized dimensions
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    region_id INT
);

CREATE TABLE dim_region (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    brand_id INT,
    price DECIMAL(10,2)
);

CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE dim_brand (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(50)
);

CREATE TABLE dim_date (
    date_id DATE PRIMARY KEY,
    day INT,
    month INT,
    year INT,
    quarter INT
);

CREATE TABLE fact_orders (
    order_id INT,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    total_amount DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (order_date) REFERENCES dim_date(date_id)
);

-- Use ETL scripts to clean and load data into fact_orders
INSERT INTO dim_region VALUES
(1, 'South'),
(2, 'North'),
(3, 'East');

INSERT INTO dim_customer
SELECT 
    c.customer_id, c.name, c.gender, 
    CASE 
        WHEN c.region = 'South' THEN 1
        WHEN c.region = 'North' THEN 2
        WHEN c.region = 'East' THEN 3
    END as region_id
FROM customers c;

INSERT INTO dim_category VALUES
(1, 'Electronics'),
(2, 'Computers');

INSERT INTO dim_brand VALUES
(1, 'BrandX'),
(2, 'BrandY'),
(3, 'BrandZ');

INSERT INTO dim_product
SELECT 
    p.product_id, p.name,
    CASE 
        WHEN p.category = 'Electronics' THEN 1
        WHEN p.category = 'Computers' THEN 2
    END as category_id,
    CASE 
        WHEN p.brand = 'BrandX' THEN 1
        WHEN p.brand = 'BrandY' THEN 2
        WHEN p.brand = 'BrandZ' THEN 3
    END as brand_id,
    p.price
FROM products p;

INSERT INTO dim_date
SELECT DISTINCT 
    o.order_date,
    DAY(o.order_date),
    MONTH(o.order_date),
    YEAR(o.order_date),
    QUARTER(o.order_date)
FROM orders o;

INSERT INTO fact_orders
SELECT 
    o.order_id,
    o.order_date,
    o.customer_id,
    oi.product_id,
    oi.quantity,
    oi.quantity * oi.unit_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- Create aggregation reports like top-selling products, seasonal trends
SELECT 
    dp.name AS product_name,
    SUM(fo.quantity) AS total_units_sold,
    SUM(fo.total_amount) AS total_sales
FROM fact_orders fo
JOIN dim_product dp ON fo.product_id = dp.product_id
GROUP BY dp.name
ORDER BY total_units_sold DESC;

SELECT 
    dd.month,
    SUM(fo.total_amount) AS monthly_sales
FROM fact_orders fo
JOIN dim_date dd ON fo.order_date = dd.date_id
GROUP BY dd.month
ORDER BY dd.month;

-- Show how OLAP queries (drill-down, roll-up) support decisions
-- Roll-up: Sales by Category
SELECT 
    dc.category_name,
    SUM(fo.total_amount) AS total_sales
FROM fact_orders fo
JOIN dim_product dp ON fo.product_id = dp.product_id
JOIN dim_category dc ON dp.category_id = dc.category_id
GROUP BY dc.category_name;

-- Drill-down: Sales by Brand within Category
SELECT 
    dc.category_name,
    db.brand_name,
    SUM(fo.total_amount) AS total_sales
FROM fact_orders fo
JOIN dim_product dp ON fo.product_id = dp.product_id
JOIN dim_category dc ON dp.category_id = dc.category_id
JOIN dim_brand db ON dp.brand_id = db.brand_id
GROUP BY dc.category_name, db.brand_name;
