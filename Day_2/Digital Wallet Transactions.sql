CREATE DATABASE digital_wallet;

USE digital_wallet;

-- Table: transactions: txn_id, user_id, amount, txn_type, txn_date, status
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10, 2),
    txn_type VARCHAR(50),
    txn_date DATE,
    status VARCHAR(20)
);

INSERT INTO transactions (user_id, amount, txn_type, txn_date, status) VALUES
(101, 150.00, 'mobile recharge', '2025-07-27', 'Success'),
(102, 950.00, 'dth recharge', '2025-07-29', 'Pending'),
(103, 1200.00, 'money transfer', '2025-07-28', 'Success'),
(104, 80.00, 'cashback', '2025-07-25', 'Failed'),
(105, 500.00, 'wallet recharge', '2025-07-30', NULL),
(106, 100.00, 'bill payment', '2025-07-31', 'Success'),
(107, 999.00, 'data recharge', '2025-07-26', 'Success');

-- Filter transactions between ₹100 and ₹1000.
SELECT txn_id, user_id, amount, txn_type, txn_date, status
FROM transactions
WHERE amount BETWEEN 100 AND 1000;

-- Show user_id, amount, and txn_type.
SELECT user_id, amount, txn_type
FROM transactions;

-- Use LIKE to find txn_type containing “recharge”.
SELECT txn_id, user_id, amount, txn_type, txn_date, status
FROM transactions
WHERE txn_type LIKE '%recharge%';

-- Identify NULL statuses.
SELECT txn_id, user_id, amount, txn_type, txn_date
FROM transactions
WHERE status IS NULL;

-- Sort by txn_date DESC.
SELECT txn_id, user_id, amount, txn_type, txn_date, status
FROM transactions
ORDER BY txn_date DESC;
