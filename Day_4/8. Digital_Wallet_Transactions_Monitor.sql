CREATE DATABASE digital_wallet;
USE digital_wallet;

-- Create Tables
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    user_id INT,
    wallet_type VARCHAR(20), -- e.g., PayX, FastPay
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    account_id INT,
    txn_type VARCHAR(10), -- Credit, Debit, Refund
    amount DECIMAL(10,2),
    txn_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Insert Data
INSERT INTO users VALUES
(1, 'Alice', 'Delhi'),
(2, 'Bob', 'Mumbai'),
(3, 'Charlie', 'Bangalore'),
(4, 'Diana', 'Chennai');

INSERT INTO accounts VALUES
(101, 1, 'PayX'),
(102, 2, 'PayX'),
(103, 3, 'FastPay'),
(104, 4, 'FastPay'),
(105, 1, 'FastPay');

INSERT INTO transactions VALUES
(201, 101, 'Credit', 1000.00, '2025-08-01'),
(202, 101, 'Debit', 200.00, '2025-08-02'),
(203, 102, 'Credit', 1500.00, '2025-07-28'),
(204, 103, 'Refund', 300.00, '2025-08-01'),
(205, 104, 'Credit', 1200.00, '2025-08-02'),
(206, 105, 'Debit', 500.00, '2025-08-01');

-- Subquery to calculate average transaction value per user
SELECT 
    u.user_id,
    u.name,
    (SELECT AVG(t.amount)
     FROM transactions t
     JOIN accounts a ON t.account_id = a.account_id
     WHERE a.user_id = u.user_id) AS avg_txn_value
FROM users u;

-- JOIN + GROUP BY to show transaction totals by city
SELECT 
    u.city,
    SUM(t.amount) AS total_txn_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN users u ON a.user_id = u.user_id
GROUP BY u.city;

-- CASE for transaction types: "Credit", "Debit", "Refund"
SELECT 
    txn_id,
    amount,
    txn_type,
    CASE 
        WHEN txn_type = 'Credit' THEN 'Incoming'
        WHEN txn_type = 'Debit' THEN 'Outgoing'
        WHEN txn_type = 'Refund' THEN 'Adjustment'
        ELSE 'Other'
    END AS txn_category
FROM transactions;

-- UNION to merge two different wallet systems (PayX + FastPay)
SELECT u.user_id, u.name, a.wallet_type
FROM users u
JOIN accounts a ON u.user_id = a.user_id
WHERE a.wallet_type = 'PayX'
UNION
SELECT u.user_id, u.name, a.wallet_type
FROM users u
JOIN accounts a ON u.user_id = a.user_id
WHERE a.wallet_type = 'FastPay';

-- INTERSECT to find users active on both platforms
SELECT user_id
FROM accounts
WHERE wallet_type = 'PayX'
  AND user_id IN (
    SELECT user_id FROM accounts WHERE wallet_type = 'FastPay'
  );

-- Date filtering for transactions made this week or month
-- This Week
SELECT * 
FROM transactions
WHERE txn_date >= CURDATE() - INTERVAL 7 DAY;

-- This Month
SELECT * 
FROM transactions
WHERE MONTH(txn_date) = MONTH(CURDATE()) 
  AND YEAR(txn_date) = YEAR(CURDATE());
