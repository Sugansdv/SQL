
CREATE DATABASE HospitalDB;

USE HospitalDB;

-- Table: departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL
);

-- Table: doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Table: patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age BETWEEN 0 AND 120),
    gender VARCHAR(10) NOT NULL
);

-- Table: appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    diagnosis TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Insert departments
INSERT INTO departments (department_name)
VALUES 
('Cardiology'),
('Neurology'),
('Pediatrics'),
('Orthopedics');

-- Insert doctors
INSERT INTO doctors (doctor_name, specialization, department_id)
VALUES
('Dr. Smith', 'Cardiologist', 1),
('Dr. Alice', 'Neurologist', 2),
('Dr. John', 'Pediatrician', 3),
('Dr. Mary', 'Orthopedic Surgeon', 4);

-- Insert patients with NOT NULL and CHECK constraint
INSERT INTO patients (patient_name, age, gender)
VALUES
('Rahul Kumar', 35, 'Male'),
('Sita Sharma', 29, 'Female'),
('Ravi Verma', 42, 'Male');

-- Insert appointments (requires existing patient_id and doctor_id)
INSERT INTO appointments (patient_id, doctor_id, appointment_date, diagnosis)
VALUES
(1, 1, '2025-08-05', 'High BP'),
(2, 2, '2025-08-06', 'Migraine'),
(3, 3, '2025-08-07', 'Fever');

-- Update doctor specialization and department ID
UPDATE doctors
SET specialization = 'Interventional Cardiologist', department_id = 1
WHERE doctor_id = 1;

-- Delete a patient and all associated appointments
-- Use SAVEPOINT and ROLLBACK

-- Start transaction
START TRANSACTION;

-- Set a savepoint before deletion
SAVEPOINT before_patient_delete;

-- Delete patient with id = 2 (Sita Sharma) — appointments will be deleted due to ON DELETE CASCADE
DELETE FROM patients WHERE patient_id = 2;

-- If something goes wrong, rollback to savepoint
-- ROLLBACK TO before_patient_delete;

-- Otherwise, commit
COMMIT;

-- Demonstrate atomicity with transaction (update doctor and appointment together)
START TRANSACTION;

-- Update doctor specialization
UPDATE doctors
SET specialization = 'Pediatric Cardiologist'
WHERE doctor_id = 1;

-- Update appointment diagnosis
UPDATE appointments
SET diagnosis = 'Heart murmur detected'
WHERE appointment_id = 1;

-- If both succeed, commit the changes
COMMIT;

-- If there's an issue, rollback everything
-- ROLLBACK;
