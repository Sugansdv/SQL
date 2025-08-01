CREATE DATABASE hospital_db;

USE hospital_db;

-- 1. Create Tables

CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    birth_date DATE
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE treatments (
    treatment_id INT PRIMARY KEY,
    appointment_id INT,
    cost DECIMAL(10,2),
    description VARCHAR(255),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- 2. Insert Sample Data

-- Patients
INSERT INTO patients (patient_id, name, birth_date) VALUES
(1, 'Alice', '1990-01-10'),
(2, 'Bob', '1985-03-15'),
(3, 'Charlie', '1990-01-10'),
(4, 'David', '1992-08-25'),
(5, 'Eva', '1989-12-05');

-- Doctors
INSERT INTO doctors (doctor_id, name, specialty) VALUES
(1, 'Dr. Smith', 'Cardiology'),
(2, 'Dr. Lee', 'Dermatology'),
(3, 'Dr. Kumar', 'Neurology');

-- Appointments
INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date) VALUES
(1, 1, 1, '2023-06-01'),
(2, 2, 1, '2023-06-03'),
(3, 3, 2, '2023-06-05'),
(4, 4, 1, '2023-06-07'),
(5, 5, 2, '2023-06-08'),
(6, 1, 2, '2023-06-10'),
(7, 2, 1, '2023-06-12');

-- Treatments
INSERT INTO treatments (treatment_id, appointment_id, cost, description) VALUES
(1, 1, 1200.00, 'ECG'),
(2, 2, 1500.00, 'Echo'),
(3, 3, 800.00, 'Skin check'),
(4, 4, 2000.00, 'Angiogram'),
(5, 5, 1000.00, 'Allergy test'),
(6, 6, 950.00, 'Skin biopsy'),
(7, 7, 1800.00, 'Stress test');

-- 3. Total patients treated per doctor
SELECT 
    d.name AS doctor_name,
    COUNT(DISTINCT a.patient_id) AS total_patients
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.name;

-- 4. Average treatment cost per doctor
SELECT 
    d.name AS doctor_name,
    AVG(t.cost) AS avg_treatment_cost
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY d.name;

-- 5. Doctors who treated more than 10 patients (HAVING)
SELECT 
    d.name AS doctor_name,
    COUNT(DISTINCT a.patient_id) AS patients_treated
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.name
HAVING COUNT(DISTINCT a.patient_id) > 10;

-- 6. INNER JOIN: Appointments + Doctors
SELECT 
    a.appointment_id,
    a.appointment_date,
    p.name AS patient_name,
    d.name AS doctor_name
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

-- 7. RIGHT JOIN: All doctors, including those with no appointments
SELECT 
    d.name AS doctor_name,
    a.appointment_id
FROM appointments a
RIGHT JOIN doctors d ON a.doctor_id = d.doctor_id;

-- 8. SELF JOIN on patients with same birth date
SELECT 
    p1.name AS patient_1,
    p2.name AS patient_2,
    p1.birth_date
FROM patients p1
JOIN patients p2 
  ON p1.birth_date = p2.birth_date 
  AND p1.patient_id < p2.patient_id;
