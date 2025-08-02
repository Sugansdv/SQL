CREATE DATABASE BankDB;
USE BankDB;

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Accounts Table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),  -- e.g., 'Savings', 'Current'
    balance DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    txn_date DATE,
    amount DECIMAL(10, 2),  -- Positive = Deposit, Negative = Withdrawal
    description VARCHAR(200),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Customers
INSERT INTO customers VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com');

-- Accounts
INSERT INTO accounts VALUES
(101, 1, 'Savings', 15000.00),
(102, 1, 'Current', 5000.00),
(103, 2, 'Savings', 2000.00),
(104, 3, 'Current', 0.00);  

-- Transactions
INSERT INTO transactions VALUES
(1, 101, '2025-08-01', 5000.00, 'Initial Deposit'),
(2, 101, '2025-08-02', -1000.00, 'ATM Withdrawal'),
(3, 102, '2025-08-01', 5000.00, 'Initial Deposit'),
(4, 103, '2025-08-03', 2000.00, 'Initial Deposit');

-- Use IS NULL to find accounts with no transactions.
SELECT a.account_id, a.account_type
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;

-- Use INNER JOIN to combine account and customer info.
SELECT 
    c.customer_id,
    c.name,
    a.account_id,
    a.account_type,
    a.balance
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id;

-- Use SUM() to get total deposits per customer.
SELECT 
    c.customer_id,
    c.name,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) AS total_deposits
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.name;

-- Use CASE for risk-level classification based on balance.
SELECT 
    c.name,
    SUM(a.balance) AS total_balance,
    CASE
        WHEN SUM(a.balance) >= 10000 THEN 'Low Risk'
        WHEN SUM(a.balance) >= 5000 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_level
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.name;

-- Use subquery in FROM to compute daily balance change.
SELECT 
    t.account_id,
    t.txn_date,
    SUM(t.amount) AS daily_change
FROM (
    SELECT account_id, txn_date, amount
    FROM transactions
) t
GROUP BY t.account_id, t.txn_date;

-- Use UNION ALL to combine savings and current account statements.
SELECT 
    a.account_id,
    c.name,
    a.account_type,
    t.txn_date,
    t.amount,
    t.description
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.account_type = 'Savings'

UNION ALL

SELECT 
    a.account_id,
    c.name,
    a.account_type,
    t.txn_date,
    t.amount,
    t.description
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.account_type = 'Current'
ORDER BY txn_date;

