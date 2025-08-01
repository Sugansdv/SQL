CREATE DATABASE vehicle_services;

USE vehicle_services;

-- Table: services: service_id, vehicle_no, service_type, cost, service_date, technician
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_no VARCHAR(20),
    service_type VARCHAR(50),
    cost DECIMAL(10,2),
    service_date DATE,
    technician VARCHAR(100)
);

INSERT INTO services (vehicle_no, service_type, cost, service_date, technician) VALUES
('TN01AB1234', 'Oil Change', 1200.00, CURDATE() - INTERVAL 5 DAY, 'Ravi Kumar'),
('TN02CD5679', 'Tire Replacement', 1800.00, CURDATE() - INTERVAL 20 DAY, NULL),
('TN03EF1111', 'Battery Check', 450.00, CURDATE() - INTERVAL 10 DAY, 'Suresh Nair'),
('TN04GH2229', 'Full Service', 2500.00, CURDATE() - INTERVAL 32 DAY, 'Anil Das'),
('TN05IJ3399', 'Brake Inspection', 900.00, CURDATE() - INTERVAL 2 DAY, 'Manoj Sharma'),
('TN06KL4458', 'Oil Change', 1300.00, CURDATE() - INTERVAL 29 DAY, NULL),
('TN07MN5569', 'AC Repair', 1700.00, CURDATE() - INTERVAL 15 DAY, 'Rohit Sen');

-- List all vehicles serviced in the last 30 days.
SELECT service_id, vehicle_no, service_type, cost, service_date, technician
FROM services
WHERE service_date >= CURDATE() - INTERVAL 30 DAY;

-- Show vehicle_no, service_type, and cost.
SELECT vehicle_no, service_type, cost
FROM services;

-- Use LIKE to find vehicles ending with “9”.
SELECT service_id, vehicle_no, service_type, cost, service_date
FROM services
WHERE vehicle_no LIKE '%9';

-- Filter with cost BETWEEN 500 and 2000.
SELECT service_id, vehicle_no, service_type, cost, service_date
FROM services
WHERE cost BETWEEN 500 AND 2000;

-- Identify records with NULL technician.
SELECT service_id, vehicle_no, service_type, cost, service_date
FROM services
WHERE technician IS NULL;

-- Use DISTINCT to list service types.
SELECT DISTINCT service_type
FROM services;

-- Sort by service_date DESC, cost ASC.
SELECT service_id, vehicle_no, service_type, cost, service_date, technician
FROM services
ORDER BY service_date DESC, cost ASC;
