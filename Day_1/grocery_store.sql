CREATE DATABASE grocery_store;
USE grocery_store;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    contact_email VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    discontinued BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

INSERT INTO categories (name) VALUES 
('Fruits'),
('Vegetables'),
('Dairy'),
('Bakery'),
('Beverages');

INSERT INTO suppliers (name, contact_email) VALUES 
('Fresh Farms', 'contact@freshfarms.com'),
('GreenGrocers', 'info@greengrocers.com'),
('DairyPure', 'support@dairypure.com'),
('BakersBest', 'hello@bakersbest.com'),
('ColdDrinks Inc', 'sales@colddrinks.com');

INSERT INTO products (name, price, stock, category_id, supplier_id) VALUES
('Apple', 1.20, 100, 1, 1),
('Banana', 0.50, 120, 1, 1),
('Orange', 0.80, 80, 1, 1),
('Tomato', 0.90, 90, 2, 2),
('Potato', 0.60, 150, 2, 2),
('Carrot', 0.70, 110, 2, 2),
('Milk', 1.50, 60, 3, 3),
('Cheese', 2.50, 40, 3, 3),
('Butter', 3.00, 35, 3, 3),
('Bread', 2.00, 75, 4, 4),
('Bun', 1.00, 80, 4, 4),
('Croissant', 2.50, 50, 4, 4),
('Cola', 1.10, 90, 5, 5),
('Orange Juice', 1.80, 70, 5, 5),
('Lemonade', 1.20, 65, 5, 5),
('Strawberries', 2.20, 60, 1, 1),
('Spinach', 1.10, 50, 2, 2),
('Yogurt', 1.30, 45, 3, 3),
('Bagel', 1.50, 55, 4, 4),
('Water Bottle', 0.90, 200, 5, 5);

-- Increase stock of 'Apple' by 50
UPDATE products
SET stock = stock + 50
WHERE name = 'Apple';


-- Mark a product as discontinued first (optional)
UPDATE products
SET discontinued = TRUE
WHERE name = 'Croissant';

-- delete discontinued products
DELETE FROM products
WHERE discontinued = TRUE;

SELECT c.name AS category, COUNT(p.product_id) AS total_products
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id;