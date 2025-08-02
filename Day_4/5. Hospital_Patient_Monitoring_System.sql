
CREATE DATABASE hospital_monitoring;
USE hospital_monitoring;

-- Create Tables
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    admission_date DATE,
    discharge_date DATE,
    is_inpatient BOOLEAN
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100)
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
    patient_id INT,
    doctor_id INT,
    treatment_type VARCHAR(100),
    cost DECIMAL(10,2),
    treatment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Insert Data
INSERT INTO patients VALUES
(1, 'John Doe', '2025-07-01', '2025-07-10', TRUE),
(2, 'Alice Smith', '2025-07-02', '2025-07-06', TRUE),
(3, 'Bob Johnson', NULL, NULL, FALSE),
(4, 'Sara Lee', '2025-07-05', '2025-07-20', TRUE);

INSERT INTO doctors VALUES
(1, 'Dr. Adams', 'Cardiology'),
(2, 'Dr. Baker', 'Neurology'),
(3, 'Dr. Clark', 'Oncology');

INSERT INTO appointments VALUES
(1, 1, 1, '2025-07-01'),
(2, 2, 1, '2025-07-02'),
(3, 3, 2, '2025-07-03'),
(4, 4, 3, '2025-07-05');

INSERT INTO treatments VALUES
(1, 1, 1, 'ECG', 2000.00, '2025-07-01'),
(2, 1, 1, 'Echo', 1500.00, '2025-07-02'),
(3, 2, 1, 'MRI', 5000.00, '2025-07-02'),
(4, 2, 1, 'Blood Test', 800.00, '2025-07-03'),
(5, 2, 1, 'X-ray', 1000.00, '2025-07-04'),
(6, 3, 2, 'CT Scan', 7000.00, '2025-07-03'),
(7, 4, 3, 'Chemotherapy', 15000.00, '2025-07-06'),
(8, 4, 3, 'Radiation', 10000.00, '2025-07-07');

-- Subquery in FROM to calculate total patients per doctor
SELECT d.name AS doctor_name, p_count.total_patients
FROM doctors d
JOIN (
    SELECT doctor_id, COUNT(DISTINCT patient_id) AS total_patients
    FROM appointments
    GROUP BY doctor_id
) AS p_count ON d.doctor_id = p_count.doctor_id;

-- Subquery in WHERE to get patients treated more than 3 times
SELECT name
FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM treatments
    GROUP BY patient_id
    HAVING COUNT(*) > 3
);

-- CASE to flag "Critical" patients based on treatment count or bill amount
SELECT p.name,
       COUNT(t.treatment_id) AS total_treatments,
       SUM(t.cost) AS total_bill,
       CASE
           WHEN COUNT(t.treatment_id) > 3 OR SUM(t.cost) > 10000 THEN 'Critical'
           ELSE 'Stable'
       END AS patient_status
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
GROUP BY p.patient_id;

-- Correlated subquery to find patient with longest hospital stay per department
SELECT d.department, p.name AS longest_stay_patient,
       DATEDIFF(p.discharge_date, p.admission_date) AS stay_duration
FROM doctors d
JOIN patients p ON d.doctor_id = (
    SELECT doctor_id
    FROM appointments a
    WHERE a.patient_id = p.patient_id
    LIMIT 1
)
WHERE DATEDIFF(p.discharge_date, p.admission_date) = (
    SELECT MAX(DATEDIFF(p2.discharge_date, p2.admission_date))
    FROM patients p2
    JOIN appointments a2 ON p2.patient_id = a2.patient_id
    JOIN doctors d2 ON a2.doctor_id = d2.doctor_id
    WHERE d2.department = d.department
);

-- Date functions to find patients treated in last 30 days
SELECT DISTINCT p.name
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
WHERE t.treatment_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- UNION to combine outpatient and inpatient records
SELECT patient_id, name, 'Inpatient' AS type
FROM patients
WHERE is_inpatient = TRUE
UNION
SELECT patient_id, name, 'Outpatient' AS type
FROM patients
WHERE is_inpatient = FALSE;
