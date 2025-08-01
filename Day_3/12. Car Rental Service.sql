CREATE DATABASE car_rental_service;
USE car_rental_service;

CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    model VARCHAR(100),
    type VARCHAR(50),
    daily_rate DECIMAL(6,2)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    vehicle_id INT,
    customer_id INT,
    rental_date DATE,
    return_date DATE,
    total_cost DECIMAL(8,2),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    rental_id INT,
    amount_paid DECIMAL(8,2),
    payment_date DATE,
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-- Vehicles
INSERT INTO vehicles VALUES
(1, 'Toyota Corolla', 'Sedan', 1500.00),
(2, 'Honda Civic', 'Sedan', 1600.00),
(3, 'Ford Explorer', 'SUV', 2500.00),
(4, 'Toyota Corolla', 'Sedan', 1500.00),
(5, 'Jeep Wrangler', 'SUV', 3000.00);

-- Customers
INSERT INTO customers VALUES
(1, 'Alice', '9876543210'),
(2, 'Bob', '9123456780'),
(3, 'Charlie', '9988776655');

-- Rentals
INSERT INTO rentals VALUES
(1, 1, 1, '2025-06-01', '2025-06-03', 4500.00),
(2, 2, 2, '2025-06-05', '2025-06-10', 8000.00),
(3, 1, 3, '2025-06-12', '2025-06-15', 6000.00),
(4, 3, 1, '2025-06-15', '2025-06-17', 5000.00),
(5, 5, 2, '2025-06-18', '2025-06-19', 3000.00),
(6, 1, 2, '2025-06-20', '2025-06-21', 3000.00),
(7, 1, 3, '2025-06-22', '2025-06-23', 3000.00),
(8, 1, 1, '2025-06-24', '2025-06-25', 3000.00),
(9, 1, 1, '2025-06-26', '2025-06-27', 3000.00),
(10, 1, 2, '2025-06-28', '2025-06-29', 3000.00),
(11, 1, 2, '2025-07-01', '2025-07-02', 3000.00);

-- Payments
INSERT INTO payments VALUES
(1, 1, 4500.00, '2025-06-03'),
(2, 2, 8000.00, '2025-06-10'),
(3, 3, 6000.00, '2025-06-15'),
(4, 4, 5000.00, '2025-06-17'),
(5, 5, 3000.00, '2025-06-19'),
(6, 6, 3000.00, '2025-06-21');

-- 1. Total rentals per vehicle
SELECT v.model, COUNT(r.rental_id) AS total_rentals
FROM vehicles v
LEFT JOIN rentals r ON v.vehicle_id = r.vehicle_id
GROUP BY v.model;

-- 2. Vehicles rented more than 10 times (HAVING)
SELECT v.model, COUNT(r.rental_id) AS rental_count
FROM vehicles v
JOIN rentals r ON v.vehicle_id = r.vehicle_id
GROUP BY v.model
HAVING COUNT(r.rental_id) > 10;

-- 3. Average rental cost per car type
SELECT v.type, AVG(r.total_cost) AS avg_rental_cost
FROM vehicles v
JOIN rentals r ON v.vehicle_id = r.vehicle_id
GROUP BY v.type;

-- 4. INNER JOIN: rentals ↔ vehicles
SELECT r.rental_id, v.model, r.rental_date, r.total_cost
FROM rentals r
INNER JOIN vehicles v ON r.vehicle_id = v.vehicle_id;

-- 5. LEFT JOIN: vehicles ↔ payments (via rentals)
SELECT v.model, r.rental_id, p.amount_paid
FROM vehicles v
LEFT JOIN rentals r ON v.vehicle_id = r.vehicle_id
LEFT JOIN payments p ON r.rental_id = p.rental_id;

-- 6. SELF JOIN: cars of the same model and type
SELECT v1.vehicle_id AS car1_id, v2.vehicle_id AS car2_id, v1.model, v1.type
FROM vehicles v1
JOIN vehicles v2 
  ON v1.model = v2.model AND v1.type = v2.type AND v1.vehicle_id < v2.vehicle_id;
