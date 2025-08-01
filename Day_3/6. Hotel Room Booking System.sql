CREATE DATABASE hotel_db;

USE hotel_db;

-- 1. Create Tables

CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10),
    room_type VARCHAR(50)  -- e.g., Deluxe, Standard, Suite
);

CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    name VARCHAR(100),
    contact_info VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- 2. Insert Sample Data

-- Rooms
INSERT INTO rooms (room_id, room_number, room_type) VALUES
(1, '101', 'Deluxe'),
(2, '102', 'Standard'),
(3, '201', 'Suite'),
(4, '202', 'Deluxe');

-- Guests
INSERT INTO guests (guest_id, name, contact_info) VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com'),
(4, 'David', 'david@example.com');

-- Bookings
INSERT INTO bookings (booking_id, guest_id, room_id, check_in, check_out) VALUES
(1, 1, 1, '2023-07-01', '2023-07-04'),
(2, 1, 1, '2023-07-10', '2023-07-12'),
(3, 2, 2, '2023-07-02', '2023-07-03'),
(4, 3, 1, '2023-07-05', '2023-07-07'),
(5, 4, 3, '2023-07-01', '2023-07-05'),
(6, 2, 1, '2023-07-08', '2023-07-10'),
(7, 2, 1, '2023-07-12', '2023-07-14');

-- Payments
INSERT INTO payments (payment_id, booking_id, amount, payment_date) VALUES
(1, 1, 3000.00, '2023-07-01'),
(2, 2, 2000.00, '2023-07-10'),
(3, 3, 1000.00, '2023-07-02'),
(4, 4, 2500.00, '2023-07-05'),
(5, 5, 4000.00, '2023-07-01'),
(6, 6, 2200.00, '2023-07-08'),
(7, 7, 2500.00, '2023-07-12');

-- 3. Total amount paid per guest
SELECT 
    g.guest_id,
    g.name,
    SUM(p.amount) AS total_paid
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.name;

-- 4. Rooms booked more than 5 times
SELECT 
    r.room_id,
    r.room_number,
    COUNT(b.booking_id) AS booking_count
FROM rooms r
JOIN bookings b ON r.room_id = b.room_id
GROUP BY r.room_id, r.room_number
HAVING COUNT(b.booking_id) > 5;

-- 5. Average stay duration grouped by room type
SELECT 
    r.room_type,
    AVG(DATEDIFF(b.check_out, b.check_in)) AS avg_stay_duration
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
GROUP BY r.room_type;

-- 6. INNER JOIN: guests ↔ bookings ↔ rooms
SELECT 
    g.name AS guest_name,
    r.room_number,
    r.room_type,
    b.check_in,
    b.check_out
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN rooms r ON b.room_id = r.room_id;

-- 7. FULL OUTER JOIN: rooms and bookings (MySQL workaround using UNION of LEFT and RIGHT JOIN)
SELECT 
    r.room_id,
    r.room_number,
    b.booking_id,
    b.check_in
FROM rooms r
LEFT JOIN bookings b ON r.room_id = b.room_id

UNION

SELECT 
    r.room_id,
    r.room_number,
    b.booking_id,
    b.check_in
FROM bookings b
RIGHT JOIN rooms r ON b.room_id = r.room_id;

-- 8. SELF JOIN: Guests who booked same room multiple times
SELECT 
    g1.name AS guest_name_1,
    g2.name AS guest_name_2,
    b1.room_id
FROM bookings b1
JOIN bookings b2 ON b1.room_id = b2.room_id 
                AND b1.guest_id = b2.guest_id 
                AND b1.booking_id < b2.booking_id
JOIN guests g1 ON b1.guest_id = g1.guest_id
JOIN guests g2 ON b2.guest_id = g2.guest_id;
