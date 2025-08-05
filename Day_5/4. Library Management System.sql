CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

-- Create books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100),
    stock INT DEFAULT 0 CHECK (stock >= 0)
);

-- Create members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Create loans table (CURDATE() used correctly in MySQL)
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    loan_date DATE DEFAULT (CURDATE()),
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Create trigger to enforce max 3 active loans per member
DELIMITER //

CREATE TRIGGER check_max_loans
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
    DECLARE active_loans INT;
    SELECT COUNT(*) INTO active_loans
    FROM loans
    WHERE member_id = NEW.member_id AND return_date IS NULL;

    IF active_loans >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member has reached the maximum of 3 active loans.';
    END IF;
END;
//

DELIMITER ;

-- Insert sample book
INSERT INTO books (isbn, title, author, stock)
VALUES ('978-1-56619-909-4', 'Clean Code', 'Robert C. Martin', 2);

-- Insert sample member
INSERT INTO members (name, email)
VALUES ('Alice Smith', 'alice@example.com');

-- Create stored procedure to handle loan with stock check and rollback
DELIMITER //

CREATE PROCEDURE loan_book(IN p_member_id INT, IN p_book_id INT)
BEGIN
    DECLARE current_stock INT;

    START TRANSACTION;

    SELECT stock INTO current_stock FROM books WHERE book_id = p_book_id FOR UPDATE;

    IF current_stock > 0 THEN
        INSERT INTO loans (member_id, book_id) VALUES (p_member_id, p_book_id);
        UPDATE books SET stock = stock - 1 WHERE book_id = p_book_id;
        COMMIT;
        SELECT 'Loan successful.' AS message;
    ELSE
        ROLLBACK;
        SELECT 'Loan failed: Not enough stock.' AS message;
    END IF;
END;
//

DELIMITER ;

-- Call the stored procedure to perform a loan
CALL loan_book(1, 1);

-- Delete loan after return
DELETE FROM loans WHERE loan_id = 1;

-- Temporarily disable trigger
DROP TRIGGER IF EXISTS check_max_loans;

-- Perform updates or batch logic here if needed

-- Recreate the trigger
DELIMITER //

CREATE TRIGGER check_max_loans
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
    DECLARE active_loans INT;
    SELECT COUNT(*) INTO active_loans
    FROM loans
    WHERE member_id = NEW.member_id AND return_date IS NULL;

    IF active_loans >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member has reached the maximum of 3 active loans.';
    END IF;
END;
//

DELIMITER ;
