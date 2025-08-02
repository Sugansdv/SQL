CREATE DATABASE MovieRentalDB;

USE MovieRentalDB;

-- Genres table
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(50)
);

-- Movies table
CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    genre_id INT,
    price DECIMAL(6,2),
    is_purchase BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Rentals table
CREATE TABLE rentals (
    rental_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    movie_id INT,
    rental_date DATE,
    return_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- Purchases table 
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    movie_id INT,
    purchase_date DATE,
    price DECIMAL(6,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

INSERT INTO genres (genre_name) VALUES 
('Action'), ('Comedy'), ('Drama');

INSERT INTO movies (title, genre_id, price, is_purchase) VALUES
('Fast & Furious', 1, 100.00, FALSE),
('Avengers', 1, 120.00, TRUE),
('The Hangover', 2, 80.00, FALSE),
('Superbad', 2, 70.00, TRUE),
('The Shawshank Redemption', 3, 90.00, FALSE),
('Forrest Gump', 3, 95.00, TRUE);

INSERT INTO customers (name, email) VALUES
('Alice', 'alice@email.com'),
('Bob', 'bob@email.com'),
('Charlie', 'charlie@email.com');

INSERT INTO rentals (customer_id, movie_id, rental_date, return_date) VALUES
(1, 1, '2025-07-01', '2025-07-05'),
(2, 1, '2025-07-10', '2025-07-15'),
(3, 3, '2025-07-01', '2025-07-03'),
(1, 3, '2025-08-01', NULL), -- not returned
(2, 5, '2025-08-02', '2025-08-10');

INSERT INTO purchases (customer_id, movie_id, purchase_date, price) VALUES
(1, 2, '2025-07-02', 120.00),
(3, 4, '2025-07-15', 70.00),
(2, 6, '2025-08-01', 95.00);

-- Top 3 rented movies per genre
SELECT m.title, g.genre_name,
       (SELECT COUNT(*) FROM rentals r WHERE r.movie_id = m.movie_id) AS rental_count
FROM movies m
JOIN genres g ON m.genre_id = g.genre_id
WHERE m.movie_id IN (
    SELECT movie_id
    FROM (
        SELECT sub.movie_id, sub.genre_id,
               DENSE_RANK() OVER (PARTITION BY sub.genre_id ORDER BY sub.rental_count DESC) AS rank_in_genre
        FROM (
            SELECT r.movie_id, m.genre_id, COUNT(*) AS rental_count
            FROM rentals r
            JOIN movies m ON r.movie_id = m.movie_id
            GROUP BY r.movie_id, m.genre_id
        ) AS sub
    ) AS ranked
    WHERE rank_in_genre <= 3
);



-- LIKE: Search movies by partial title
SELECT * FROM movies
WHERE title LIKE '%Fast%';

-- Aggregate revenue per genre (from rentals)
SELECT 
    g.genre_name,
    SUM(m.price) AS total_rental_revenue
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
JOIN genres g ON m.genre_id = g.genre_id
GROUP BY g.genre_name;

-- Filter null return dates (IS NULL) to find unreturned movies.
SELECT 
    c.name, m.title, r.rental_date
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.return_date IS NULL;

-- Use CASE to label late returns.
SELECT 
    c.name,
    m.title,
    r.rental_date,
    r.return_date,
    CASE 
        WHEN DATEDIFF(r.return_date, r.rental_date) > 7 THEN 'Late'
        ELSE 'On Time'
    END AS return_status
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.return_date IS NOT NULL;

-- Combine rental and purchase data using UNION ALL.
SELECT 
    c.name,
    m.title,
    'Rental' AS transaction_type,
    r.rental_date AS transaction_date,
    m.price AS amount
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN movies m ON r.movie_id = m.movie_id

UNION ALL

SELECT 
    c.name,
    m.title,
    'Purchase' AS transaction_type,
    p.purchase_date AS transaction_date,
    p.price AS amount
FROM purchases p
JOIN customers c ON p.customer_id = c.customer_id
JOIN movies m ON p.movie_id = m.movie_id;

-- Use JOIN to fetch full customer and rental info.
SELECT 
    c.customer_id,
    c.name,
    c.email,
    m.title,
    r.rental_date,
    r.return_date
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN movies m ON r.movie_id = m.movie_id;
