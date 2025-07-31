CREATE DATABASE hotel_db;
USE hotel_db;

CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL
);

CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    service_charge DECIMAL(10, 2) NOT NULL,
    service_date DATE NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id)
);

INSERT INTO rooms (room_number, room_type, price_per_night) VALUES
('101', 'Single', 100.00),
('102', 'Double', 150.00),
('103', 'Deluxe', 200.00),
('201', 'Suite', 300.00),
('202', 'Single', 100.00);

INSERT INTO guests (name, email) VALUES
('Alice Johnson', 'alice@hotel.com'),
('Bob Smith', 'bob@hotel.com'),
('Charlie Ray', 'charlie@hotel.com');

INSERT INTO bookings (guest_id, room_id, check_in, check_out) VALUES
(1, 101, '2025-07-01', '2025-07-05'),
(2, 102, '2025-07-02', '2025-07-06'),
(1, 103, '2025-07-10', '2025-07-12'),
(3, 201, '2025-07-03', '2025-07-08'),
(2, 202, '2025-07-05', '2025-07-09'),
(3, 103, '2025-07-12', '2025-07-14'),
(1, 102, '2025-07-15', '2025-07-18'),
(2, 201, '2025-07-10', '2025-07-12'),
(3, 101, '2025-07-08', '2025-07-10'),
(1, 202, '2025-07-20', '2025-07-22');

INSERT INTO services (guest_id, service_name, service_charge, service_date) VALUES
(1, 'Room Service', 25.00, '2025-07-01'),
(1, 'Spa', 50.00, '2025-07-02'),
(2, 'Laundry', 15.00, '2025-07-03'),
(3, 'Breakfast', 10.00, '2025-07-04'),
(1, 'Mini Bar', 20.00, '2025-07-10'),
(2, 'Room Service', 25.00, '2025-07-05'),
(3, 'Spa', 50.00, '2025-07-08'),
(1, 'Laundry', 15.00, '2025-07-15');

SELECT 
    b.booking_id,
    g.name AS guest_name,
    r.room_number,
    b.check_in,
    b.check_out,
    DATEDIFF(b.check_out, b.check_in) AS duration_days
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id;

SELECT 
    g.name AS guest_name,
    SUM(s.service_charge) AS total_service_charges
FROM services s
JOIN guests g ON s.guest_id = g.guest_id
GROUP BY s.guest_id;
