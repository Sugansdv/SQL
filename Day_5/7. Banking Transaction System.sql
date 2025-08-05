CREATE DATABASE IF NOT EXISTS banking_db;
USE banking_db;

-- Create customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Create accounts table with PRIMARY KEY, NOT NULL balance, and CHECK constraint
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(12, 2) NOT NULL CHECK (balance >= 0),
    status ENUM('active', 'closed') DEFAULT 'active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount DECIMAL(12, 2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample customers
INSERT INTO customers (name, email)
VALUES ('Alice Smith', 'alice@example.com'), ('Bob Brown', 'bob@example.com');

-- Insert sample accounts with NOT NULL balance and PK
INSERT INTO accounts (account_id, customer_id, balance)
VALUES (101, 1, 5000.00), (102, 2, 3000.00);

-- Update balance after transactions (manual example)
UPDATE accounts SET balance = balance - 500 WHERE account_id = 101;
UPDATE accounts SET balance = balance + 500 WHERE account_id = 102;

-- Delete closed accounts
DELETE FROM accounts WHERE status = 'closed';

-- Drop a FOREIGN KEY to restructure relationships
ALTER TABLE accounts DROP FOREIGN KEY accounts_ibfk_1;

-- Transfer money with transaction and rollback if either fails
DELIMITER //

CREATE PROCEDURE transfer_money(
    IN p_from INT,
    IN p_to INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE from_balance DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    SELECT balance INTO from_balance FROM accounts WHERE account_id = p_from FOR UPDATE;

    IF from_balance < p_amount THEN
        ROLLBACK;
        SELECT 'Insufficient funds. Transaction rolled back.' AS message;
    ELSE
        UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from;
        UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to;
        INSERT INTO transactions (from_account, to_account, amount)
        VALUES (p_from, p_to, p_amount);
        COMMIT;
        SELECT 'Transfer successful.' AS message;
    END IF;
END;
//

DELIMITER ;

-- Example transfer
CALL transfer_money(101, 102, 1000);

-- Demonstrate isolation by simulating two concurrent transfers
-- (To be run in two separate MySQL clients or sessions)

-- Session 1
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 101 FOR UPDATE;
-- HOLD THIS SESSION OPEN HERE

-- Session 2 (in another client)
-- Try to transfer from account 101
CALL transfer_money(101, 102, 500);
-- This will wait until session 1 finishes 

-- Session 1 can now commit or rollback
COMMIT;
