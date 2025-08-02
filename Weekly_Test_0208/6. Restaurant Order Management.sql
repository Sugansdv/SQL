CREATE DATABASE RestaurantDB;

USE RestaurantDB;

-- Table: customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    first_order_date DATE
);

-- Table: staff
CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50) -- e.g., Waiter, Chef
);

-- Table: menu_items
CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(6,2)
);

-- Table: orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    staff_id INT,
    item_id INT,
    order_type VARCHAR(20), -- 'Dine-In' or 'Delivery'
    quantity INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

INSERT INTO customers VALUES
(1, 'Alice', '2025-01-01'),
(2, 'Bob', '2025-06-01'),
(3, 'Charlie', '2025-08-01');

INSERT INTO staff VALUES
(1, 'John', 'Waiter'),
(2, 'Sara', 'Waiter');

INSERT INTO menu_items VALUES
(1, 'Margherita Pizza', 8.99),
(2, 'Pepperoni Pizza', 9.99),
(3, 'Pasta Alfredo', 7.99),
(4, 'Garlic Bread', 4.50);

INSERT INTO orders VALUES
(1, 1, 1, 1, 'Dine-In', 2, '2025-07-01'),
(2, 1, 1, 2, 'Dine-In', 1, '2025-07-01'),
(3, 2, 2, 3, 'Delivery', 1, '2025-07-02'),
(4, 2, 2, 4, 'Delivery', 2, '2025-07-02'),
(5, 3, 1, 2, 'Dine-In', 3, '2025-08-01'),
(6, 3, 1, 1, 'Dine-In', 1, '2025-08-01');

-- INNER JOIN to list full orders with customer and waiter info
SELECT 
    o.order_id,
    c.name AS Customer,
    s.name AS Waiter,
    m.name AS Item,
    o.quantity,
    o.order_type,
    o.order_date
FROM 
    orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN staff s ON o.staff_id = s.staff_id
INNER JOIN menu_items m ON o.item_id = m.item_id;

-- LIKE '%Pizza%' to find pizza items
SELECT * 
FROM menu_items
WHERE name LIKE '%Pizza%';

-- GROUP BY to get total orders per staff
SELECT 
    s.name AS Staff,
    COUNT(o.order_id) AS TotalOrders
FROM 
    orders o
JOIN 
    staff s ON o.staff_id = s.staff_id
GROUP BY 
    s.name;

-- ORDER BY on amount (price * quantity) and customer name
SELECT 
    c.name AS Customer,
    m.name AS Item,
    o.quantity,
    (m.price * o.quantity) AS Amount
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    menu_items m ON o.item_id = m.item_id
ORDER BY 
    Amount DESC, c.name ASC;

-- CASE WHEN to categorize customers (New/Returning)
SELECT 
    name,
    first_order_date,
    CASE 
        WHEN first_order_date >= '2025-07-01' THEN 'New'
        ELSE 'Returning'
    END AS CustomerType
FROM 
    customers;

-- Subquery to find customers who ordered more than 5 times
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS TotalOrders
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.name
HAVING 
    COUNT(o.order_id) > 5;

-- Combine dine-in and delivery data using UNION
SELECT 
    customer_id,
    'Dine-In' AS OrderType,
    order_id,
    order_date
FROM 
    orders
WHERE 
    order_type = 'Dine-In'
UNION
SELECT 
    customer_id,
    'Delivery' AS OrderType,
    order_id,
    order_date
FROM 
    orders
WHERE 
    order_type = 'Delivery';
