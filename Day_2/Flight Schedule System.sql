CREATE DATABASE flight_schedule;

USE flight_schedule;

-- Table: flights: flight_id, flight_number, origin, destination, status, departure_time
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10),
    origin VARCHAR(50),
    destination VARCHAR(50),
    status VARCHAR(20),
    departure_time TIME
);

INSERT INTO flights (flight_number, origin, destination, status, departure_time) VALUES
('6E101', 'Delhi', 'Chennai', 'On Time', '06:30:00'),
('AI302', 'Mumbai', 'Kolkata', NULL, '09:45:00'),
('SJ555', 'Bangalore', 'Hyderabad', 'Delayed', '12:15:00'),
('AI999', 'Chennai', 'Delhi', 'On Time', '15:00:00'),
('6E120AI', 'Pune', 'Chennai', 'On Time', '18:30:00'),
('UK830', 'Kolkata', 'Mumbai', 'Cancelled', '21:00:00');

-- 1. Find flights going to ‘Chennai’ or ‘Mumbai’
SELECT flight_number, origin, destination
FROM flights
WHERE destination IN ('Chennai', 'Mumbai');

-- 2. Use LIKE to find flights ending with "AI"
SELECT flight_number, origin, destination
FROM flights
WHERE flight_number LIKE '%AI';

-- 3. Use BETWEEN for departure times within a day (e.g., 06:00 to 18:00)
SELECT flight_number, origin, destination, departure_time
FROM flights
WHERE departure_time BETWEEN '06:00:00' AND '18:00:00';

-- 4. Check for flights with NULL status
SELECT flight_number, origin, destination
FROM flights
WHERE status IS NULL;

-- 5. List all unique destinations
SELECT DISTINCT destination
FROM flights;

-- 6. Sort by departure_time ASC
SELECT flight_number, origin, destination, departure_time
FROM flights
ORDER BY departure_time ASC;
