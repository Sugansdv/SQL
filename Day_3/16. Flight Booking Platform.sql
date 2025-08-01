CREATE DATABASE flight_booking;
USE flight_booking;

CREATE TABLE airlines (
    airline_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    airline_id INT,
    origin VARCHAR(100),
    destination VARCHAR(100),
    capacity INT,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    seats_booked INT,
    booking_date DATE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

-- Airlines
INSERT INTO airlines VALUES
(1, 'SkyJet'),
(2, 'AirNova'),
(3, 'IndigoXpress');

-- Flights
INSERT INTO flights VALUES
(1, 1, 'Delhi', 'Mumbai', 180),
(2, 2, 'Bangalore', 'Chennai', 150),
(3, 1, 'Mumbai', 'Kolkata', 200),
(4, 3, 'Delhi', 'Goa', 120),
(5, 2, 'Mumbai', 'Delhi', 180);

-- Passengers
INSERT INTO passengers VALUES
(1, 'Ravi Kumar', 'ravi@mail.com'),
(2, 'Sneha Mehra', 'sneha@mail.com'),
(3, 'Amit Patel', 'amit@mail.com'),
(4, 'Neha Singh', 'neha@mail.com');

-- Bookings
INSERT INTO bookings VALUES
(1, 1, 1, 2, '2025-07-01'),
(2, 2, 1, 1, '2025-07-02'),
(3, 3, 2, 3, '2025-07-03'),
(4, 4, 3, 2, '2025-07-04'),
(5, 1, 2, 1, '2025-07-05'),
(6, 1, 3, 2, '2025-07-06'),
(7, 3, 4, 1, '2025-07-07'),
(8, 5, 1, 2, '2025-07-08'),
(9, 5, 2, 3, '2025-07-09');

-- 1. Total bookings per airline
SELECT a.name AS airline_name, COUNT(b.booking_id) AS total_bookings
FROM airlines a
JOIN flights f ON a.airline_id = f.airline_id
JOIN bookings b ON f.flight_id = b.flight_id
GROUP BY a.airline_id, a.name;

-- 2. Most frequent flyers (by number of bookings)
SELECT p.name AS passenger_name, COUNT(b.booking_id) AS total_bookings
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_id, p.name
ORDER BY total_bookings DESC;

-- 3. Flights with average occupancy > 80%
SELECT f.flight_id, f.origin, f.destination, f.capacity,
       AVG(b.seats_booked) AS avg_seats, 
       (AVG(b.seats_booked)/f.capacity)*100 AS avg_occupancy_percent
FROM flights f
JOIN bookings b ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.origin, f.destination, f.capacity
HAVING (AVG(b.seats_booked)/f.capacity)*100 > 80;

-- 4. INNER JOIN bookings ↔ flights ↔ passengers
SELECT b.booking_id, f.origin, f.destination, p.name AS passenger_name, b.seats_booked
FROM bookings b
INNER JOIN flights f ON b.flight_id = f.flight_id
INNER JOIN passengers p ON b.passenger_id = p.passenger_id;

-- 5. RIGHT JOIN: airlines ↔ flights (to show all flights even for missing airline info)
SELECT a.name AS airline_name, f.flight_id, f.origin, f.destination
FROM airlines a
RIGHT JOIN flights f ON a.airline_id = f.airline_id;

-- 6. SELF JOIN: Passengers who flew the same routes
SELECT DISTINCT p1.name AS passenger1, p2.name AS passenger2, f1.origin, f1.destination
FROM bookings b1
JOIN flights f1 ON b1.flight_id = f1.flight_id
JOIN passengers p1 ON b1.passenger_id = p1.passenger_id

JOIN bookings b2 ON f1.origin = (SELECT origin FROM flights WHERE flight_id = b2.flight_id)
                 AND f1.destination = (SELECT destination FROM flights WHERE flight_id = b2.flight_id)
JOIN passengers p2 ON b2.passenger_id = p2.passenger_id

WHERE p1.passenger_id < p2.passenger_id;

