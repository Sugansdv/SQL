CREATE DATABASE clinic_db;

USE clinic_db;

-- Table: appointments: appointment_id, patient_name, doctor_name, date, status, notes
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(100),
    doctor_name VARCHAR(100),
    date DATE,
    status VARCHAR(20),
    notes TEXT
);

INSERT INTO appointments (patient_name, doctor_name, date, status, notes) VALUES
('Rohit Sharma', 'Dr. Mehta', '2025-07-29', 'Completed', 'Follow-up in 2 weeks'),
('Nikita Thomas', 'Dr. Verma', '2025-07-27', 'Cancelled', NULL),
('Atharv Kulkarni', 'Dr. Iyer', '2025-07-30', 'Scheduled', 'First-time visit'),
('Meghna Pathak', 'Dr. Mehta', '2025-07-25', 'Completed', NULL),
('Ethan Roy', 'Dr. Kapoor', '2025-07-31', 'Scheduled', ''),
('Siddharth Bose', 'Dr. Verma', '2025-07-26', 'Completed', 'Prescribed medicine'),
('Ritika Singh', 'Dr. Iyer', '2025-07-24', 'No Show', NULL);

-- Filter appointments within a given week.
SELECT appointment_id, patient_name, doctor_name, date, status, notes
FROM appointments
WHERE date BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE();

-- Use LIKE to find patients with “th” in name.
SELECT appointment_id, patient_name, doctor_name, date, status
FROM appointments
WHERE patient_name LIKE '%th%';

-- Show doctor_name, date, and status.
SELECT doctor_name, date, status
FROM appointments;

-- NULL check for notes.
SELECT appointment_id, patient_name, doctor_name, date, status
FROM appointments
WHERE notes IS NULL;

-- DISTINCT doctors list.
SELECT DISTINCT doctor_name
FROM appointments;

-- Sort by date DESC.
SELECT appointment_id, patient_name, doctor_name, date, status
FROM appointments
ORDER BY date DESC;
