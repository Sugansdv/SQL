CREATE DATABASE HospitalDB;

USE HospitalDB;

-- Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100)
);

-- Doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    dob DATE
);

-- Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    is_emergency BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Departments
INSERT INTO departments (department_name) VALUES 
('Cardiology'), ('Neurology'), ('Orthopedics');

-- Doctors
INSERT INTO doctors (name, department_id) VALUES
('Dr. Smith', 1),
('Dr. Watson', 2),
('Dr. Roy', 3);

-- Patients
INSERT INTO patients (name, dob) VALUES
('Alice', '1990-01-01'),
('Bob', '1985-02-02'),
('Charlie', '2000-03-03'),
('David', '1992-04-04');  -- No appointment

-- Appointments
INSERT INTO appointments (patient_id, doctor_id, appointment_date, is_emergency) VALUES
(1, 1, '2025-07-01', FALSE),
(2, 2, '2025-07-05', TRUE),
(3, 1, '2025-07-10', FALSE),
(1, 3, '2025-07-12', TRUE);

-- Step 5: Queries

-- Use LEFT JOIN to show all patients, even those with no appointments.
SELECT 
    p.name AS patient_name,
    a.appointment_date,
    d.name AS doctor_name
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN doctors d ON a.doctor_id = d.doctor_id;

-- Filter data using BETWEEN for date range of visits.
SELECT 
    p.name AS patient_name,
    a.appointment_date,
    d.name AS doctor_name
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.appointment_date BETWEEN '2025-07-01' AND '2025-07-10';

-- Aggregate visit counts per department
SELECT 
    dept.department_name,
    COUNT(a.appointment_id) AS total_visits
FROM appointments a
JOIN doctors doc ON a.doctor_id = doc.doctor_id
JOIN departments dept ON doc.department_id = dept.department_id
GROUP BY dept.department_name;

-- FULL OUTER JOIN: All appointments and doctors, even unmatched  
-- UNION of LEFT and RIGHT JOINs.
SELECT 
    a.appointment_id,
    a.appointment_date,
    d.name AS doctor_name
FROM appointments a
LEFT JOIN doctors d ON a.doctor_id = d.doctor_id

UNION

SELECT 
    a.appointment_id,
    a.appointment_date,
    d.name AS doctor_name
FROM appointments a
RIGHT JOIN doctors d ON a.doctor_id = d.doctor_id;

-- Subquery subquery in FROM to summarize daily appointments.
SELECT 
    daily.appointment_date,
    COUNT(daily.appointment_id) AS total_appointments
FROM (
    SELECT appointment_id, appointment_date
    FROM appointments
) AS daily
GROUP BY daily.appointment_date;

-- CASE to flag emergency vs. routine.
SELECT 
    p.name AS patient_name,
    a.appointment_date,
    CASE 
        WHEN a.is_emergency THEN 'Emergency'
        ELSE 'Routine'
    END AS visit_type
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id;

-- Combine regular and emergency visits using UNION.
SELECT 
    p.name AS patient_name,
    a.appointment_date,
    'Routine' AS visit_type
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
WHERE is_emergency = FALSE

UNION

SELECT 
    p.name AS patient_name,
    a.appointment_date,
    'Emergency' AS visit_type
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
WHERE is_emergency = TRUE;
