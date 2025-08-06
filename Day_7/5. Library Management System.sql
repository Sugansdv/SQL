CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    total_copies INT,
    available_copies INT,
    supplier VARCHAR(100),
    purchase_price DECIMAL(8,2)
);

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE issued_books (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    issue_date DATE,
    due_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO books (title, author, total_copies, available_copies, supplier, purchase_price) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 5, 5, 'BookWorld', 200.00),
('1984', 'George Orwell', 3, 3, 'ReadersPoint', 150.00),
('To Kill a Mockingbird', 'Harper Lee', 4, 4, 'EduBooks', 180.00);

INSERT INTO members (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- View for members (no supplier or price)
CREATE VIEW view_book_availability AS
SELECT book_id, title, author, total_copies, available_copies
FROM books;

-- Function to get due date
DELIMITER //
CREATE FUNCTION get_due_date(issue_date DATE)
RETURNS DATE
DETERMINISTIC
BEGIN
    RETURN DATE_ADD(issue_date, INTERVAL 14 DAY);
END;
//
DELIMITER ;

-- Procedure to issue book
DELIMITER //
CREATE PROCEDURE issue_book(IN p_member_id INT, IN p_book_id INT)
BEGIN
    DECLARE v_available INT;
    DECLARE v_due DATE;

    SELECT available_copies INTO v_available FROM books WHERE book_id = p_book_id;

    IF v_available > 0 THEN
        SET v_due = get_due_date(CURDATE());
        
        INSERT INTO issued_books (member_id, book_id, issue_date, due_date)
        VALUES (p_member_id, p_book_id, CURDATE(), v_due);

        UPDATE books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not available';
    END IF;
END;
//
DELIMITER ;

-- Trigger to update availability after issue
DELIMITER //
CREATE TRIGGER after_issue
AFTER INSERT ON issued_books
FOR EACH ROW
BEGIN
    UPDATE books SET available_copies = available_copies - 0 WHERE book_id = NEW.book_id;
END;
//
DELIMITER ;
