CREATE DATABASE online_food_ordering;
USE online_food_ordering;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    area VARCHAR(50)
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    area VARCHAR(50)
);

CREATE TABLE dishes (
    dish_id INT PRIMARY KEY,
    name VARCHAR(100),
    restaurant_id INT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    dish_id INT,
    order_type VARCHAR(20), -- 'Delivery' or 'Pickup'
    order_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id)
);

-- Sample Data
INSERT INTO customers VALUES
(1, 'Alice', 'Downtown'),
(2, 'Bob', 'Uptown'),
(3, 'Charlie', 'Downtown'),
(4, 'Diana', 'Suburb');

INSERT INTO restaurants VALUES
(1, 'Spicy Bites', 'Downtown'),
(2, 'Green Bowl', 'Uptown'),
(3, 'Taco Town', 'Suburb');

INSERT INTO dishes VALUES
(1, 'Burger', 1),
(2, 'Salad', 2),
(3, 'Taco', 3),
(4, 'Pasta', 1);

INSERT INTO orders VALUES
(101, 1, 1, 1, 'Delivery', '2025-08-01', 250.00),
(102, 2, 2, 2, 'Pickup', '2025-08-01', 180.00),
(103, 3, 1, 1, 'Delivery', '2025-08-02', 250.00),
(104, 4, 3, 3, 'Pickup', '2025-08-02', 200.00),
(105, 1, 1, 4, 'Delivery', '2025-08-03', 300.00),
(106, 3, 1, 1, 'Pickup', '2025-08-03', 250.00);

-- SELECT Subquery: Dish Popularity % = dish orders / total orders
SELECT 
    d.name AS dish_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(100.0 * COUNT(o.order_id) / 
        (SELECT COUNT(*) FROM orders), 2) AS popularity_percentage
FROM dishes d
JOIN orders o ON d.dish_id = o.dish_id
GROUP BY d.name;

-- FROM Subquery: Order volume by area
SELECT area, SUM(order_count) AS total_orders
FROM (
    SELECT c.area, COUNT(*) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.area
) AS area_orders
GROUP BY area;

-- CASE: Bucket customers by total number of orders
SELECT 
    c.name,
    COUNT(o.order_id) AS total_orders,
    CASE 
        WHEN COUNT(o.order_id) >= 3 THEN 'High'
        WHEN COUNT(o.order_id) = 2 THEN 'Medium'
        ELSE 'Low'
    END AS order_bucket
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- Correlated Subquery: Customer with highest order amount in each area
SELECT 
    c.name AS customer_name,
    c.area,
    o.amount AS highest_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.amount = (
    SELECT MAX(o2.amount)
    FROM orders o2
    JOIN customers c2 ON o2.customer_id = c2.customer_id
    WHERE c2.area = c.area
);

-- UNION ALL: Compare delivery and pickup orders
SELECT 'Delivery' AS order_type, customer_id, amount
FROM orders
WHERE order_type = 'Delivery'
UNION ALL
SELECT 'Pickup', customer_id, amount
FROM orders
WHERE order_type = 'Pickup';

-- GROUP orders by delivery date using DATE functions
SELECT 
    DATE(order_date) AS date,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_amount
FROM orders
GROUP BY DATE(order_date)
ORDER BY date;
