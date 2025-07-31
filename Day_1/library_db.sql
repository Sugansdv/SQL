CREATE DATABASE library_db;
USE library_db;

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100),
    isbn VARCHAR(20) UNIQUE,
    total_copies INT DEFAULT 1
);

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE
);

CREATE TABLE borrowings (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO books (title, author, isbn, total_copies) VALUES
('1984', 'George Orwell', '9780451524935', 5),
('To Kill a Mockingbird', 'Harper Lee', '9780060935467', 3),
('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 4),
('Moby Dick', 'Herman Melville', '9781503280786', 2),
('War and Peace', 'Leo Tolstoy', '9780199232765', 2),
('Pride and Prejudice', 'Jane Austen', '9781503290563', 3),
('The Hobbit', 'J.R.R. Tolkien', '9780345339683', 5),
('Crime and Punishment', 'Fyodor Dostoevsky', '9780140449136', 4),
('Brave New World', 'Aldous Huxley', '9780060850524', 3),
('The Catcher in the Rye', 'J.D. Salinger', '9780316769488', 2);

INSERT INTO members (name, email, join_date) VALUES
('Alice Johnson', 'alice@example.com', '2024-01-15'),
('Bob Smith', 'bob@example.com', '2024-02-10'),
('Charlie Brown', 'charlie@example.com', '2024-03-20'),
('Daisy Adams', 'daisy@example.com', '2024-04-12'),
('Ethan Clark', 'ethan@example.com', '2024-05-18'),
('Fiona Davis', 'fiona@example.com', '2024-06-05'),
('George Evans', 'george@example.com', '2024-07-08'),
('Hannah Ford', 'hannah@example.com', '2024-01-27'),
('Ian Green', 'ian@example.com', '2024-02-14'),
('Julia Hall', 'julia@example.com', '2024-03-30');

INSERT INTO borrowings (member_id, book_id, borrow_date, due_date, return_date) VALUES
(1, 1, '2025-07-01', '2025-07-15', NULL),
(2, 2, '2025-07-10', '2025-07-25', '2025-07-20'),
(3, 3, '2025-07-05', '2025-07-20', NULL),
(4, 1, '2025-07-15', '2025-07-30', NULL),
(5, 5, '2025-07-02', '2025-07-16', '2025-07-15');

SELECT b.title, br.borrow_date, br.due_date
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
WHERE br.member_id = 1;

SELECT m.name AS member_name, b.title AS book_title, br.due_date
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
JOIN members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL AND br.due_date < CURDATE();

SELECT b.title, COUNT(br.book_id) AS borrow_count
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
GROUP BY br.book_id
ORDER BY borrow_count DESC
LIMIT 5;

