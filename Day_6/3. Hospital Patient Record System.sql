CREATE DATABASE hospital_records;
USE hospital_records;

-- Departments Table
CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL
);

-- Doctors Table
CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  doctor_name VARCHAR(100) NOT NULL,
  department_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Patients Table
CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  dob DATE,
  gender ENUM('M', 'F', 'O'),
  contact_info VARCHAR(100)
);

-- Appointments Table
CREATE TABLE appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  appointment_date DATETIME,
  reason TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Medications Table
CREATE TABLE medications (
  medication_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  medication_name VARCHAR(100),
  dosage VARCHAR(50),
  prescribed_date DATE,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Normalize data to 3NF; separate patient and visit details

-- Index appointment_date, patient_id, and doctor_id

CREATE INDEX idx_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_patient_id ON appointments(patient_id);
CREATE INDEX idx_doctor_id ON appointments(doctor_id);

-- Analyze execution plan for frequent appointment lookups

EXPLAIN SELECT * 
FROM appointments 
WHERE appointment_date BETWEEN '2025-08-01' AND '2025-08-31'
  AND doctor_id = 2;

-- Use subqueries to find patients with the most visits

SELECT 
  patient_id,
  CONCAT(first_name, ' ', last_name) AS patient_name,
  (
    SELECT COUNT(*) 
    FROM appointments 
    WHERE appointments.patient_id = patients.patient_id
  ) AS visit_count
FROM patients
ORDER BY visit_count DESC
LIMIT 1;

-- Create a denormalized view for dashboard analytics

CREATE VIEW dashboard_patient_summary AS
SELECT 
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  COUNT(DISTINCT a.appointment_id) AS total_appointments,
  COUNT(DISTINCT m.medication_id) AS total_medications,
  MAX(a.appointment_date) AS last_appointment
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN medications m ON p.patient_id = m.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name;

-- Add LIMIT to retrieve last 5 appointments for a patient

SELECT 
  a.appointment_id,
  a.appointment_date,
  d.doctor_name,
  a.reason
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.patient_id = 1
ORDER BY a.appointment_date DESC
LIMIT 5;
