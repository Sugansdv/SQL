CREATE DATABASE sales_tracker;

USE sales_tracker;

-- Table: sales: sale_id, item_name, category, price, quantity, sale_date 
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    quantity INT,
    sale_date DATE
);

INSERT INTO sales (item_name, category, price, quantity, sale_date) VALUES
('iPhone Pro Max', 'Electronics', 1299.99, 2, '2025-07-25'),
('MacBook Pro', 'Electronics', 1999.99, 1, '2025-07-20'),
('Protein Bar', 'Health', 550.00, 5, '2025-07-28'),
('AirPods Pro', 'Electronics', 999.00, 3, '2025-07-29'),
('Blender', 'Home Appliance', 450.00, NULL, '2025-07-27'),
('Pro Gaming Mouse', 'Accessories', 700.00, 2, '2025-07-30');


-- Filter items with price > 500 and quantity >= 2. 
SELECT * 
FROM sales
WHERE price > 500
  AND quantity >= 2;

-- Use LIKE to find items containing "Pro". 
SELECT * 
FROM sales
WHERE item_name LIKE '%Pro%';

-- Check for NULL in quantity. 
SELECT * 
FROM sales
WHERE quantity IS NULL;

-- DISTINCT categories. 
SELECT DISTINCT category 
FROM sales;

-- Sort by sale_date DESC, price DESC.
SELECT item_name, category, price, quantity, sale_date
FROM sales
WHERE price > 500
  AND quantity >= 2
  AND item_name LIKE '%Pro%'
ORDER BY sale_date DESC, price DESC;

