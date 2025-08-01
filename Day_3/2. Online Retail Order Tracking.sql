CREATE DATABASE retail_db;

USE retail_db;

-- 1. Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2. Insert sample data

-- Customers
INSERT INTO customers (customer_id, name, email) VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com');

-- Products
INSERT INTO products (product_id, name, price) VALUES
(101, 'Laptop', 50000),
(102, 'Headphones', 2000),
(103, 'Keyboard', 1500),
(104, 'Monitor', 8000),
(105, 'Mouse', 500);

-- Orders
INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1001, 1, '2025-07-01'),
(1002, 1, '2025-07-15'),
(1003, 2, '2025-07-20');

-- Order Items
INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
(1, 1001, 101, 1),
(2, 1001, 102, 2),
(3, 1002, 104, 1),
(4, 1003, 102, 1),
(5, 1003, 105, 4);

-- 3. Total amount spent per customer
SELECT 
    c.name AS customer_name,
    SUM(p.price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name;

-- 4. Products sold count and total revenue
SELECT 
    p.name AS product_name,
    COUNT(oi.item_id) AS times_sold,
    SUM(p.price * oi.quantity) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name;

-- 5. Group sales by product and filter with HAVING SUM > 10000
SELECT 
    p.name AS product_name,
    SUM(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
HAVING SUM(p.price * oi.quantity) > 10000;

-- 6. INNER JOIN orders ↔ order_items, order_items ↔ products
SELECT 
    o.order_id,
    p.name AS product_name,
    oi.quantity,
    (p.price * oi.quantity) AS total_price
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id;

-- 7. LEFT JOIN to show customers without orders
SELECT 
    c.name AS customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 8. RIGHT JOIN to show products that were never sold
SELECT 
    p.name AS product_name,
    oi.item_id
FROM order_items oi
RIGHT JOIN products p ON oi.product_id = p.product_id
WHERE oi.item_id IS NULL;
