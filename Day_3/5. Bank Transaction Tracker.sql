CREATE DATABASE bank_db;

USE bank_db;

-- 1. Create Tables

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(20), -- 'deposit' or 'withdrawal'
    amount DECIMAL(10,2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 2. Insert Sample Data

-- Customers
INSERT INTO customers (customer_id, name, city) VALUES
(1, 'Alice', 'Delhi'),
(2, 'Bob', 'Mumbai'),
(3, 'Charlie', 'Delhi'),
(4, 'David', 'Chennai'),
(5, 'Eva', 'Kolkata');

-- Accounts
INSERT INTO accounts (account_id, customer_id, account_type) VALUES
(101, 1, 'Savings'),
(102, 2, 'Current'),
(103, 3, 'Savings'),
(104, 4, 'Savings'),
(105, 5, 'Current');

-- Transactions
INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date) VALUES
(1, 101, 'deposit', 5000, '2023-07-01'),
(2, 101, 'withdrawal', 2000, '2023-07-02'),
(3, 102, 'deposit', 10000, '2023-07-01'),
(4, 102, 'withdrawal', 12000, '2023-07-03'),
(5, 103, 'withdrawal', 1500, '2023-07-04'),
(6, 103, 'deposit', 2500, '2023-07-05'),
(7, 101, 'withdrawal', 3000, '2023-07-06'),
(8, 102, 'withdrawal', 5000, '2023-07-07'),
(9, 104, 'deposit', 7000, '2023-07-08');

-- 3. Total deposits and withdrawals per account
SELECT 
    account_id,
    SUM(CASE WHEN transaction_type = 'deposit' THEN amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN transaction_type = 'withdrawal' THEN amount ELSE 0 END) AS total_withdrawals
FROM transactions
GROUP BY account_id;

-- 4. Highest and lowest transaction amounts
SELECT 
    MAX(amount) AS highest_transaction,
    MIN(amount) AS lowest_transaction
FROM transactions;

-- 5. Accounts with total withdrawals > ₹10,000 (HAVING)
SELECT 
    account_id,
    SUM(CASE WHEN transaction_type = 'withdrawal' THEN amount ELSE 0 END) AS total_withdrawals
FROM transactions
GROUP BY account_id
HAVING SUM(CASE WHEN transaction_type = 'withdrawal' THEN amount ELSE 0 END) > 10000;

-- 6. INNER JOIN customers and accounts
SELECT 
    c.customer_id,
    c.name AS customer_name,
    a.account_id,
    a.account_type
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id;

-- 7. LEFT JOIN: Accounts with no transactions
SELECT 
    a.account_id,
    a.account_type,
    t.transaction_id
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;

-- 8. SELF JOIN: Customers from same city
SELECT 
    c1.name AS customer_1,
    c2.name AS customer_2,
    c1.city
FROM customers c1
JOIN customers c2 
  ON c1.city = c2.city 
  AND c1.customer_id < c2.customer_id;
