CREATE DATABASE LogisticsFleetDB;
USE LogisticsFleetDB;

CREATE TABLE deliveries (
  delivery_id INT PRIMARY KEY,
  vehicle_id INT,
  driver_id INT,
  route_id INT,
  delivery_time DATETIME,
  gps_start VARCHAR(255),
  gps_end VARCHAR(255),
  fuel_used DECIMAL(5,2)
);

CREATE TABLE vehicles (
  vehicle_id INT PRIMARY KEY,
  vehicle_type VARCHAR(100),
  capacity INT
);

CREATE TABLE drivers (
  driver_id INT PRIMARY KEY,
  name VARCHAR(100),
  license_no VARCHAR(50)
);

CREATE TABLE routes (
  route_id INT PRIMARY KEY,
  origin VARCHAR(100),
  destination VARCHAR(100),
  distance_km DECIMAL(6,2)
);

INSERT INTO vehicles VALUES
(1, 'Truck', 5000),
(2, 'Van', 2000);

INSERT INTO drivers VALUES
(1, 'Arun Kumar', 'LIC12345'),
(2, 'Meena S.', 'LIC67890');

INSERT INTO routes VALUES
(1, 'Chennai', 'Coimbatore', 510.5),
(2, 'Madurai', 'Trichy', 140.3);

INSERT INTO deliveries VALUES
(1, 1, 1, 1, '2025-08-01 09:00:00', '13.0827,80.2707', '11.0168,76.9558', 70.5),
(2, 2, 2, 2, '2025-08-02 15:30:00', '9.9252,78.1198', '10.7905,78.7047', 25.3);

-- Requirements: Warehouse: Star Schema with delivery fact and dimensions.

CREATE TABLE dim_vehicle (
  vehicle_id INT PRIMARY KEY,
  vehicle_type VARCHAR(100),
  capacity INT
);

CREATE TABLE dim_driver (
  driver_id INT PRIMARY KEY,
  name VARCHAR(100),
  license_no VARCHAR(50)
);

CREATE TABLE dim_route (
  route_id INT PRIMARY KEY,
  origin VARCHAR(100),
  destination VARCHAR(100),
  distance_km DECIMAL(6,2)
);

CREATE TABLE dim_time (
  time_id INT PRIMARY KEY,
  delivery_date DATE,
  day INT,
  month INT,
  year INT,
  weekday VARCHAR(10)
);

CREATE TABLE fact_delivery (
  delivery_id INT PRIMARY KEY,
  time_id INT,
  vehicle_id INT,
  driver_id INT,
  route_id INT,
  fuel_used DECIMAL(5,2),
  gps_start VARCHAR(255),
  gps_end VARCHAR(255),
  FOREIGN KEY (vehicle_id) REFERENCES dim_vehicle(vehicle_id),
  FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
  FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
  FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- Requirements: ETL cleans GPS coordinates and timestamps.

INSERT INTO dim_vehicle SELECT * FROM vehicles;
INSERT INTO dim_driver SELECT * FROM drivers;
INSERT INTO dim_route SELECT * FROM routes;

INSERT INTO dim_time
SELECT DISTINCT
  ROW_NUMBER() OVER () AS time_id,
  CAST(delivery_time AS DATE) AS delivery_date,
  DAY(delivery_time) AS day,
  MONTH(delivery_time) AS month,
  YEAR(delivery_time) AS year,
  DATENAME(WEEKDAY, delivery_time) AS weekday
FROM deliveries;

INSERT INTO fact_delivery (delivery_id, time_id, vehicle_id, driver_id, route_id, fuel_used, gps_start, gps_end)
SELECT 
  d.delivery_id,
  t.time_id,
  d.vehicle_id,
  d.driver_id,
  d.route_id,
  d.fuel_used,
  d.gps_start,
  d.gps_end
FROM deliveries d
JOIN dim_time t ON CAST(d.delivery_time AS DATE) = t.delivery_date;

-- Requirements: Reports: fuel usage per trip, driver performance over time.

SELECT 
  d.name AS driver_name,
  SUM(f.fuel_used) AS total_fuel_used
FROM fact_delivery f
JOIN dim_driver d ON f.driver_id = d.driver_id
GROUP BY d.name;

SELECT 
  t.month,
  d.name AS driver_name,
  COUNT(*) AS trips_made
FROM fact_delivery f
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_driver d ON f.driver_id = d.driver_id
GROUP BY t.month, d.name;

-- Requirements: OLAP used for route optimization analysis.

SELECT 
  r.origin,
  r.destination,
  AVG(r.distance_km) AS avg_distance,
  AVG(f.fuel_used) AS avg_fuel_used
FROM fact_delivery f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY r.origin, r.destination;
