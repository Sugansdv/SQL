CREATE DATABASE product_inventory;

USE product_inventory;

--  Table: products: product_id, name, category, price, stock, supplier, description 
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT,
    supplier VARCHAR(100),
    description TEXT
);

INSERT INTO products (name, category, price, stock, supplier, description) VALUES
('Smartphone X', 'Electronics', 799.99, 20, 'TechCorp', 'Latest model smartphone'),
('Budget Phone', 'Electronics', 199.99, 0, 'TechCorp', NULL),
('Laptop Pro', 'Computers', 1200.00, 10, 'CompHub', 'High-performance laptop'),
('Gaming Phone', 'Electronics', 999.00, 15, 'GamerTech', 'Designed for gamers'),
('Washing Machine', 'Appliances', 650.00, 5, 'HomeMakers', NULL),
('LED TV', 'Electronics', 5200.00, 3, 'VisionPlus', '4K Ultra HD'),
('Wireless Charger', 'Accessories', 150.00, 25, 'ChargeCo', 'Fast charging pad'),
('Phone Case', 'Accessories', 120.00, 50, 'CoverKing', 'Silicone protective case');

-- List all products with price between 100 and 1000. 
-- Select only name, category, and price.
SELECT name, category, price
FROM products
WHERE price BETWEEN 100 AND 1000;

-- Use LIKE to find products with “phone” in the name. 
SELECT name
FROM products
WHERE name LIKE '%phone%';

-- Retrieve items with NULL description. 
SELECT name, description
FROM products
WHERE description IS NULL;

-- Use DISTINCT to list all suppliers. 
SELECT DISTINCT supplier
FROM products;

-- Filter products where stock is 0 OR price > 5000. 
SELECT name, stock, price 
FROM products
where stock = 0 OR price > 5000;

-- Sort by category, then price DESC. 
SELECT category, price
FROM products
ORDER BY category ASC, price DESC;

