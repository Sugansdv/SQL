CREATE DATABASE HealthcareAnalytics;
USE HealthcareAnalytics;

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    birth_date DATE
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    department_id INT,
    appointment_date DATE,
    scheduled_time TIME,
    actual_visit_time TIME,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

INSERT INTO departments VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Pediatrics');

INSERT INTO doctors VALUES
(101, 'Dr. Smith', 'Cardiologist', 1),
(102, 'Dr. Alice', 'Neurologist', 2),
(103, 'Dr. Lee', 'Pediatrician', 3);

INSERT INTO patients VALUES
(201, 'John Doe', 'Male', '1985-05-12'),
(202, 'Jane Roe', 'Female', '1992-11-23'),
(203, 'David Kim', 'Male', '2000-07-19');

INSERT INTO appointments VALUES
(301, 201, 101, 1, '2023-01-10', '09:00:00', '09:20:00'),
(302, 202, 102, 2, '2023-01-10', '10:00:00', '10:45:00'),
(303, 203, 103, 3, '2023-01-11', '11:00:00', '11:05:00'),
(304, 201, 101, 1, '2023-01-12', '08:30:00', '08:50:00');

-- Create a Star Schema with fact_visits, dim_time, dim_doctor, dim_patient
CREATE TABLE dim_time (
    date_id DATE PRIMARY KEY,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(10)
);

CREATE TABLE dim_doctor (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(100),
    department_id INT
);

CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    birth_date DATE
);

CREATE TABLE fact_visits (
    visit_id INT PRIMARY KEY,
    appointment_date DATE,
    doctor_id INT,
    patient_id INT,
    department_id INT,
    scheduled_time TIME,
    actual_visit_time TIME,
    wait_minutes INT,
    FOREIGN KEY (appointment_date) REFERENCES dim_time(date_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctor(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id)
);

-- ETL process to clean records and compute wait times
INSERT INTO dim_time
SELECT DISTINCT 
    appointment_date,
    DAY(appointment_date),
    MONTH(appointment_date),
    YEAR(appointment_date),
    DATENAME(WEEKDAY, appointment_date)
FROM appointments;

INSERT INTO dim_doctor
SELECT 
    doctor_id,
    name,
    specialty,
    department_id
FROM doctors;

INSERT INTO dim_patient
SELECT 
    patient_id,
    name,
    gender,
    birth_date
FROM patients;

INSERT INTO fact_visits
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.doctor_id,
    a.patient_id,
    a.department_id,
    a.scheduled_time,
    a.actual_visit_time,
    DATEDIFF(MINUTE, a.scheduled_time, a.actual_visit_time)
FROM appointments a;

-- OLAP reports: average wait time per doctor, department traffic
SELECT 
    d.name AS doctor_name,
    AVG(fv.wait_minutes) AS avg_wait_time_minutes
FROM fact_visits fv
JOIN dim_doctor d ON fv.doctor_id = d.doctor_id
GROUP BY d.name;

SELECT 
    dep.department_name,
    COUNT(fv.visit_id) AS total_visits
FROM fact_visits fv
JOIN departments dep ON fv.department_id = dep.department_id
GROUP BY dep.department_name;

-- Compare OLAP summaries to granular OLTP logs
SELECT 
    a.appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date,
    a.scheduled_time,
    a.actual_visit_time,
    DATEDIFF(MINUTE, a.scheduled_time, a.actual_visit_time) AS wait_time
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;
