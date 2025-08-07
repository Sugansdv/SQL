CREATE DATABASE CinemaSalesDB;
USE CinemaSalesDB;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE theaters (
    theater_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    capacity INT
);

CREATE TABLE shows (
    show_id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    genre VARCHAR(50),
    show_time DATETIME,
    theater_id INT,
    ticket_price DECIMAL(10,2),
    currency VARCHAR(10),
    FOREIGN KEY (theater_id) REFERENCES theaters(theater_id)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    show_id INT,
    seats_booked INT,
    booking_time DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (show_id) REFERENCES shows(show_id)
);

INSERT INTO customers VALUES 
(1, 'Alice', 'alice@gmail.com', '1234567890'),
(2, 'Bob', 'bob@gmail.com', '2345678901');

INSERT INTO theaters VALUES 
(1, 'Cineplex A', 'Mumbai', 200),
(2, 'Cineplex B', 'Delhi', 150);

INSERT INTO shows VALUES 
(1, 'Inception', 'Sci-Fi', '2025-08-01 18:00:00', 1, 250.00, 'INR'),
(2, 'Titanic', 'Romance', '2025-08-01 20:00:00', 2, 300.00, 'INR');

INSERT INTO bookings VALUES 
(1, 1, 1, 2, '2025-07-25 10:00:00'),
(2, 2, 2, 3, '2025-07-26 11:00:00');

-- Star Schema: fact_bookings, dim_movie, dim_time, dim_customer
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE dim_movie (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(20)
);

CREATE TABLE fact_bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    time_id INT,
    theater_id INT,
    seats_booked INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- ETL includes timestamp conversion, currency standardization
INSERT INTO dim_customer
SELECT DISTINCT customer_id, name, email, phone FROM customers;

INSERT INTO dim_movie
SELECT DISTINCT 1 AS movie_id, movie_name, genre FROM shows WHERE show_id = 1
UNION
SELECT DISTINCT 2 AS movie_id, movie_name, genre FROM shows WHERE show_id = 2;

INSERT INTO dim_time VALUES 
(1, '2025-07-25', 25, 7, 2025, 'Friday'),
(2, '2025-07-26', 26, 7, 2025, 'Saturday');

INSERT INTO fact_bookings VALUES 
(1, 1, 1, 1, 1, 2, 500.00),
(2, 2, 2, 2, 2, 3, 900.00);

-- Reporting: occupancy rates by movie, genre-based trend analysis
SELECT 
    d.movie_name,
    SUM(f.seats_booked) AS total_seats_booked,
    t.capacity,
    ROUND((SUM(f.seats_booked) * 100.0 / t.capacity), 2) AS occupancy_rate
FROM fact_bookings f
JOIN dim_movie d ON f.movie_id = d.movie_id
JOIN theaters t ON f.theater_id = t.theater_id
GROUP BY d.movie_name, t.capacity;

SELECT 
    d.genre,
    COUNT(f.booking_id) AS total_bookings
FROM fact_bookings f
JOIN dim_movie d ON f.movie_id = d.movie_id
GROUP BY d.genre;

-- Compare real-time OLTP check-ins with OLAP historical insights
SELECT * FROM bookings;

SELECT 
    d.movie_name,
    dt.year,
    SUM(f.seats_booked) AS total_seats
FROM fact_bookings f
JOIN dim_movie d ON f.movie_id = d.movie_id
JOIN dim_time dt ON f.time_id = dt.time_id
GROUP BY d.movie_name, dt.year;
