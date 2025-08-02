CREATE DATABASE movie_booking_analytics;
USE movie_booking_analytics;

-- Create tables
CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE
);

CREATE TABLE theatres (
    theatre_id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    theatre_id INT,
    booking_time DATETIME,
    ticket_price DECIMAL(6,2),
    booking_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id)
);

-- Insert data
INSERT INTO movies VALUES
(1, 'Avengers', 'Action'),
(2, 'Batman', 'Action'),
(3, 'Inception', 'Sci-Fi');

INSERT INTO customers VALUES
(1, 'Alice', 'alice@example.com', '2024-11-10'),
(2, 'Bob', 'bob@example.com', '2025-04-05'),
(3, 'Charlie', 'charlie@example.com', '2025-06-15');

INSERT INTO theatres VALUES
(1, 'PVR', 'Mumbai'),
(2, 'INOX', 'Delhi');

INSERT INTO bookings VALUES
(101, 1, 1, 1, '2025-08-01 10:30:00', 250.00, '2025-08-01'),
(102, 2, 2, 1, '2025-08-01 14:00:00', 300.00, '2025-08-01'),
(103, 1, 2, 2, '2025-08-02 18:30:00', 280.00, '2025-08-02'),
(104, 3, 3, 2, '2025-08-02 12:00:00', 260.00, '2025-08-02'),
(105, 2, 1, 1, '2025-08-03 16:00:00', 270.00, '2025-08-03');

-- Subquery to find movies with bookings above the average
SELECT m.title, COUNT(b.booking_id) AS total_bookings
FROM movies m
JOIN bookings b ON m.movie_id = b.movie_id
GROUP BY m.movie_id, m.title
HAVING COUNT(b.booking_id) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM bookings
        GROUP BY movie_id
    ) AS sub
);

-- JOIN bookings ↔ movies ↔ customers
SELECT b.booking_id, c.name AS customer_name, m.title AS movie_title, b.ticket_price
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN movies m ON b.movie_id = m.movie_id;

-- CASE to classify booking times as "Morning", "Afternoon", "Evening"
SELECT booking_id,
       booking_time,
       CASE
           WHEN HOUR(booking_time) < 12 THEN 'Morning'
           WHEN HOUR(booking_time) BETWEEN 12 AND 17 THEN 'Afternoon'
           ELSE 'Evening'
       END AS booking_period
FROM bookings;

-- INTERSECT: customers who watched both "Avengers" and "Batman"
SELECT customer_id
FROM bookings
WHERE movie_id = 1
AND customer_id IN (
    SELECT customer_id FROM bookings WHERE movie_id = 2
);


-- UNION ALL: combine weekend and weekday ticket sales
SELECT 'Weekend' AS day_type, ticket_price
FROM bookings
WHERE DAYOFWEEK(booking_date) IN (1, 7) -- Sunday(1), Saturday(7)
UNION ALL
SELECT 'Weekday' AS day_type, ticket_price
FROM bookings
WHERE DAYOFWEEK(booking_date) BETWEEN 2 AND 6;

-- Correlated subquery to find customer who booked the most in each theatre
SELECT b.theatre_id, b.customer_id, COUNT(*) AS total_bookings
FROM bookings b
GROUP BY b.theatre_id, b.customer_id
HAVING COUNT(*) = (
    SELECT MAX(sub.count)
    FROM (
        SELECT customer_id, COUNT(*) AS count
        FROM bookings b2
        WHERE b2.theatre_id = b.theatre_id
        GROUP BY customer_id
    ) AS sub
);
