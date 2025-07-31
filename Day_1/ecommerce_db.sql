CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE brands (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);


CREATE TABLE favorites (
    user_id INT,
    product_id INT,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO brands (name) VALUES 
('Apple'),
('Samsung'),
('Nike'),
('Adidas'),
('Sony');

INSERT INTO categories (name) VALUES 
('Electronics'),
('Footwear'),
('Clothing'),
('Accessories'),
('Home Appliances');

INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('alex_jones', 'alex@example.com');

INSERT INTO products (name, price, brand_id, category_id) VALUES
('iPhone 14', 999.99, 1, 1),
('Galaxy S22', 799.99, 2, 1),
('Air Jordan', 149.99, 3, 2),
('Ultraboost', 129.99, 4, 2),
('Sony Headphones', 89.99, 5, 1),
('Apple Watch', 399.99, 1, 4),
('Adidas T-Shirt', 39.99, 4, 3),
('Nike Socks', 9.99, 3, 3),
('Samsung TV', 499.99, 2, 5),
('Sony Speaker', 59.99, 5, 5);
INSERT INTO favorites (user_id, product_id) VALUES
(1, 1),
(1, 5),
(2, 3),
(2, 1),
(3, 1),
(3, 2),
(3, 6);

-- a) Get product details by category
SELECT 
    p.name AS product_name, 
    p.price, 
    c.name AS category 
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.name = 'Electronics';

-- b) List products by brand
SELECT 
    p.name AS product_name, 
    p.price, 
    b.name AS brand 
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
WHERE b.name = 'Apple';

-- c) Find most favorited products
SELECT 
    p.name AS product_name,
    COUNT(f.user_id) AS total_favorites
FROM favorites f
JOIN products p ON f.product_id = p.product_id
GROUP BY f.product_id
ORDER BY total_favorites DESC
LIMIT 5;