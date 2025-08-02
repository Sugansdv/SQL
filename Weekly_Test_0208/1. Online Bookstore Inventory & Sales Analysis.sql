CREATE DATABASE BookstoreDB;

USE BookstoreDB;

-- Authors table
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

-- Books table
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150),
    genre VARCHAR(50),
    price DECIMAL(10, 2),
    format VARCHAR(20), -- 'Physical' or 'eBook'
    author_id INT,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    book_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);


INSERT INTO authors (name) VALUES
('J.K. Rowling'),
('George R.R. Martin'),
('Agatha Christie');

INSERT INTO books (title, genre, price, format, author_id) VALUES
('Harry Potter 1', 'Fantasy', 499.00, 'Physical', 1),
('Harry Potter 2', 'Fantasy', 599.00, 'eBook', 1),
('Game of Thrones', 'Fantasy', 699.00, 'Physical', 2),
('Clash of Kings', 'Fantasy', 799.00, 'eBook', 2),
('Murder on the Orient Express', 'Mystery', 399.00, 'Physical', 3),
('Death on the Nile', 'Mystery', 450.00, 'eBook', 3),
('Unused Book', 'Sci-Fi', 350.00, 'Physical', 3);

INSERT INTO customers (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');

INSERT INTO orders (customer_id, book_id, quantity, order_date) VALUES
(1, 1, 2, '2025-07-01'),
(2, 2, 1, '2025-07-03'),
(1, 3, 3, '2025-08-01'),
(3, 5, 1, '2025-08-05'),
(2, 4, 2, '2025-08-10');

-- SELECT books filtered by genre
SELECT * FROM books
WHERE genre = 'Fantasy';

-- JOIN books with authors and sales (orders)
SELECT 
    b.title,
    a.name AS author_name,
    o.quantity,
    o.order_date
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN orders o ON b.book_id = o.book_id;

-- Total and average sales per author
SELECT 
    a.name AS author_name,
    SUM(o.quantity * b.price) AS total_sales,
    AVG(o.quantity * b.price) AS avg_sales
FROM authors a
JOIN books b ON a.author_id = b.author_id
JOIN orders o ON b.book_id = o.book_id
GROUP BY a.name;

-- Filter duplicate books using DISTINCT
SELECT DISTINCT title FROM books;

-- Filter orders by date range using BETWEEN
SELECT * FROM orders
WHERE order_date BETWEEN '2025-08-01' AND '2025-08-31';

-- Subquery in WHERE: Books never sold
SELECT * FROM books
WHERE book_id NOT IN (
    SELECT DISTINCT book_id FROM orders
);

-- CASE WHEN: Classify book sales performance
SELECT 
    b.title,
    SUM(o.quantity) AS total_qty,
    CASE 
        WHEN SUM(o.quantity) < 2 THEN 'Low'
        WHEN SUM(o.quantity) BETWEEN 2 AND 4 THEN 'Medium'
        ELSE 'High'
    END AS performance
FROM books b
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.title;

-- Sort books by revenue and author name
SELECT 
    b.title,
    a.name AS author_name,
    SUM(o.quantity * b.price) AS total_revenue
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.title, a.name
ORDER BY total_revenue DESC, a.name ASC;

-- 	Use UNION to merge physical and eBook sales.
SELECT 
    b.title, b.format, SUM(o.quantity) AS total_sold
FROM books b
JOIN orders o ON b.book_id = o.book_id
WHERE b.format = 'Physical'
GROUP BY b.title, b.format

UNION

SELECT 
    b.title, b.format, SUM(o.quantity) AS total_sold
FROM books b
JOIN orders o ON b.book_id = o.book_id
WHERE b.format = 'eBook'
GROUP BY b.title, b.format;
