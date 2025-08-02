CREATE DATABASE RideSharingDB;
USE RideSharingDB;

CREATE TABLE drivers (
  driver_id INT PRIMARY KEY,
  name VARCHAR(100),
  city VARCHAR(50)
);

CREATE TABLE riders (
  rider_id INT PRIMARY KEY,
  name VARCHAR(100),
  city VARCHAR(50)
);

CREATE TABLE rides (
  ride_id INT PRIMARY KEY,
  driver_id INT,
  rider_id INT,
  start_time DATETIME,
  end_time DATETIME,
  ride_type VARCHAR(20),  
  status VARCHAR(20),  
  city VARCHAR(50),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  ride_id INT,
  amount DECIMAL(10,2),
  payment_time DATETIME,
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

INSERT INTO drivers VALUES 
(1, 'Arun', 'Delhi'),
(2, 'Sneha', 'Mumbai');

INSERT INTO riders VALUES 
(1, 'Raj', 'Delhi'),
(2, 'Priya', 'Mumbai'),
(3, 'Vikram', 'Delhi');

INSERT INTO rides VALUES 
(101, 1, 1, '2025-08-01 08:00:00', '2025-08-01 08:30:00', 'Economy', 'Completed', 'Delhi'),
(102, 1, 3, '2025-08-01 09:00:00', '2025-08-01 09:20:00', 'Shared', 'Completed', 'Delhi'),
(103, 2, 2, '2025-08-01 22:00:00', '2025-08-01 22:40:00', 'Premium', 'Cancelled', 'Mumbai'),
(104, 2, 2, '2025-08-01 18:00:00', '2025-08-01 18:25:00', 'Economy', 'Completed', 'Mumbai');

INSERT INTO payments VALUES 
(1001, 101, 250.00, '2025-08-01 08:35:00'),
(1002, 102, 150.00, '2025-08-01 09:25:00'),
(1003, 104, 200.00, '2025-08-01 18:30:00');

-- Subquery to find average ride duration per driver. 
SELECT driver_id,
       (SELECT AVG(TIMESTAMPDIFF(MINUTE, r.start_time, r.end_time))
        FROM rides r2
        WHERE r2.driver_id = r.driver_id) AS avg_duration_minutes
FROM rides r
GROUP BY driver_id;

-- Correlated subquery to get rider with most rides per city. 
SELECT city, rider_id, name, total_rides
FROM (
  SELECT r.city, r.rider_id, ri.name,
         COUNT(*) AS total_rides,
         RANK() OVER (PARTITION BY r.city ORDER BY COUNT(*) DESC) as rnk
  FROM rides r
  JOIN riders ri ON r.rider_id = ri.rider_id
  GROUP BY r.city, r.rider_id
) AS ranked_riders
WHERE rnk = 1;

-- CASE to classify ride types: Shared, Premium, Economy. 
SELECT ride_id, rider_id, driver_id,
  CASE ride_type
    WHEN 'Shared' THEN 'Group Ride'
    WHEN 'Premium' THEN 'Luxury Ride'
    WHEN 'Economy' THEN 'Standard Ride'
    ELSE 'Other'
  END AS ride_category
FROM rides;

-- UNION for completed and cancelled rides. 
SELECT ride_id, rider_id, 'Completed' AS ride_status
FROM rides
WHERE status = 'Completed'

UNION

SELECT ride_id, rider_id, 'Cancelled' AS ride_status
FROM rides
WHERE status = 'Cancelled';

-- Use JOIN + GROUP BY for city-wise earnings. 
SELECT r.city, SUM(p.amount) AS total_earnings
FROM rides r
JOIN payments p ON r.ride_id = p.ride_id
GROUP BY r.city;

-- Date range filter for peak hours (use TIME()). 
SELECT ride_id, start_time, end_time
FROM rides
WHERE (TIME(start_time) BETWEEN '07:00:00' AND '10:00:00')
   OR (TIME(start_time) BETWEEN '17:00:00' AND '20:00:00');



