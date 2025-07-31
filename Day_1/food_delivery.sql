CREATE DATABASE food_delivery;

USE food_delivery;

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE menus (
    menu_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100),
    price DECIMAL(10, 2),
    restaurant_id INT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    address VARCHAR(255)
);

CREATE TABLE delivery_agents (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    menu_id INT,
    agent_id INT,
    order_date DATE,
    status VARCHAR(50), -- e.g., 'Pending', 'Delivered', 'Cancelled'
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (menu_id) REFERENCES menus(menu_id),
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
);
INSERT INTO restaurants (name, location) VALUES
('Spice Villa', 'Chennai'),
('Tandoori Treats', 'Delhi'),
('Pasta Palace', 'Mumbai'),
('Sushi Spot', 'Bangalore'),
('Burger World', 'Hyderabad');

INSERT INTO menus (item_name, price, restaurant_id) VALUES
('Paneer Tikka', 250.00, 1),
('Butter Chicken', 300.00, 1),
('Veg Biryani', 180.00, 2),
('Chicken Biryani', 220.00, 2),
('Spaghetti', 200.00, 3),
('Margherita Pizza', 240.00, 3),
('Salmon Sushi', 350.00, 4),
('California Roll', 320.00, 4),
('Veg Burger', 150.00, 5),
('Cheese Burger', 170.00, 5);

INSERT INTO customers (name, address) VALUES
('Arun', 'Chennai'),
('Bhavya', 'Delhi'),
('Chitra', 'Mumbai'),
('Dinesh', 'Bangalore'),
('Elena', 'Hyderabad'),
('Farhan', 'Pune'),
('Geetha', 'Chennai'),
('Hari', 'Delhi');

INSERT INTO delivery_agents (name, phone) VALUES
('Ravi', '9000000011'),
('Suman', '9000000012'),
('Ajay', '9000000013'),
('Meena', '9000000014'),
('Kiran', '9000000015');

INSERT INTO orders (customer_id, menu_id, agent_id, order_date, status) VALUES
(1, 1, 1, '2025-07-30', 'Pending'),
(2, 2, 2, '2025-07-29', 'Delivered'),
(3, 3, 3, '2025-07-28', 'Pending'),
(4, 4, 1, '2025-07-30', 'Cancelled'),
(5, 5, 4, '2025-07-30', 'Delivered'),
(6, 6, 5, '2025-07-29', 'Pending'),
(7, 7, 2, '2025-07-27', 'Delivered'),
(8, 8, 3, '2025-07-27', 'Delivered'),
(1, 9, 4, '2025-07-28', 'Pending'),
(2, 10, 5, '2025-07-28', 'Delivered'),
(3, 1, 1, '2025-07-30', 'Pending'),
(4, 2, 2, '2025-07-29', 'Delivered'),
(5, 3, 3, '2025-07-30', 'Delivered'),
(6, 4, 4, '2025-07-28', 'Pending'),
(7, 5, 5, '2025-07-27', 'Cancelled');

SELECT 
    o.order_id,
    c.name AS customer,
    m.item_name,
    r.name AS restaurant,
    da.name AS agent,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN menus m ON o.menu_id = m.menu_id
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
JOIN delivery_agents da ON o.agent_id = da.agent_id
WHERE o.status = 'Pending';


SELECT 
    r.name AS restaurant,
    SUM(m.price) AS total_revenue
FROM orders o
JOIN menus m ON o.menu_id = m.menu_id
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.restaurant_id
ORDER BY total_revenue DESC;





