CREATE DATABASE IF NOT EXISTS library_system;
USE library_system;

CREATE TABLE books (
  book_id INT PRIMARY KEY,
  title VARCHAR(100),
  genre VARCHAR(50)
);

CREATE TABLE members (
  member_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE loans (
  loan_id INT PRIMARY KEY,
  book_id INT,
  member_id INT,
  loan_date DATE,
  FOREIGN KEY (book_id) REFERENCES books(book_id),
  FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE returns (
  return_id INT PRIMARY KEY,
  loan_id INT,
  return_date DATE,
  FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

INSERT INTO books VALUES
(1, 'The Great Gatsby', 'Fiction'),
(2, 'A Brief History of Time', 'Non-Fiction'),
(3, '1984', 'Fiction'),
(4, 'Sapiens', 'Non-Fiction'),
(5, 'To Kill a Mockingbird', 'Fiction');

INSERT INTO members VALUES
(101, 'Alice'),
(102, 'Bob'),
(103, 'Charlie'),
(104, 'Diana');

INSERT INTO loans VALUES
(1001, 1, 101, '2025-07-01'),
(1002, 2, 101, '2025-07-05'),
(1003, 3, 102, '2025-07-10'),
(1004, 1, 103, '2025-06-15'),
(1005, 4, 104, '2025-07-25'),
(1006, 5, 101, '2025-06-20');

INSERT INTO returns VALUES
(2001, 1001, '2025-07-10'),
(2002, 1002, '2025-07-15'),
(2003, 1003, '2025-07-20'),
(2004, 1004, '2025-06-30');

-- Subquery to find books borrowed more than average. 
SELECT b.book_id, b.title, COUNT(l.loan_id) AS borrow_count
FROM books b
JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title
HAVING COUNT(*) > (
    SELECT AVG(book_loans) FROM (
        SELECT COUNT(*) AS book_loans
        FROM loans
        GROUP BY book_id
    ) AS avg_loans
);

-- CASE to classify members based on total borrowings. 
SELECT m.member_id, m.name,
  COUNT(l.loan_id) AS total_borrowings,
  CASE
    WHEN COUNT(l.loan_id) >= 3 THEN 'Frequent Reader'
    WHEN COUNT(l.loan_id) = 2 THEN 'Moderate Reader'
    ELSE 'Occasional Reader'
  END AS member_category
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.name;

-- Use JOIN + GROUP BY to show most borrowed genres.
SELECT b.genre, COUNT(*) AS times_borrowed
FROM loans l
JOIN books b ON l.book_id = b.book_id
GROUP BY b.genre
ORDER BY times_borrowed DESC;

-- UNION to show active and inactive borrowers. 
-- Active = at least one unreturned loan
SELECT DISTINCT m.member_id, m.name, 'Active' AS status
FROM members m
JOIN loans l ON m.member_id = l.member_id
LEFT JOIN returns r ON l.loan_id = r.loan_id
WHERE r.return_id IS NULL
UNION
-- Inactive = all books returned or no loans
SELECT DISTINCT m.member_id, m.name, 'Inactive' AS status
FROM members m
WHERE m.member_id NOT IN (
    SELECT member_id FROM loans l
    WHERE l.loan_id NOT IN (SELECT loan_id FROM returns)
);

-- INTERSECT for members who borrowed both Fiction and Non-Fiction. 
SELECT DISTINCT l.member_id
FROM loans l
JOIN books b ON l.book_id = b.book_id
WHERE b.genre = 'Fiction'
  AND l.member_id IN (
    SELECT DISTINCT l2.member_id
    FROM loans l2
    JOIN books b2 ON l2.book_id = b2.book_id
    WHERE b2.genre = 'Non-Fiction'
  );

-- Date-based filtering for loans in the past 90 days.  
SELECT l.loan_id, m.name, b.title, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.loan_date >= CURDATE() - INTERVAL 90 DAY;
