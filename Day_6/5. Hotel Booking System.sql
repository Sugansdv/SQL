CREATE DATABASE hotel_booking;
USE hotel_booking;

-- Room Types Table
CREATE TABLE room_types (
  room_type_id INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL,
  description TEXT
);

-- Guests Table
CREATE TABLE guests (
  guest_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(20)
);

-- Rooms Table
CREATE TABLE rooms (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  room_number VARCHAR(10) NOT NULL,
  room_type_id INT,
  FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id)
);

-- Bookings Table
CREATE TABLE bookings (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  guest_id INT,
  room_id INT,
  check_in DATE,
  check_out DATE,
  status ENUM('Booked', 'Checked-In', 'Checked-Out', 'Cancelled'),
  FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
  FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

-- Payments Table
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT,
  amount DECIMAL(10, 2),
  payment_date DATE,
  method ENUM('Cash', 'Card', 'Online'),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Normalize bookings and guest details to 3NF

-- Index room_type, check_in, guest_id

CREATE INDEX idx_room_type ON rooms(room_type_id);
CREATE INDEX idx_check_in ON bookings(check_in);
CREATE INDEX idx_guest_id ON bookings(guest_id);

-- Use EXPLAIN to analyze booking history queries

EXPLAIN
SELECT 
  b.booking_id,
  g.first_name,
  g.last_name,
  r.room_number,
  b.check_in,
  b.check_out
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
WHERE g.guest_id = 5;

-- Use LIMIT to return top 10 highest-paying guests

SELECT 
  g.guest_id,
  CONCAT(g.first_name, ' ', g.last_name) AS guest_name,
  SUM(p.amount) AS total_paid
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, guest_name
ORDER BY total_paid DESC
LIMIT 10;

-- Optimize performance of join across 3+ tables: rooms + guests + payments

EXPLAIN
SELECT 
  g.first_name,
  g.last_name,
  r.room_number,
  rt.type_name,
  p.amount
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN rooms r ON b.room_id = r.room_id
JOIN room_types rt ON r.room_type_id = rt.room_type_id
JOIN payments p ON b.booking_id = p.booking_id;

-- Create a denormalized table for daily revenue reporting

CREATE TABLE daily_revenue (
  revenue_date DATE PRIMARY KEY,
  total_revenue DECIMAL(12, 2)
);

-- Populate the denormalized revenue table

INSERT INTO daily_revenue (revenue_date, total_revenue)
SELECT 
  payment_date AS revenue_date,
  SUM(amount) AS total_revenue
FROM payments
GROUP BY payment_date;
