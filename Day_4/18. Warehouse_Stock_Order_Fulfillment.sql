CREATE DATABASE WarehouseDB;
USE WarehouseDB;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    reorder_level INT
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT,
    stock_quantity INT,
    expiry_date DATE,
    warehouse_type VARCHAR(10), -- 'online' or 'offline'
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    supplier_id INT,
    quantity INT,
    fulfilled_quantity INT,
    delivery_delay_days INT,
    order_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

INSERT INTO products VALUES
(1, 'Rice', 'Grains', 100),
(2, 'Wheat', 'Grains', 150),
(3, 'Sugar', 'Sweetener', 200),
(4, 'Salt', 'Condiments', 50);

INSERT INTO inventory VALUES
(1, 1, 80, '2025-09-01', 'online'),
(2, 2, 160, '2025-08-15', 'offline'),
(3, 3, 190, '2025-08-10', 'online'),
(4, 4, 30, '2025-10-01', 'offline');

INSERT INTO suppliers VALUES
(1, 'AgriCorp'),
(2, 'FoodSupply'),
(3, 'GlobalGoods');

INSERT INTO orders VALUES
(1, 1, 1, 100, 90, 2, '2025-08-01'),
(2, 2, 2, 150, 150, 0, '2025-07-25'),
(3, 3, 2, 200, 180, 5, '2025-07-28'),
(4, 4, 3, 50, 45, 1, '2025-08-02');

-- Subquery in WHERE to show products below reorder level. 
SELECT product_name, stock_quantity
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE stock_quantity < (
    SELECT reorder_level
    FROM products
    WHERE products.product_id = i.product_id
);

-- CASE to categorize products as Fast, Medium, Slow moving.
SELECT product_name,
       stock_quantity,
       CASE
           WHEN stock_quantity >= 150 THEN 'Fast'
           WHEN stock_quantity BETWEEN 100 AND 149 THEN 'Medium'
           ELSE 'Slow'
       END AS movement_category
FROM inventory i
JOIN products p ON i.product_id = p.product_id;
 
-- Correlated subquery to get supplier with least delayed deliveries. 
SELECT supplier_id, supplier_name
FROM suppliers s
WHERE delivery_delay_days = (
    SELECT MIN(delivery_delay_days)
    FROM orders o
    WHERE o.supplier_id = s.supplier_id
);

-- JOIN + GROUP BY for fulfillment rate by supplier. 
SELECT s.supplier_name,
       SUM(o.fulfilled_quantity) * 100.0 / SUM(o.quantity) AS fulfillment_rate
FROM orders o
JOIN suppliers s ON o.supplier_id = s.supplier_id
GROUP BY s.supplier_name;

-- UNION ALL for online and offline stock. 
SELECT 'online' AS warehouse_type, product_id, stock_quantity
FROM inventory
WHERE warehouse_type = 'online'
UNION ALL
SELECT 'offline', product_id, stock_quantity
FROM inventory
WHERE warehouse_type = 'offline';

-- Date filtering for expiry tracking. 
SELECT p.product_name, i.stock_quantity, i.expiry_date
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE expiry_date <= CURDATE() + INTERVAL 30 DAY;


