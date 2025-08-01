CREATE DATABASE order_management;

USE order_management;

-- Table: orders: order_id, customer_name, total, order_date, status, address
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    total DECIMAL(10, 2),
    order_date DATE,
    status VARCHAR(20),
    address VARCHAR(200)
);

INSERT INTO orders (customer_name, total, order_date, status, address) VALUES
('Rajesh Kumar', 1500.00, CURDATE() - INTERVAL 2 DAY, 'Delivered', '123 Main Street'),
('Rita Shah', 2500.00, CURDATE() - INTERVAL 6 DAY, 'Pending', '456 Oak Avenue'),
('Anil Mehta', 800.00, CURDATE() - INTERVAL 10 DAY, 'Shipped', '789 Pine Road'),
('Ramesh Patel', 1200.00, CURDATE() - INTERVAL 1 DAY, NULL, '321 Elm Street'),
('Sneha Kapoor', 2000.00, CURDATE() - INTERVAL 4 DAY, 'Delivered', '123 Main Street'),
('Rahul Dev', 1750.00, CURDATE() - INTERVAL 3 DAY, NULL, '456 Oak Avenue'),
('Priya Nair', 900.00, CURDATE() - INTERVAL 8 DAY, 'Cancelled', '222 Lake Blvd');

-- Retrieve orders placed in the last 7 days.
SELECT customer_name, order_date, status
FROM orders
WHERE order_date >= CURDATE() - INTERVAL 7 DAY;

-- Use LIKE for customer names starting with “R”.
SELECT customer_name
FROM orders
WHERE customer_name LIKE 'R%';

-- Check for NULL status.
SELECT * 
FROM orders
WHERE status IS NULL;

-- Use DISTINCT to list addresses.
SELECT DISTINCT address 
FROM orders;

-- Sort by order_date DESC, total DESC.
SELECT customer_name, order_date, total
FROM orders
ORDER BY order_date DESC, total DESC;
