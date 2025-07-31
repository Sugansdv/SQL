CREATE DATABASE airline_db;

USE airline_db;

CREATE TABLE airports (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    city VARCHAR(100),
    code VARCHAR(10) UNIQUE
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(20),
    departure_airport_id INT,
    arrival_airport_id INT,
    departure_time DATETIME,
    arrival_time DATETIME,
    FOREIGN KEY (departure_airport_id) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport_id) REFERENCES airports(airport_id)
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT,
    flight_id INT,
    seat_number VARCHAR(10),
    booking_date DATE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

INSERT INTO airports (name, city, code) VALUES
('Indira Gandhi International', 'Delhi', 'DEL'),
('Chhatrapati Shivaji International', 'Mumbai', 'BOM'),
('Kempegowda International', 'Bangalore', 'BLR'),
('Netaji Subhas Chandra Bose International', 'Kolkata', 'CCU');

INSERT INTO flights (flight_number, departure_airport_id, arrival_airport_id, departure_time, arrival_time) VALUES
('AI101', 1, 2, '2025-08-01 09:00:00', '2025-08-01 11:00:00'),
('AI102', 2, 3, '2025-08-01 14:00:00', '2025-08-01 16:00:00'),
('AI103', 1, 4, '2025-08-02 07:30:00', '2025-08-02 09:30:00'),
('AI104', 3, 1, '2025-08-02 10:00:00', '2025-08-02 12:00:00'),
('AI105', 4, 2, '2025-08-03 17:00:00', '2025-08-03 19:30:00');

INSERT INTO passengers (name, email, phone) VALUES
('Ravi Kumar', 'ravi@example.com', '9990011122'),
('Anita Sharma', 'anita@example.com', '8883344556'),
('Deepak Singh', 'deepak@example.com', '9876543210'),
('Priya Das', 'priya@example.com', '9988776655'),
('Sohail Khan', 'sohail@example.com', '9871234567'),
('Meena Iyer', 'meena@example.com', '9123456789'),
('Arjun Reddy', 'arjun@example.com', '9001122334'),
('Neha Jain', 'neha@example.com', '9012345678'),
('Raj Patel', 'raj@example.com', '9321457689'),
('Kavita Rao', 'kavita@example.com', '9567823490');

INSERT INTO bookings (passenger_id, flight_id, seat_number, booking_date) VALUES
(1, 1, '12A', '2025-07-15'),
(2, 1, '12B', '2025-07-15'),
(3, 2, '14C', '2025-07-20'),
(4, 3, '15D', '2025-07-21'),
(5, 3, '15E', '2025-07-21'),
(6, 4, '10A', '2025-07-22'),
(7, 4, '10B', '2025-07-22'),
(8, 5, '1A', '2025-07-23'),
(9, 5, '1B', '2025-07-23'),
(10, 2, '14A', '2025-07-20');

SELECT 
    f.flight_number,
    a1.code AS departure,
    a2.code AS arrival,
    f.departure_time,
    f.arrival_time
FROM flights f
JOIN airports a1 ON f.departure_airport_id = a1.airport_id
JOIN airports a2 ON f.arrival_airport_id = a2.airport_id
WHERE a1.code = 'DEL' AND a2.code = 'BOM';

SELECT 
    p.name,
    p.email,
    b.seat_number
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
WHERE f.flight_number = 'AI103';





