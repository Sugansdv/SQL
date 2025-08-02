CREATE DATABASE IF NOT EXISTS GadgetStoreDB;
USE GadgetStoreDB;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(100),
    join_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO categories (category_name) VALUES
('Smartphones'), ('Laptops'), ('Accessories'), ('Wearables');

INSERT INTO products (product_name, category_id, price) VALUES
('iPhone 14', 1, 799.99),
('Galaxy S22', 1, 699.99),
('MacBook Pro', 2, 1299.99),
('Laptop Bag', 3, 49.99),
('Smartwatch', 4, 199.99),
('Wireless Mouse', 3, 29.99);

INSERT INTO customers (name, location, join_date) VALUES
('Alice', 'Mumbai', '2023-01-01'),
('Bob', 'Delhi', '2023-02-15'),
('Charlie', 'Bangalore', '2023-03-01'),
('David', 'Mumbai', '2023-04-20'),
('Eve', 'Chennai', '2023-06-10');

INSERT INTO orders (customer_id, product_id, order_date, quantity) VALUES
(1, 1, '2023-07-01', 1),
(1, 4, '2023-07-02', 2),
(2, 2, '2023-07-03', 1),
(3, 3, '2023-07-04', 1),
(4, 5, '2023-07-05', 1),
(4, 6, '2023-07-06', 2),
(2, 4, '2023-07-07', 1),
(5, 1, '2023-07-08', 1),
(1, 2, '2023-07-09', 1),
(1, 3, '2023-07-10', 1);

-- Use DISTINCT to get unique customer locations
SELECT DISTINCT location FROM customers;

-- Use BETWEEN to filter high-value orders (e.g., price > 500)
SELECT o.order_id, c.name, p.product_name, (p.price * o.quantity) AS total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE (p.price * o.quantity) BETWEEN 500 AND 1500;

-- Subquery in WHERE to find customers who never ordered accessories
SELECT * FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE p.category_id = (SELECT category_id FROM categories WHERE category_name = 'Accessories')
);

-- Use MAX(), MIN() for order value analytics
SELECT 
    MAX(p.price * o.quantity) AS max_order_value,
    MIN(p.price * o.quantity) AS min_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;

-- Use JOINs for full product category mapping
SELECT p.product_name, c.category_name, p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- Sort by most purchased products
SELECT 
    p.product_name, 
    SUM(o.quantity) AS total_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;

-- Requirement: CASE to label customers as "VIP" or "Regular"
SELECT 
    c.name,
    COUNT(o.order_id) AS total_orders,
    CASE 
        WHEN COUNT(o.order_id) > 3 THEN 'VIP'
        ELSE 'Regular'
    END AS customer_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
