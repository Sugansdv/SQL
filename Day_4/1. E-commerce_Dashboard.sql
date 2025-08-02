-- Create and Use Database
CREATE DATABASE ecommerce_dashboard;
USE ecommerce_dashboard;

-- Tables: customers, orders, order_items, products
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    join_date DATE
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

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    customer_id INT,
    review_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert Data
INSERT INTO customers VALUES
(1, 'Alice', 'alice@example.com', '2023-12-15'),
(2, 'Bob', 'bob@example.com', '2022-06-20'),
(3, 'Charlie', 'charlie@example.com', '2025-01-10');

INSERT INTO products VALUES
(1, 'Laptop', 1000.00),
(2, 'Mouse', 30.00),
(3, 'Keyboard', 60.00);

INSERT INTO orders VALUES
(101, 1, '2025-03-01'),
(102, 1, '2025-05-01'),
(103, 2, '2025-04-01'),
(104, 3, '2025-06-01');

INSERT INTO order_items VALUES
(1, 101, 1, 1),
(2, 101, 2, 2),
(3, 102, 3, 1),
(4, 103, 2, 3),
(5, 104, 1, 1);

INSERT INTO reviews VALUES
(1, 1, '2025-03-15'),
(2, 3, '2025-07-20');

-- Subquery in SELECT to calculate customer’s average order value
SELECT 
    c.customer_id,
    c.name,
    (
        SELECT AVG(order_total)
        FROM (
            SELECT SUM(oi.quantity * p.price) AS order_total
            FROM orders o
            JOIN order_items oi ON o.order_id = oi.order_id
            JOIN products p ON oi.product_id = p.product_id
            WHERE o.customer_id = c.customer_id
            GROUP BY o.order_id
        ) AS avg_per_order
    ) AS average_order_value
FROM customers c;

-- Subquery in FROM to get total revenue per product
SELECT 
    p.name AS product_name,
    revenue_summary.total_revenue
FROM (
    SELECT 
        oi.product_id,
        SUM(oi.quantity * p.price) AS total_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY oi.product_id
) revenue_summary
JOIN products p ON revenue_summary.product_id = p.product_id;

-- Correlated subquery to find customers whose orders are above their own average
SELECT o.order_id, o.customer_id, o.order_date
FROM orders o
WHERE (
    SELECT SUM(oi.quantity * p.price)
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = o.order_id
) > (
    SELECT AVG(sub_total)
    FROM (
        SELECT SUM(oi2.quantity * p2.price) AS sub_total
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        JOIN products p2 ON oi2.product_id = p2.product_id
        WHERE o2.customer_id = o.customer_id
        GROUP BY o2.order_id
    ) avg_orders
);

-- UNION to combine old and new customers
SELECT customer_id, name, 'Old' AS type
FROM customers
WHERE join_date < '2024-01-01'

UNION

SELECT customer_id, name, 'New' AS type
FROM customers
WHERE join_date >= '2024-01-01';

-- INTERSECT to find customers who placed orders and submitted reviews
-- (MySQL does not support INTERSECT; using IN as alternative)
SELECT customer_id, name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders)
  AND customer_id IN (SELECT customer_id FROM reviews);

-- CASE to categorize customers: High Spender, Medium, Low
-- Use DATE() and YEAR() to filter orders in current year
SELECT 
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS total_spent,
    CASE
        WHEN SUM(oi.quantity * p.price) >= 1000 THEN 'High Spender'
        WHEN SUM(oi.quantity * p.price) >= 500 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spender_category
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY c.customer_id, c.name;
