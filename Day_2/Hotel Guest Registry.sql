CREATE DATABASE hotel_registry;

USE hotel_registry;

-- Table: guests: guest_id, name, room_type, check_in, check_out, payment_status
CREATE TABLE guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    room_type VARCHAR(50),
    check_in DATE,
    check_out DATE,
    payment_status VARCHAR(20)
);

INSERT INTO guests (name, room_type, check_in, check_out, payment_status) VALUES
('Karan Mehta', 'Deluxe', '2025-07-20', '2025-07-25', 'Paid'),
('Priya Sharma', 'Suite', '2025-07-15', '2025-07-22', NULL),
('Komal Rai', 'Standard', '2025-07-18', '2025-07-23', 'Unpaid'),
('Amit Verma', 'Deluxe', '2025-07-10', '2025-07-12', 'Paid'),
('Kavya Nair', 'Suite', '2025-07-21', '2025-07-28', NULL),
('Rohit Sen', 'Standard', '2025-07-05', '2025-07-07', 'Paid');

-- Retrieve guests who stayed between two specific dates.
SELECT guest_id, name, room_type, check_in, check_out, payment_status
FROM guests
WHERE check_in >= '2025-07-15' AND check_out <= '2025-07-28';

-- Select only name, room_type, and check_in.
SELECT name, room_type, check_in
FROM guests;

-- Filter those with payment_status IS NULL.
SELECT guest_id, name, room_type, check_in, check_out
FROM guests
WHERE payment_status IS NULL;

-- Use LIKE to find guests with names starting with “K”.
SELECT guest_id, name, room_type, check_in, check_out
FROM guests
WHERE name LIKE 'K%';

-- Use DISTINCT to list room types.
SELECT DISTINCT room_type
FROM guests;

-- Sort by check_out DESC, name ASC.
SELECT guest_id, name, room_type, check_in, check_out, payment_status
FROM guests
ORDER BY check_out DESC, name ASC;
