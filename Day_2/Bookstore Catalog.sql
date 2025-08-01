CREATE DATABASE bookstore;

USE bookstore;

-- Table: books: book_id, title, author, genre, price, published_year, stock
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    genre VARCHAR(50),
    price DECIMAL(10,2),
    published_year INT,
    stock INT
);

INSERT INTO books (title, author, genre, price, published_year, stock) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 450.00, 2015, 12),
('The Silent Patient', 'Alex Michaelides', 'Thriller', 600.00, 2020, 5),
('The Alchemist', 'Paulo Coelho', 'Fiction', 399.00, 2012, 10),
('Inferno', 'Dan Brown', 'Mystery', 550.00, 2013, NULL),
('Thinking Fast and Slow', 'Daniel Kahneman', 'Non-Fiction', 499.00, 2011, 3),
('The Book Thief', 'Markus Zusak', 'Fiction', 480.00, 2017, 0),
('Becoming', 'Michelle Obama', 'Biography', 700.00, 2018, NULL);

-- 1. Get all fiction books priced under 500 (show title, author, price)
SELECT title, author, price
FROM books
WHERE genre = 'Fiction' AND price < 500;

-- 2. Use DISTINCT to list all genres
SELECT DISTINCT genre
FROM books;

-- 3. Use LIKE to find titles that start with “The”
SELECT title, author, price
FROM books
WHERE title LIKE 'The%';

-- 4. Filter books published between 2010 and 2023
SELECT title, author, published_year
FROM books
WHERE published_year BETWEEN 2010 AND 2023;

-- 5. Identify books with NULL stock values
SELECT title, author, stock
FROM books
WHERE stock IS NULL;

-- 6. Sort by published_year DESC, then title ASC
SELECT title, author, published_year
FROM books
ORDER BY published_year DESC, title ASC;
