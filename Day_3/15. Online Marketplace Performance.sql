CREATE DATABASE online_marketplace;
USE online_marketplace;

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE buyers (
    buyer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    seller_id INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    product_id INT,
    buyer_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id)
);

-- Sellers
INSERT INTO sellers VALUES
(1, 'Raj Enterprises', 'Mumbai'),
(2, 'Delhi Mart', 'Delhi'),
(3, 'Chennai Deals', 'Chennai'),
(4, 'Bangalore Store', 'Bangalore'),
(5, 'Mumbai Bazaar', 'Mumbai');

-- Buyers
INSERT INTO buyers VALUES
(1, 'Amit', 'amit@mail.com'),
(2, 'Priya', 'priya@mail.com'),
(3, 'Rahul', 'rahul@mail.com');

-- Products
INSERT INTO products VALUES
(1, 'Laptop', 55000, 1),
(2, 'Phone', 20000, 2),
(3, 'Headphones', 2500, 1),
(4, 'Monitor', 12000, 3),
(5, 'Keyboard', 1500, 4),
(6, 'Mouse', 800, 5),
(7, 'Tablet', 15000, 2);

-- Purchases
INSERT INTO purchases VALUES
(1, 1, 1, 2, '2025-07-01'),
(2, 2, 1, 3, '2025-07-02'),
(3, 3, 2, 5, '2025-07-03'),
(4, 4, 3, 1, '2025-07-04'),
(5, 2, 2, 2, '2025-07-05'),
(6, 5, 1, 4, '2025-07-06'),
(7, 1, 3, 1, '2025-07-07'),
(8, 7, 3, 3, '2025-07-08'),
(9, 6, 2, 10, '2025-07-09');

-- 1. Revenue generated per seller (SUM)
SELECT s.name AS seller_name, SUM(p.price * pu.quantity) AS total_revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN purchases pu ON p.product_id = pu.product_id
GROUP BY s.seller_id, s.name;

-- 2. Most purchased products (COUNT)
SELECT pr.name AS product_name, COUNT(pu.purchase_id) AS times_purchased
FROM products pr
JOIN purchases pu ON pr.product_id = pu.product_id
GROUP BY pr.product_id, pr.name
ORDER BY times_purchased DESC;

-- 3. Sellers with revenue > ₹1,00,000
SELECT s.name AS seller_name, SUM(p.price * pu.quantity) AS total_revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN purchases pu ON p.product_id = pu.product_id
GROUP BY s.seller_id, s.name
HAVING SUM(p.price * pu.quantity) > 100000;

-- 4. INNER JOIN: purchases ↔ products ↔ sellers
SELECT pu.purchase_id, pr.name AS product_name, s.name AS seller_name, pu.quantity, pu.purchase_date
FROM purchases pu
INNER JOIN products pr ON pu.product_id = pr.product_id
INNER JOIN sellers s ON pr.seller_id = s.seller_id;

-- 5. LEFT JOIN: sellers ↔ products (even those without products)
SELECT s.name AS seller_name, p.name AS product_name
FROM sellers s
LEFT JOIN products p ON s.seller_id = p.seller_id;

-- 6. SELF JOIN: sellers from the same city
SELECT s1.name AS seller1, s2.name AS seller2, s1.city
FROM sellers s1
JOIN sellers s2 ON s1.city = s2.city AND s1.seller_id < s2.seller_id;
