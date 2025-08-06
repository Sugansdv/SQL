CREATE DATABASE BankingSystem;

USE BankingSystem;

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    account_holder VARCHAR(100),
    balance DECIMAL(10,2),
    is_fraudulent BOOLEAN DEFAULT FALSE
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account INT,
    to_account INT,
    amount DECIMAL(10,2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account) REFERENCES Accounts(account_id),
    FOREIGN KEY (to_account) REFERENCES Accounts(account_id)
);

INSERT INTO Accounts (account_holder, balance, is_fraudulent) VALUES 
('Alice Johnson', 5000.00, FALSE),
('Bob Smith', 3000.00, FALSE),
('Charlie Green', 10000.00, TRUE);

-- Create secure view for tellers (hide fraud flag and sensitive details)
CREATE VIEW view_account_summary AS
SELECT 
    account_id,
    account_holder,
    balance
FROM 
    Accounts
WHERE 
    is_fraudulent = FALSE;

-- Create procedure to transfer funds with balance checks
DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN from_ac INT, 
    IN to_ac INT, 
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);

    -- Check balance
    SELECT balance INTO from_balance FROM Accounts WHERE account_id = from_ac;

    IF from_balance < amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance for transfer.';
    ELSE
        -- Deduct from sender
        UPDATE Accounts SET balance = balance - amount WHERE account_id = from_ac;

        -- Add to receiver
        UPDATE Accounts SET balance = balance + amount WHERE account_id = to_ac;

        -- Log transaction
        INSERT INTO Transactions (from_account, to_account, amount) 
        VALUES (from_ac, to_ac, amount);
    END IF;
END //
DELIMITER ;

-- Create function to count transactions for reports
DELIMITER //
CREATE FUNCTION get_transaction_count(ac_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE txn_count INT;
    SELECT COUNT(*) INTO txn_count FROM Transactions 
    WHERE from_account = ac_id OR to_account = ac_id;
    RETURN txn_count;
END //
DELIMITER ;

-- Create trigger before transfer to prevent overdraft
DELIMITER //
CREATE TRIGGER before_transfer
BEFORE UPDATE ON Accounts
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overdraft not allowed.';
    END IF;
END //
DELIMITER ;


-- View account summaries (teller access)
SELECT * FROM view_account_summary;

-- Try a valid fund transfer
CALL transfer_funds(1, 2, 500.00);

-- Check transactions
SELECT * FROM Transactions;

-- Get transaction count for account 1
SELECT get_transaction_count(1) AS Total_Transactions;

-- Try overdraft (will fail)
CALL transfer_funds(2, 1, 10000.00);
