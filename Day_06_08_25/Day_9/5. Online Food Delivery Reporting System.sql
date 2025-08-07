CREATE DATABASE FoodDeliveryReports;
USE FoodDeliveryReports;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    food_category VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    name VARCHAR(100),
    vehicle_type VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    order_date DATE,
    order_time TIME,
    delivery_time TIME,
    total_cost DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

INSERT INTO customers VALUES
(1, 'Alice', 'alice@gmail.com', 'Chennai', 'South'),
(2, 'Bob', 'bob@gmail.com', 'Delhi', 'North'),
(3, 'Charlie', 'charlie@gmail.com', 'Mumbai', 'West');

INSERT INTO restaurants VALUES
(101, 'Tandoori Hub', 'Indian', 'Delhi'),
(102, 'Pizza World', 'Italian', 'Mumbai'),
(103, 'Veggie Delight', 'Vegan', 'Chennai');

INSERT INTO drivers VALUES
(201, 'Ravi', 'Bike', 'Chennai'),
(202, 'Sunil', 'Scooter', 'Delhi'),
(203, 'Karan', 'Car', 'Mumbai');

INSERT INTO orders VALUES
(301, 1, 103, 201, '2023-08-01', '12:00:00', '12:25:00', 400.00, 40.00),
(302, 2, 101, 202, '2023-08-01', '13:00:00', '13:50:00', 550.00, 50.00),
(303, 3, 102, 203, '2023-08-02', '19:30:00', '20:00:00', 600.00, 60.00);

-- Create Snowflake Schema with normalized customer and location tables
CREATE TABLE dim_city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city_id INT
);

CREATE TABLE dim_restaurant (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    city_id INT
);

CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY,
    name VARCHAR(100),
    vehicle_type VARCHAR(50),
    city_id INT
);

CREATE TABLE dim_time (
    date_id DATE PRIMARY KEY,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(20)
);

CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    order_date DATE,
    order_time TIME,
    delivery_time TIME,
    delivery_minutes INT,
    food_cost DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    total_cost DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    FOREIGN KEY (order_date) REFERENCES dim_time(date_id)
);

-- ETL includes data cleanup, time parsing, and cost breakdown
INSERT INTO dim_city VALUES
(1, 'Chennai', 'South'),
(2, 'Delhi', 'North'),
(3, 'Mumbai', 'West');

INSERT INTO dim_customer
SELECT 
    c.customer_id, c.name, c.email,
    CASE 
        WHEN c.city = 'Chennai' THEN 1
        WHEN c.city = 'Delhi' THEN 2
        WHEN c.city = 'Mumbai' THEN 3
    END AS city_id
FROM customers c;

INSERT INTO dim_restaurant
SELECT 
    r.restaurant_id, r.name, r.food_category,
    CASE 
        WHEN r.city = 'Chennai' THEN 1
        WHEN r.city = 'Delhi' THEN 2
        WHEN r.city = 'Mumbai' THEN 3
    END AS city_id
FROM restaurants r;

INSERT INTO dim_driver
SELECT 
    d.driver_id, d.name, d.vehicle_type,
    CASE 
        WHEN d.city = 'Chennai' THEN 1
        WHEN d.city = 'Delhi' THEN 2
        WHEN d.city = 'Mumbai' THEN 3
    END AS city_id
FROM drivers d;

INSERT INTO dim_time
SELECT DISTINCT 
    order_date,
    DAY(order_date),
    MONTH(order_date),
    YEAR(order_date),
    DATENAME(WEEKDAY, order_date)
FROM orders;

INSERT INTO fact_orders
SELECT 
    o.order_id,
    o.customer_id,
    o.restaurant_id,
    o.driver_id,
    o.order_date,
    o.order_time,
    o.delivery_time,
    DATEDIFF(MINUTE, o.order_time, o.delivery_time),
    o.total_cost - o.delivery_fee,
    o.delivery_fee,
    o.total_cost
FROM orders o;

-- Aggregation reports: avg delivery time by region, food category trends
SELECT 
    dc.region,
    AVG(f.delivery_minutes) AS avg_delivery_time
FROM fact_orders f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_city dc ON c.city_id = dc.city_id
GROUP BY dc.region;

SELECT 
    r.category,
    COUNT(f.order_id) AS total_orders
FROM fact_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.category;

-- OLAP queries for city-wise, vendor-wise KPIs
SELECT 
    c.city_name,
    COUNT(f.order_id) AS total_orders,
    SUM(f.total_cost) AS total_revenue
FROM fact_orders f
JOIN dim_city c ON f.order_date = f.order_date AND c.city_id = (
    SELECT city_id FROM dim_customer WHERE customer_id = f.customer_id
)
GROUP BY c.city_name;

SELECT 
    r.name AS restaurant_name,
    COUNT(f.order_id) AS total_orders,
    SUM(f.food_cost) AS total_food_sales
FROM fact_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.name;
