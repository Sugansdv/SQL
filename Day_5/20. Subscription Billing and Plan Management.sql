-- Create and use the database
DROP DATABASE subscription_system;
CREATE DATABASE IF NOT EXISTS subscription_system;
USE subscription_system;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

-- Plans table
CREATE TABLE plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2),
    duration_days INT
);

-- Subscriptions table
CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    plan_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id),
    CHECK (start_date < end_date)
);

-- Payments table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE NOT NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

-- Insert Users
INSERT INTO users (name, email) VALUES 
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- Insert Plans
INSERT INTO plans (name, price, duration_days) VALUES
('Basic', 9.99, 30),
('Premium', 19.99, 60);

-- Insert Subscriptions
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date) VALUES 
(1, 1, '2025-08-01', '2025-08-31'),
(2, 2, '2025-06-01', '2025-07-01');

-- Start a transaction and create savepoint before renewal
START TRANSACTION;
SAVEPOINT before_renewal;

-- Extend end_date by 30 days for user_id = 1
UPDATE subscriptions 
SET end_date = DATE_ADD(end_date, INTERVAL 30 DAY) 
WHERE user_id = 1;

-- Commit transaction to ensure durability
COMMIT;

-- Delete Expired Plans (plans with no active subscriptions)
SET SQL_SAFE_UPDATES = 0;

-- Then run your DELETE
DELETE p
FROM plans p
LEFT JOIN subscriptions s 
    ON p.plan_id = s.plan_id AND s.end_date >= CURDATE()
WHERE s.plan_id IS NULL;

-- (Optional) Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;


-- Insert Payment with explicit date
INSERT INTO payments (subscription_id, amount, payment_date)
VALUES (1, 9.99, CURDATE());
