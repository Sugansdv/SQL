CREATE DATABASE bank_db;

USE bank_db;

CREATE TABLE branches (
  branch_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  location VARCHAR(100)
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(15)
);

CREATE TABLE accounts (
  account_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT,
  branch_id INT,
  account_type VARCHAR(50),
  created_on DATE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
  transaction_id INT PRIMARY KEY AUTO_INCREMENT,
  account_id INT,
  transaction_type ENUM('credit', 'debit'),
  amount DECIMAL(10, 2),
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

INSERT INTO branches (name, location) VALUES
('Main Branch', 'Mumbai'),
('City Branch', 'Delhi'),
('West Branch', 'Pune');

INSERT INTO customers (name, email, phone) VALUES
('Ravi Sharma', 'ravi@example.com', '9876543210'),
('Anjali Mehta', 'anjali@example.com', '9123456789'),
('Vikram Rao', 'vikram@example.com', '9988776655');


INSERT INTO accounts (customer_id, branch_id, account_type, created_on) VALUES
(1, 1, 'Savings', '2024-01-01'),
(2, 2, 'Current', '2024-02-15'),
(3, 3, 'Savings', '2024-03-10');

INSERT INTO transactions (account_id, transaction_type, amount, timestamp) VALUES
(1, 'credit', 10000, '2025-07-01 10:00:00'),
(1, 'debit', 2500, '2025-07-02 14:30:00'),
(1, 'credit', 1500, '2025-07-03 09:15:00'),
(2, 'credit', 20000, '2025-07-01 11:00:00'),
(2, 'debit', 5000, '2025-07-04 16:45:00'),
(3, 'credit', 12000, '2025-07-02 12:00:00');

SELECT 
  t.transaction_id,
  t.transaction_type,
  t.amount,
  t.timestamp
FROM transactions t
WHERE t.account_id = 1
ORDER BY t.timestamp DESC;

SELECT 
  a.account_id,
  c.name AS customer_name,
  SUM(CASE WHEN t.transaction_type = 'credit' THEN t.amount ELSE 0 END) -
  SUM(CASE WHEN t.transaction_type = 'debit' THEN t.amount ELSE 0 END) AS balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, c.name;
