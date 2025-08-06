CREATE DATABASE online_bookstore;

USE online_bookstore;

-- Authors Table
CREATE TABLE authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- Genres Table
CREATE TABLE genres (
  genre_id INT AUTO_INCREMENT PRIMARY KEY,
  genre_name VARCHAR(100) NOT NULL
);

-- Publishers Table
CREATE TABLE publishers (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- Books Table (referencing authors, genres, publishers)
CREATE TABLE books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author_id INT,
  genre_id INT,
  publisher_id INT,
  price DECIMAL(10, 2),
  published_date DATE,
  FOREIGN KEY (author_id) REFERENCES authors(author_id),
  FOREIGN KEY (genre_id) REFERENCES genres(genre_id),
  FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- Sales Table
CREATE TABLE sales (
  sale_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT,
  sale_date DATE,
  quantity INT,
  FOREIGN KEY (book_id) REFERENCES books(book_id)
);


-- Insert Authors
INSERT INTO authors (name) VALUES 
('J.K. Rowling'), 
('George R.R. Martin'), 
('J.R.R. Tolkien');

-- Insert Genres
INSERT INTO genres (genre_name) VALUES 
('Fantasy'), 
('Science Fiction'), 
('Mystery');

-- Insert Publishers
INSERT INTO publishers (name) VALUES 
('Bloomsbury'), 
('Bantam Books'), 
('HarperCollins');

-- Insert Books
INSERT INTO books (title, author_id, genre_id, publisher_id, price, published_date) VALUES
('Harry Potter and the Sorcerer\'s Stone', 1, 1, 1, 19.99, '1997-06-26'),
('A Game of Thrones', 2, 1, 2, 24.99, '1996-08-06'),
('The Hobbit', 3, 1, 3, 14.99, '1937-09-21');

-- Insert Sales
INSERT INTO sales (book_id, sale_date, quantity) VALUES
(1, '2025-07-01', 150),
(2, '2025-07-02', 100),
(3, '2025-07-02', 120),
(1, '2025-08-01', 200),
(2, '2025-08-01', 150);

--  Create Indexes

-- Clustered index on book_id (PRIMARY KEY is clustered by default in MySQL)
-- Already added during table creation

-- Non-clustered index on title
CREATE INDEX idx_title ON books(title);

-- Non-clustered index on author_id
CREATE INDEX idx_author_id ON books(author_id);

-- Step 6: Use EXPLAIN to Optimize Book Search

-- Search by title
EXPLAIN SELECT * FROM books WHERE title = 'The Hobbit';

-- Search by author
EXPLAIN SELECT * FROM books WHERE author_id = 3;

-- JOIN to List Books with Publisher and Genre

SELECT
  b.book_id,
  b.title,
  a.name AS author,
  g.genre_name,
  p.name AS publisher,
  b.price
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN genres g ON b.genre_id = g.genre_id
JOIN publishers p ON b.publisher_id = p.publisher_id;

-- Create Denormalized Summary Table for Monthly Book Sales

-- Create the summary table
CREATE TABLE monthly_sales_summary (
  book_id INT,
  month_year VARCHAR(7), -- e.g., '2025-08'
  total_quantity INT,
  PRIMARY KEY (book_id, month_year)
);

-- Populate the summary table
INSERT INTO monthly_sales_summary (book_id, month_year, total_quantity)
SELECT
  book_id,
  DATE_FORMAT(sale_date, '%Y-%m') AS month_year,
  SUM(quantity) AS total_quantity
FROM sales
GROUP BY book_id, month_year;

-- Add Pagination to Best-Selling Books

-- Get best-selling books for August 2025 - Page 1 (first 5 results)
SELECT
  b.title,
  a.name AS author,
  ms.total_quantity
FROM monthly_sales_summary ms
JOIN books b ON ms.book_id = b.book_id
JOIN authors a ON b.author_id = a.author_id
WHERE ms.month_year = '2025-08'
ORDER BY ms.total_quantity DESC
LIMIT 0, 5;

