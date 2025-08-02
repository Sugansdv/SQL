CREATE DATABASE HotelSystem;
USE HotelSystem;

CREATE TABLE rooms (
  room_id INT PRIMARY KEY,
  room_number VARCHAR(10),
  type VARCHAR(20),
  rate_per_night DECIMAL(10,2)
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

INSERT INTO rooms VALUES
(1, '101', 'Economy', 1000),
(2, '102', 'Deluxe', 2000),
(3, '103', 'Suite', 3500);

INSERT INTO guests VALUES
(1, 'Amit Mehra', 'amit@gmail.com'),
(2, 'Riya Sharma', 'riya@gmail.com'),
(3, 'John Doe', 'john@example.com');

INSERT INTO bookings VALUES
(1, 1, 1, '2025-07-01', '2025-07-05'),
(2, 2, 2, '2025-08-01', '2025-08-04'),
(3, 3, 2, '2025-08-05', '2025-08-08');

INSERT INTO payments VALUES
(1, 1, 4000, '2025-07-05'),
(2, 2, 6000, '2025-08-04'),
(3, 3, 6000, '2025-08-08');

-- Subquery in SELECT to show bill summary per guest. 
SELECT g.name, 
       (SELECT SUM(p.amount) 
        FROM payments p 
        JOIN bookings b ON p.booking_id = b.booking_id 
        WHERE b.guest_id = g.guest_id) AS total_spent
FROM guests g;

-- CASE to label room types: Economy, Deluxe, Suite. 
SELECT room_id, room_number, 
  CASE 
    WHEN type = 'Economy' THEN 'Budget'
    WHEN type = 'Deluxe' THEN 'Comfort'
    WHEN type = 'Suite' THEN 'Luxury'
    ELSE 'Other'
  END AS category
FROM rooms;

-- UNION to combine completed and upcoming bookings. 
SELECT booking_id, guest_id, room_id, check_in, check_out, 'Completed' AS status
FROM bookings
WHERE check_out < CURDATE()

UNION

SELECT booking_id, guest_id, room_id, check_in, check_out, 'Upcoming' AS status
FROM bookings
WHERE check_in >= CURDATE();

-- Correlated subquery to find most frequent guest per room type.
SELECT g.name, r.type
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN rooms r ON b.room_id = r.room_id
WHERE g.guest_id = (
  SELECT b2.guest_id
  FROM bookings b2
  JOIN rooms r2 ON b2.room_id = r2.room_id
  WHERE r2.type = r.type
  GROUP BY b2.guest_id
  ORDER BY COUNT(*) DESC
  LIMIT 1
);
 
-- JOIN + GROUP BY for revenue per room type. 
SELECT r.type, SUM(p.amount) AS total_revenue
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN rooms r ON b.room_id = r.room_id
GROUP BY r.type;

-- Date filtering for check-in/check-out analytics. 
-- Upcoming check-ins in next 7 days
SELECT g.name, b.check_in
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
WHERE b.check_in BETWEEN CURDATE() AND CURDATE() + INTERVAL 7 DAY;

-- Past check-outs in last 7 days
SELECT g.name, b.check_out
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
WHERE b.check_out BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE();
