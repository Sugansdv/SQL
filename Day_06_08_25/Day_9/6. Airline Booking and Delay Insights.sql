CREATE DATABASE AirlineInsights;
USE AirlineInsights;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20),
    carrier VARCHAR(50),
    origin VARCHAR(50),
    destination VARCHAR(50),
    aircraft_type VARCHAR(50),
    scheduled_departure DATETIME,
    actual_departure DATETIME,
    scheduled_arrival DATETIME,
    actual_arrival DATETIME
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    flight_id INT,
    booking_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

INSERT INTO customers VALUES
(1, 'Alice', 'alice@gmail.com', 'India'),
(2, 'Bob', 'bob@gmail.com', 'USA'),
(3, 'Charlie', 'charlie@gmail.com', 'UK');

INSERT INTO flights VALUES
(101, 'AI101', 'Air India', 'Delhi', 'Mumbai', 'A320', '2023-08-01 08:00:00', '2023-08-01 08:20:00', '2023-08-01 10:00:00', '2023-08-01 10:15:00'),
(102, 'AI102', 'Air India', 'Delhi', 'Bangalore', 'A320', '2023-08-01 09:00:00', '2023-08-01 09:10:00', '2023-08-01 11:00:00', '2023-08-01 11:05:00'),
(103, '6E301', 'IndiGo', 'Mumbai', 'Chennai', 'A321', '2023-08-01 07:00:00', '2023-08-01 07:25:00', '2023-08-01 09:30:00', '2023-08-01 09:40:00');

INSERT INTO bookings VALUES
(201, 1, 101, '2023-07-25', 'Confirmed'),
(202, 2, 102, '2023-07-26', 'Checked-in'),
(203, 3, 103, '2023-07-27', 'Cancelled');

-- Warehouse: Star Schema with fact_flights, dim_route, dim_aircraft
CREATE TABLE dim_route (
    route_id INT PRIMARY KEY,
    origin VARCHAR(50),
    destination VARCHAR(50)
);

CREATE TABLE dim_aircraft (
    aircraft_id INT PRIMARY KEY,
    aircraft_type VARCHAR(50),
    carrier VARCHAR(50)
);

CREATE TABLE fact_flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20),
    route_id INT,
    aircraft_id INT,
    flight_date DATE,
    departure_delay_minutes INT,
    arrival_delay_minutes INT,
    flight_duration_minutes INT,
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES dim_aircraft(aircraft_id)
);

-- ETL includes delay calculation and flight duration
INSERT INTO dim_route VALUES
(1, 'Delhi', 'Mumbai'),
(2, 'Delhi', 'Bangalore'),
(3, 'Mumbai', 'Chennai');

INSERT INTO dim_aircraft VALUES
(1, 'A320', 'Air India'),
(2, 'A321', 'IndiGo');

INSERT INTO fact_flights
SELECT 
    f.flight_id,
    f.flight_number,
    CASE 
        WHEN f.origin = 'Delhi' AND f.destination = 'Mumbai' THEN 1
        WHEN f.origin = 'Delhi' AND f.destination = 'Bangalore' THEN 2
        WHEN f.origin = 'Mumbai' AND f.destination = 'Chennai' THEN 3
    END AS route_id,
    CASE 
        WHEN f.aircraft_type = 'A320' AND f.carrier = 'Air India' THEN 1
        WHEN f.aircraft_type = 'A321' AND f.carrier = 'IndiGo' THEN 2
    END AS aircraft_id,
    CAST(f.scheduled_departure AS DATE),
    DATEDIFF(MINUTE, f.scheduled_departure, f.actual_departure) AS departure_delay_minutes,
    DATEDIFF(MINUTE, f.scheduled_arrival, f.actual_arrival) AS arrival_delay_minutes,
    DATEDIFF(MINUTE, f.actual_departure, f.actual_arrival) AS flight_duration_minutes
FROM flights f;

-- OLAP reports on average delays by route, carrier ranking
SELECT 
    r.origin,
    r.destination,
    AVG(f.arrival_delay_minutes) AS avg_arrival_delay
FROM fact_flights f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY r.origin, r.destination;

SELECT 
    a.carrier,
    AVG(f.arrival_delay_minutes) AS avg_delay,
    COUNT(f.flight_id) AS total_flights
FROM fact_flights f
JOIN dim_aircraft a ON f.aircraft_id = a.aircraft_id
GROUP BY a.carrier
ORDER BY avg_delay;

-- Compare OLTP system used for check-in vs warehouse used for analytics
SELECT 
    b.booking_id,
    b.status,
    f.flight_number,
    f.scheduled_departure
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
WHERE b.status = 'Checked-in';

SELECT 
    f.flight_number,
    r.origin,
    r.destination,
    f.departure_delay_minutes,
    f.arrival_delay_minutes,
    f.flight_duration_minutes
FROM fact_flights f
JOIN dim_route r ON f.route_id = r.route_id;
