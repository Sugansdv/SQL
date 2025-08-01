CREATE DATABASE online_bookstore;
USE online_bookstore;

CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200),
    author_id INT,
    genre VARCHAR(50),
    rating DECIMAL(2,1),
    price DECIMAL(6,2),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    book_id INT,
    customer_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Authors
INSERT INTO authors VALUES
(1, 'J.K. Rowling'),
(2, 'George R.R. Martin'),
(3, 'J.R.R. Tolkien'),
(4, 'Agatha Christie');

-- Books
INSERT INTO books VALUES
(1, 'Harry Potter', 1, 'Fantasy', 4.8, 499.00),
(2, 'Game of Thrones', 2, 'Fantasy', 4.7, 599.00),
(3, 'The Hobbit', 3, 'Fantasy', 4.6, 399.00),
(4, 'Murder on the Orient Express', 4, 'Mystery', 4.2, 299.00),
(5, 'The Silmarillion', 3, 'Fantasy', 4.1, 350.00),
(6, 'Casual Vacancy', 1, 'Drama', 3.9, 299.00);

-- Customers
INSERT INTO customers VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Carol', 'carol@example.com'),
(4, 'David', 'david@example.com'),
(5, 'Eve', 'eve@example.com');

-- Sales
INSERT INTO sales VALUES
(1, 1, 1, 50, '2025-01-01'),
(2, 1, 2, 60, '2025-01-02'),
(3, 2, 2, 70, '2025-01-03'),
(4, 3, 3, 120, '2025-01-04'),
(5, 4, 4, 40, '2025-01-05'),
(6, 5, 5, 10, '2025-01-06'),
(7, 3, 1, 30, '2025-01-07'),
(8, 1, 3, 10, '2025-01-08'),
(9, 2, 4, 40, '2025-01-09'),
(10, 1, 5, 30, '2025-01-10');

-- 1. Top-selling authors (GROUP BY, SUM)
SELECT a.name AS author_name, SUM(s.quantity) AS total_sales
FROM authors a
JOIN books b ON a.author_id = b.author_id
JOIN sales s ON b.book_id = s.book_id
GROUP BY a.name
ORDER BY total_sales DESC;

-- 2. Books with rating > 4.5 and sold more than 100 times
SELECT b.title, b.rating, SUM(s.quantity) AS total_sold
FROM books b
JOIN sales s ON b.book_id = s.book_id
GROUP BY b.book_id, b.title, b.rating
HAVING b.rating > 4.5 AND SUM(s.quantity) > 100;

-- 3. Customers with > 5 purchases (HAVING)
SELECT c.name, COUNT(s.sale_id) AS total_purchases
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.name
HAVING COUNT(s.sale_id) > 5;

-- 4. INNER JOIN books ↔ sales ↔ customers
SELECT b.title, s.quantity, c.name AS customer_name, s.sale_date
FROM books b
JOIN sales s ON b.book_id = s.book_id
JOIN customers c ON s.customer_id = c.customer_id;

-- 5. FULL OUTER JOIN authors ↔ books (MySQL doesn't support FULL OUTER JOIN directly)
SELECT a.name AS author_name, b.title
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
UNION
SELECT a.name AS author_name, b.title
FROM authors a
RIGHT JOIN books b ON a.author_id = b.author_id;

-- 6. SELF JOIN on books with same genre
SELECT b1.title AS book1, b2.title AS book2, b1.genre
FROM books b1
JOIN books b2 ON b1.genre = b2.genre AND b1.book_id < b2.book_id;
