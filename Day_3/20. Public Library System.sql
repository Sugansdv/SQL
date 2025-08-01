CREATE DATABASE public_library_db;
USE public_library_db;

-- Table: members
CREATE TABLE members (
  member_id INT PRIMARY KEY,
  name VARCHAR(100)
);

-- Table: books
CREATE TABLE books (
  book_id INT PRIMARY KEY,
  title VARCHAR(100),
  author VARCHAR(100)
);

-- Table: checkouts
CREATE TABLE checkouts (
  checkout_id INT PRIMARY KEY,
  member_id INT,
  book_id INT,
  checkout_date DATE,
  return_date DATE,
  FOREIGN KEY (member_id) REFERENCES members(member_id),
  FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Table: fines
CREATE TABLE fines (
  fine_id INT PRIMARY KEY,
  member_id INT,
  amount DECIMAL(10,2),
  paid BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- Members
INSERT INTO members VALUES
(1, 'Alice'), (2, 'Bob'), (3, 'Charlie'), (4, 'Diana');

-- Books
INSERT INTO books VALUES
(101, '1984', 'George Orwell'),
(102, 'To Kill a Mockingbird', 'Harper Lee'),
(103, 'The Hobbit', 'J.R.R. Tolkien');

-- Checkouts
INSERT INTO checkouts VALUES
(1, 1, 101, '2025-07-01', '2025-07-15'),
(2, 2, 101, '2025-07-16', '2025-07-25'),
(3, 3, 102, '2025-07-10', '2025-07-20'),
(4, 1, 103, '2025-07-21', '2025-07-30'),
(5, 2, 103, '2025-07-25', NULL),
(6, 4, 103, '2025-07-28', NULL);

-- Fines
INSERT INTO fines VALUES
(1, 1, 100.00, TRUE),
(2, 2, 700.00, FALSE),
(3, 3, 200.00, FALSE),
(4, 4, 800.00, TRUE);

-- Count books issued per member
SELECT m.name AS member_name, COUNT(c.book_id) AS books_issued
FROM members m
JOIN checkouts c ON m.member_id = c.member_id
GROUP BY m.name;

-- Members with fines over ₹500
SELECT m.name AS member_name, SUM(f.amount) AS total_fine
FROM members m
JOIN fines f ON m.member_id = f.member_id
GROUP BY m.name
HAVING SUM(f.amount) > 500;

-- Books with > 5 checkouts
SELECT b.title, COUNT(c.checkout_id) AS checkout_count
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.title
HAVING COUNT(c.checkout_id) > 5;

-- INNER JOIN: checkouts ↔ members ↔ books
SELECT c.checkout_id, m.name AS member_name, b.title, c.checkout_date
FROM checkouts c
JOIN members m ON c.member_id = m.member_id
JOIN books b ON c.book_id = b.book_id;

-- LEFT JOIN: books ↔ checkouts (to show all books, even those never checked out)
SELECT b.title, c.checkout_id
FROM books b
LEFT JOIN checkouts c ON b.book_id = c.book_id;

-- SELF JOIN: members who borrowed the same books
SELECT DISTINCT m1.name AS member1, m2.name AS member2, b.title
FROM checkouts c1
JOIN checkouts c2 ON c1.book_id = c2.book_id AND c1.member_id < c2.member_id
JOIN members m1 ON c1.member_id = m1.member_id
JOIN members m2 ON c2.member_id = m2.member_id
JOIN books b ON c1.book_id = b.book_id;
