CREATE DATABASE HotelDB;
USE HotelDB;

CREATE TABLE Guests (
    guest_id INT PRIMARY KEY,
    guest_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_type VARCHAR(50),
    base_rate DECIMAL(10,2)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    booking_id INT,
    service_name VARCHAR(100),
    cost DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

CREATE TABLE dim_guest (
    guest_id INT PRIMARY KEY,
    guest_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE dim_room (
    room_id INT PRIMARY KEY,
    room_type VARCHAR(50),
    base_rate DECIMAL(10,2)
);

CREATE TABLE dim_time (
    date DATE PRIMARY KEY,
    day INT,
    month INT,
    year INT,
    season VARCHAR(20)
);

CREATE TABLE fact_booking (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    stay_duration INT,
    room_revenue DECIMAL(10,2),
    service_revenue DECIMAL(10,2),
    total_revenue DECIMAL(10,2),
    FOREIGN KEY (guest_id) REFERENCES dim_guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES dim_room(room_id)
);

INSERT INTO dim_guest SELECT * FROM Guests;

INSERT INTO dim_room SELECT * FROM Rooms;

INSERT INTO dim_time
SELECT DISTINCT 
    check_in AS date,
    DAY(check_in), MONTH(check_in), YEAR(check_in),
    CASE 
        WHEN MONTH(check_in) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(check_in) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(check_in) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END AS season
FROM Bookings;


-- Load dimensions
INSERT INTO dim_guest SELECT * FROM Guests;

INSERT INTO dim_room SELECT * FROM Rooms;

INSERT INTO dim_time
SELECT DISTINCT 
    check_in AS date,
    DAY(check_in), MONTH(check_in), YEAR(check_in),
    CASE 
        WHEN MONTH(check_in) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(check_in) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(check_in) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END AS season
FROM Bookings;

-- Load fact_booking
INSERT INTO fact_booking (booking_id, guest_id, room_id, check_in, check_out, stay_duration, room_revenue, service_revenue, total_revenue)
SELECT 
    b.booking_id,
    b.guest_id,
    b.room_id,
    b.check_in,
    b.check_out,
    DATEDIFF(b.check_out, b.check_in) AS stay_duration,
    DATEDIFF(b.check_out, b.check_in) * r.base_rate AS room_revenue,
    IFNULL(SUM(s.cost), 0) AS service_revenue,
    DATEDIFF(b.check_out, b.check_in) * r.base_rate + IFNULL(SUM(s.cost), 0) AS total_revenue
FROM 
    Bookings b
JOIN 
    Rooms r ON b.room_id = r.room_id
LEFT JOIN 
    Services s ON b.booking_id = s.booking_id
GROUP BY 
    b.booking_id, b.guest_id, b.room_id, b.check_in, b.check_out, r.base_rate;

-- Reporting
-- Occupancy by Season
SELECT 
    dt.season,
    COUNT(fb.booking_id) AS total_bookings
FROM 
    fact_booking fb
JOIN 
    dim_time dt ON fb.check_in = dt.date
GROUP BY dt.season;

-- Room type Profotability
SELECT 
    dr.room_type,
    COUNT(fb.booking_id) AS total_bookings,
    SUM(fb.total_revenue) AS total_revenue,
    AVG(fb.total_revenue) AS avg_revenue_per_booking
FROM 
    fact_booking fb
JOIN 
    dim_room dr ON fb.room_id = dr.room_id
GROUP BY 
    dr.room_type;
 -- OLAP Roll-up: Revenue by Room Type (Monthly)
 SELECT 
    dr.room_type,
    dt.month,
    dt.year,
    SUM(fb.total_revenue) AS monthly_revenue
FROM 
    fact_booking fb
JOIN dim_room dr ON fb.room_id = dr.room_id
JOIN dim_time dt ON fb.check_in = dt.date
GROUP BY 
    dr.room_type, dt.month, dt.year;

-- OLAP Drill-down: Booking Details by Guest
SELECT 
    dg.guest_name,
    fb.booking_id,
    fb.stay_duration,
    fb.total_revenue
FROM 
    fact_booking fb
JOIN dim_guest dg ON fb.guest_id = dg.guest_id
ORDER BY fb.total_revenue DESC;

