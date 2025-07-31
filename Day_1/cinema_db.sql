CREATE DATABASE cinema_db;

use cinema_db;

CREATE TABLE screens ( screen_id INT PRIMARY KEY AUTO_INCREMENT ,screen_name VARCHAR(50), seats INT);

CREATE TABLE movies (
	movie_id INT PRIMARY KEY AUTO_INCREMENT, 
    movie_title VARCHAR(50),
    movie_genre VARCHAR(50), 
    movie_duration INT, 
    release_date DATE 
    );

CREATE TABLE customers (
	customer_id INT PRIMARY KEY AUTO_INCREMENT ,
    customer_name VARCHAR(50), 
    customer_email VARCHAR(50) 
    );
    
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    movie_id INT,
    screen_id INT,
    show_time DATETIME,
    seat_number VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (screen_id) REFERENCES screens(screen_id) 
);

INSERT INTO movies (movie_title, movie_genre, movie_duration,release_date
) VALUES
('Inception', 'Sci-Fi', 148,'2025-08-02'),
('Avatar', 'Adventure', 162,'2025-08-03'),
('Interstellar', 'Sci-Fi', 169, '2025-08-15'),
('The Dark Knight', 'Action', 152, '2025-08-07'),
('Titanic', 'Romance', 195,'2025-08-05');

INSERT INTO screens (screen_name, seats) VALUES
('Screen 1', 100),
('Screen 2', 80),
('Screen 3', 60);

INSERT INTO customers (customer_name, customer_email) VALUES
('Arjun', 'arjun@mail.com'),
('Priya', 'priya@mail.com'),
('Ravi', 'ravi@mail.com'),
('Sneha', 'sneha@mail.com'),
('Meena', 'meena@mail.com'),
('Rahul', 'rahul@mail.com'),
('Kiran', 'kiran@mail.com'),
('Divya', 'divya@mail.com');

INSERT INTO bookings (customer_id, movie_id, screen_id, show_time, seat_number) VALUES
(1, 1, 1, '2025-08-01 18:00:00', 'A1'),
(2, 1, 1, '2025-08-01 18:00:00', 'A2'),
(3, 2, 2, '2025-08-01 20:00:00', 'B1'),
(4, 3, 1, '2025-08-02 14:00:00', 'C1'),
(5, 4, 3, '2025-08-02 16:00:00', 'D1'),
(6, 5, 2, '2025-08-02 19:00:00', 'E1'),
(7, 1, 1, '2025-08-03 18:00:00', 'A3'),
(8, 3, 1, '2025-08-03 14:00:00', 'C2'),
(1, 2, 2, '2025-08-03 20:00:00', 'B2'),
(2, 4, 3, '2025-08-04 18:00:00', 'D2'),
(3, 1, 1, '2025-08-04 18:00:00', 'A4'),
(4, 5, 2, '2025-08-04 19:00:00', 'E2'),
(5, 3, 1, '2025-08-05 14:00:00', 'C3'),
(6, 3, 1, '2025-08-05 14:00:00', 'C4'),
(7, 3, 1, '2025-08-05 14:00:00', 'C5');

SELECT 
    m.movie_title,
    b.show_time,
    b.screen_id,
    GROUP_CONCAT(b.seat_number ORDER BY b.seat_number) AS booked_seats
FROM bookings b
JOIN movies m ON b.movie_id = m.movie_id
GROUP BY m.movie_title, b.show_time, b.screen_id
ORDER BY b.show_time;


SELECT 
    m.movie_title,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN movies m ON b.movie_id = m.movie_id
GROUP BY m.movie_id
ORDER BY total_bookings DESC
LIMIT 3;

select * from bookings;

delete from bookings where booking_id=10;

select * from customers;
delete from bookings where booking_id=6;

select * from movies;

DELETE FROM customers WHERE customer_id = 3;















    
