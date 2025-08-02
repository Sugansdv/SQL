CREATE DATABASE IF NOT EXISTS SaaSDB;
USE SaaSDB;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    status VARCHAR(20), 
    join_date DATE
);

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(100),
    monthly_price DECIMAL(10, 2)
);

CREATE TABLE subscriptions (
    sub_id INT PRIMARY KEY,
    user_id INT,
    plan_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users VALUES
(1, 'Alice', 'Active', '2024-01-01'),
(2, 'Bob', 'Inactive', '2024-02-01'),
(3, 'Charlie', 'Trial', '2024-05-01'),
(4, 'Diana', 'Active', '2024-03-15');

INSERT INTO plans VALUES
(1, 'Free', 0.00),
(2, 'Basic', 19.99),
(3, 'Pro', 49.99);

INSERT INTO subscriptions VALUES
(1, 1, 2, '2024-01-01', '2025-01-01'),
(2, 2, 1, '2024-02-01', '2024-08-01'),
(3, 3, 1, '2024-05-01', '2024-11-01'),
(4, 4, 3, '2024-03-15', '2025-03-15');

INSERT INTO payments VALUES
(1, 1, 239.88, '2024-01-01'),
(2, 4, 599.88, '2024-03-15');

-- Subquery in FROM to calculate plan-wise average revenue. 
SELECT 
    p.plan_name,
    AVG(paid.total_amount) AS avg_revenue
FROM plans p
LEFT JOIN (
    SELECT s.plan_id, SUM(p.amount) AS total_amount
    FROM subscriptions s
    JOIN payments p ON s.user_id = p.user_id
    GROUP BY s.plan_id
) AS paid ON p.plan_id = paid.plan_id
GROUP BY p.plan_id;

-- Use CASE to show user activity: Active, Inactive, Trial. 
SELECT 
    name,
    status,
    CASE 
        WHEN status = 'Active' THEN 'Billing'
        WHEN status = 'Trial' THEN 'Trial Period'
        ELSE 'No Active Subscription'
    END AS user_activity
FROM users;

-- UNION to merge paid and free-tier users. 
-- Paid users
SELECT u.name, p.plan_name, 'Paid' AS tier
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE p.monthly_price > 0

UNION

-- Free-tier users
SELECT u.name, p.plan_name, 'Free' AS tier
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE p.monthly_price = 0;

-- JOIN + GROUP BY for monthly revenue trends. 
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(amount) AS monthly_revenue
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m');

-- Correlated subquery to find longest-subscribed users. 
SELECT 
    u.user_id,
    u.name,
    DATEDIFF(s.end_date, s.start_date) AS subscription_days
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
WHERE DATEDIFF(s.end_date, s.start_date) = (
    SELECT MAX(DATEDIFF(s2.end_date, s2.start_date))
    FROM subscriptions s2
    WHERE s2.user_id = u.user_id
);

-- Date filtering for renewal reminders.
SELECT 
    u.name,
    s.end_date AS renewal_date
FROM subscriptions s
JOIN users u ON u.user_id = s.user_id
WHERE MONTH(s.end_date) = MONTH(CURDATE()) 
  AND YEAR(s.end_date) = YEAR(CURDATE());
