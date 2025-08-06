
CREATE DATABASE banking_system;

USE banking_system;

CREATE TABLE branches (
  branch_id INT PRIMARY KEY AUTO_INCREMENT,
  branch_name VARCHAR(100),
  location VARCHAR(100)
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(15)
);

CREATE TABLE accounts (
  account_no INT PRIMARY KEY,
  customer_id INT,
  branch_id INT,
  account_type VARCHAR(50),
  balance DECIMAL(15,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
  transaction_id INT PRIMARY KEY AUTO_INCREMENT,
  account_no INT,
  transaction_date DATE,
  amount DECIMAL(12,2),
  type ENUM('credit', 'debit'),
  description TEXT,
  FOREIGN KEY (account_no) REFERENCES accounts(account_no)
);

INSERT INTO branches (branch_name, location)
VALUES 
  ('Main Branch', 'Chennai'),
  ('West Branch', 'Mumbai');

INSERT INTO customers (full_name, email, phone)
VALUES
  ('Amit Sharma', 'amit@example.com', '9876543210'),
  ('Sneha Roy', 'sneha@example.com', '9123456780');

INSERT INTO accounts (account_no, customer_id, branch_id, account_type, balance)
VALUES
  (1001, 1, 1, 'Savings', 25000.00),
  (1002, 2, 2, 'Current', 150000.00);

INSERT INTO transactions (account_no, transaction_date, amount, type, description)
VALUES
  (1001, '2025-08-01', 5000.00, 'debit', 'ATM Withdrawal'),
  (1001, '2025-08-03', 10000.00, 'credit', 'Salary Credit'),
  (1002, '2025-08-04', 25000.00, 'debit', 'Bill Payment'),
  (1001, '2025-08-06', 3000.00, 'debit', 'Online Transfer'),
  (1002, '2025-08-06', 100000.00, 'credit', 'Business Deposit');

-- Add indexes on commonly queried columns
CREATE INDEX idx_account_no ON accounts(account_no);
CREATE INDEX idx_transaction_date ON transactions(transaction_date);
CREATE INDEX idx_branch_id ON accounts(branch_id);

-- Use EXPLAIN to analyze slow queries (e.g., account balance checks)
EXPLAIN
SELECT balance
FROM accounts
WHERE account_no = 1001;

-- Use subquery to calculate running balance for an account
SELECT 
  t1.transaction_id,
  t1.transaction_date,
  t1.amount,
  t1.type,
  t1.description,
  (
    SELECT SUM(
      CASE 
        WHEN t2.type = 'credit' THEN t2.amount 
        ELSE -t2.amount 
      END
    )
    FROM transactions t2
    WHERE t2.account_no = t1.account_no
      AND t2.transaction_date <= t1.transaction_date
  ) AS running_balance
FROM transactions t1
WHERE t1.account_no = 1001
ORDER BY t1.transaction_date;

-- Create a denormalized view for account statements
CREATE VIEW account_statement AS
SELECT 
  c.full_name,
  a.account_no,
  b.branch_name,
  t.transaction_date,
  t.amount,
  t.type,
  t.description
FROM transactions t
JOIN accounts a ON t.account_no = a.account_no
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches b ON a.branch_id = b.branch_id;

-- Display latest 10 transactions (LIMIT usage)
SELECT *
FROM transactions
ORDER BY transaction_date DESC
LIMIT 10;
