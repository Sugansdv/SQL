CREATE DATABASE flight_reservation;
USE flight_reservation;

-- Airlines Table
CREATE TABLE airlines (
  airline_id INT AUTO_INCREMENT PRIMARY KEY,
  airline_name VARCHAR(100) NOT NULL
);

-- Airports Table
CREATE TABLE airports (
  airport_id INT AUTO_INCREMENT PRIMARY KEY,
  airport_code VARCHAR(10) NOT NULL,
  airport_name VARCHAR(100),
  city VARCHAR(100),
  country VARCHAR(100)
);

-- Flights Table
CREATE TABLE flights (
  flight_id INT AUTO_INCREMENT PRIMARY KEY,
  airline_id INT,
  departure_airport INT,
  arrival_airport INT,
  flight_date DATE,
  departure_time TIME,
  arrival_time TIME,
  FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
  FOREIGN KEY (departure_airport) REFERENCES airports(airport_id),
  FOREIGN KEY (arrival_airport) REFERENCES airports(airport_id)
);

-- Passengers Table
CREATE TABLE passengers (
  passenger_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  passport_number VARCHAR(20),
  nationality VARCHAR(50)
);

-- Bookings Table
CREATE TABLE bookings (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  passenger_id INT,
  flight_id INT,
  seat_number VARCHAR(10),
  booking_date DATE,
  FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
  FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- Design in 3NF (airlines and airports in separate tables)

-- Index flight_date, departure_airport, passenger_id

CREATE INDEX idx_flight_date ON flights(flight_date);
CREATE INDEX idx_departure_airport ON flights(departure_airport);
CREATE INDEX idx_passenger_id ON bookings(passenger_id);

-- Use EXPLAIN on searches by airport and date

EXPLAIN
SELECT 
  f.flight_id,
  a.airline_name,
  dep.airport_code AS departure,
  arr.airport_code AS arrival,
  f.flight_date
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN airports dep ON f.departure_airport = dep.airport_id
JOIN airports arr ON f.arrival_airport = arr.airport_id
WHERE f.departure_airport = 1 AND f.flight_date = '2025-08-07';

-- Subquery to find passengers with the most flights

SELECT 
  passenger_id,
  CONCAT(first_name, ' ', last_name) AS passenger_name,
  (
    SELECT COUNT(*) 
    FROM bookings b 
    WHERE b.passenger_id = p.passenger_id
  ) AS total_flights
FROM passengers p
ORDER BY total_flights DESC
LIMIT 1;

-- Create a denormalized table for frequent flyer reporting

CREATE TABLE frequent_flyer_summary (
  passenger_id INT PRIMARY KEY,
  passenger_name VARCHAR(100),
  total_flights INT,
  last_flight_date DATE
);

INSERT INTO frequent_flyer_summary (passenger_id, passenger_name, total_flights, last_flight_date)
SELECT 
  p.passenger_id,
  CONCAT(p.first_name, ' ', p.last_name),
  COUNT(b.booking_id) AS total_flights,
  MAX(f.flight_date) AS last_flight
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
GROUP BY p.passenger_id, passenger_name;

-- Use LIMIT to display next 5 upcoming flights

SELECT 
  f.flight_id,
  a.airline_name,
  dep.airport_code AS departure,
  arr.airport_code AS arrival,
  f.flight_date,
  f.departure_time
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN airports dep ON f.departure_airport = dep.airport_id
JOIN airports arr ON f.arrival_airport = arr.airport_id
WHERE f.flight_date > CURDATE()
ORDER BY f.flight_date, f.departure_time
LIMIT 5;
