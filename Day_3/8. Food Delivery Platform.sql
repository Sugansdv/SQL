CREATE DATABASE food_delivery_db;
USE food_delivery_db;

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE delivery_agents (
    agent_id INT PRIMARY KEY,
    name VARCHAR(100),
    contact VARCHAR(15)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    restaurant_id INT,
    agent_id INT,
    order_date DATE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    item_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Restaurants
INSERT INTO restaurants VALUES
(1, 'Tandoori Treats', 'Mumbai'),
(2, 'Spice Route', 'Delhi'),
(3, 'Veggie Delight', 'Mumbai'),
(4, 'Coastal Curry', 'Chennai');

-- Delivery Agents
INSERT INTO delivery_agents VALUES
(1, 'Amit', '9876543210'),
(2, 'Ravi', '8765432109'),
(3, 'Sneha', '7654321098');

-- Orders
INSERT INTO orders VALUES
(101, 1, 1, '2025-07-01'),
(102, 2, 2, '2025-07-02'),
(103, 1, 1, '2025-07-03'),
(104, 3, 3, '2025-07-04'),
(105, 3, 2, '2025-07-05'),
(106, 1, 1, '2025-07-06');

-- Order Items
INSERT INTO order_items VALUES
(1, 101, 'Paneer Tikka', 2, 250),
(2, 101, 'Butter Naan', 4, 50),
(3, 102, 'Biryani', 1, 300),
(4, 103, 'Tandoori Chicken', 1, 450),
(5, 104, 'Veg Thali', 2, 200),
(6, 105, 'Salad', 3, 100),
(7, 106, 'Kebab', 2, 300);

-- 1. Total orders per restaurant
SELECT r.name AS restaurant_name, COUNT(o.order_id) AS total_orders
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.name;

-- 2. Sum of order values per delivery agent
SELECT da.name AS agent_name, SUM(oi.quantity * oi.price) AS total_value
FROM delivery_agents da
JOIN orders o ON da.agent_id = o.agent_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY da.name;

-- 3. Restaurants with revenue > ₹50,000 (HAVING)
SELECT r.name AS restaurant_name, SUM(oi.quantity * oi.price) AS revenue
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY r.name
HAVING SUM(oi.quantity * oi.price) > 50000;

-- 4. INNER JOIN: restaurants ↔ orders
SELECT r.name AS restaurant_name, o.order_id, o.order_date
FROM restaurants r
INNER JOIN orders o ON r.restaurant_id = o.restaurant_id;

-- 5. LEFT JOIN: delivery agents ↔ orders
SELECT da.name AS agent_name, o.order_id
FROM delivery_agents da
LEFT JOIN orders o ON da.agent_id = o.agent_id;

-- 6. SELF JOIN to find restaurants in the same location
SELECT r1.name AS restaurant1, r2.name AS restaurant2, r1.location
FROM restaurants r1
JOIN restaurants r2 ON r1.location = r2.location AND r1.restaurant_id < r2.restaurant_id;
