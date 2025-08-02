CREATE DATABASE IF NOT EXISTS ShoppingDB;
USE ShoppingDB;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE carts (
    cart_id INT PRIMARY KEY,
    user_id INT,
    cart_date DATE,
    status VARCHAR(20), -- 'Completed' or 'Abandoned'
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    cart_id INT,
    order_date DATE,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id)
);

CREATE TABLE cart_items (
    cart_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO users VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com');

INSERT INTO products VALUES
(101, 'Phone', 699.99),
(102, 'Laptop', 1299.00),
(103, 'Headphones', 199.99);

INSERT INTO carts VALUES
(1, 1, '2025-07-20', 'Abandoned'),
(2, 1, '2025-07-22', 'Abandoned'),
(3, 1, '2025-07-25', 'Abandoned'),
(4, 1, '2025-07-27', 'Abandoned'),
(5, 2, '2025-07-21', 'Completed'),
(6, 3, '2025-07-26', 'Abandoned');

INSERT INTO orders VALUES
(1, 5, '2025-07-21');

INSERT INTO cart_items VALUES
(1, 101, 1),
(2, 101, 1),
(3, 102, 1),
(4, 103, 1),
(5, 103, 1),
(6, 101, 1);

-- Subquery to find users who abandon carts > 3 times.
SELECT user_id, name
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM carts
    WHERE status = 'Abandoned'
    GROUP BY user_id
    HAVING COUNT(*) > 3
);
 
-- CASE to label cart status: Completed, Abandoned. 
SELECT
    cart_id,
    user_id,
    cart_date,
    CASE
        WHEN status = 'Completed' THEN 'Order Placed'
        ELSE 'Abandoned Cart'
    END AS cart_status
FROM carts;

-- UNION for items added to cart and items actually purchased. 
-- Items added to cart
SELECT
    ci.product_id,
    p.product_name,
    'Added to Cart' AS action
FROM cart_items ci
JOIN products p ON ci.product_id = p.product_id

UNION

-- Items actually purchased (only from carts that had orders)
SELECT
    ci.product_id,
    p.product_name,
    'Purchased' AS action
FROM orders o
JOIN carts c ON o.cart_id = c.cart_id
JOIN cart_items ci ON c.cart_id = ci.cart_id
JOIN products p ON ci.product_id = p.product_id;

-- Correlated subquery to find most abandoned product per user. 
SELECT DISTINCT
    u.user_id,
    u.name,
    p.product_name,
    (
        SELECT COUNT(*)
        FROM carts c2
        JOIN cart_items ci2 ON c2.cart_id = ci2.cart_id
        WHERE c2.status = 'Abandoned'
          AND c2.user_id = u.user_id
          AND ci2.product_id = ci.product_id
    ) AS abandonment_count
FROM users u
JOIN carts c ON u.user_id = c.user_id
JOIN cart_items ci ON c.cart_id = ci.cart_id
JOIN products p ON ci.product_id = p.product_id
WHERE c.status = 'Abandoned'
AND ci.product_id = (
    SELECT ci3.product_id
    FROM cart_items ci3
    JOIN carts c3 ON ci3.cart_id = c3.cart_id
    WHERE c3.user_id = u.user_id AND c3.status = 'Abandoned'
    GROUP BY ci3.product_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Date filtering for abandonments in the last week. 
SELECT *
FROM carts
WHERE status = 'Abandoned'
AND cart_date >= CURDATE() - INTERVAL 7 DAY;

-- JOIN + GROUP BY to see cart conversion rate. 
SELECT
    u.user_id,
    u.name,
    COUNT(c.cart_id) AS total_carts,
    SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) AS completed_carts,
    ROUND(100.0 * SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) / COUNT(c.cart_id), 2) AS conversion_rate_pct
FROM users u
JOIN carts c ON u.user_id = c.user_id
GROUP BY u.user_id;
