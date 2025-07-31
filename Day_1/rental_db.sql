CREATE DATABASE rental_db;

USE rental_db;

CREATE TABLE vehicle_types (
  type_id INT PRIMARY KEY AUTO_INCREMENT,
  type_name VARCHAR(50) NOT NULL
);

CREATE TABLE vehicles (
  vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
  model VARCHAR(100),
  type_id INT,
  registration_no VARCHAR(50) UNIQUE,
  FOREIGN KEY (type_id) REFERENCES vehicle_types(type_id)
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(15)
);

CREATE TABLE rentals (
  rental_id INT PRIMARY KEY AUTO_INCREMENT,
  vehicle_id INT,
  customer_id INT,
  start_date DATE,
  end_date DATE,
  cost DECIMAL(10, 2),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO vehicle_types (type_name) VALUES
('Sedan'), ('SUV'), ('Bike'), ('Truck');

INSERT INTO vehicles (model, type_id, registration_no) VALUES
('Honda City', 1, 'KA01AB1234'),
('Toyota Fortuner', 2, 'MH02XY4567'),
('Royal Enfield', 3, 'DL03MN7890'),
('Tata Ace', 4, 'TN04PQ3210'),
('KTM Duke', 3, 'KA05GH1122');

INSERT INTO customers (name, email, phone) VALUES
('Alice', 'alice@mail.com', '9876543210'),
('Bob', 'bob@mail.com', '9123456780'),
('Charlie', 'charlie@mail.com', '9988776655');

INSERT INTO rentals (vehicle_id, customer_id, start_date, end_date, cost) VALUES
(1, 1, '2025-07-01', '2025-07-05', 4000),
(2, 2, '2025-07-02', '2025-07-06', 6000),
(3, 3, '2025-07-03', '2025-07-04', 1500),
(4, 1, '2025-07-05', '2025-07-10', 8000),
(5, 2, '2025-07-07', '2025-07-08', 1800),
(1, 3, '2025-07-10', '2025-07-12', 2500);

SELECT
  v.model,
  v.registration_no,
  r.start_date,
  r.end_date,
  c.name AS rented_by
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.start_date BETWEEN '2025-07-01' AND '2025-07-08'
ORDER BY r.start_date;

SELECT
  vt.type_name,
  SUM(r.cost) AS total_income
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN vehicle_types vt ON v.type_id = vt.type_id
GROUP BY vt.type_name
ORDER BY total_income DESC;


