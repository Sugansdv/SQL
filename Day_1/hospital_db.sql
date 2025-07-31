CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    specialization VARCHAR(100),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    dob DATE
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    reason VARCHAR(200),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

INSERT INTO departments (name) VALUES
('Cardiology'),
('Neurology'),
('Pediatrics'),
('Orthopedics'),
('Dermatology');

INSERT INTO doctors (name, department_id, specialization) VALUES
('Dr. Alice', 1, 'Heart Specialist'),
('Dr. Bob', 2, 'Brain Surgeon'),
('Dr. Carol', 3, 'Child Care'),
('Dr. David', 4, 'Bone Specialist'),
('Dr. Eva', 5, 'Skin Specialist'),
('Dr. Frank', 1, 'Cardiologist'),
('Dr. Grace', 2, 'Neuro Physician'),
('Dr. Henry', 3, 'Pediatrician'),
('Dr. Irene', 4, 'Orthopedic Surgeon'),
('Dr. Jack', 5, 'Cosmetic Dermatologist');

INSERT INTO patients (name, gender, dob) VALUES
('John Doe', 'Male', '1990-01-01'),
('Jane Smith', 'Female', '1985-05-12'),
('Mike Ross', 'Male', '1992-07-08'),
('Rachel Green', 'Female', '1989-09-21'),
('Phoebe Buffay', 'Female', '1980-04-30'),
('Ross Geller', 'Male', '1984-10-17'),
('Monica Geller', 'Female', '1983-03-04'),
('Chandler Bing', 'Male', '1982-12-19'),
('Joey Tribbiani', 'Male', '1985-06-11'),
('Lily Evans', 'Female', '1991-11-15'),
('James Potter', 'Male', '1990-09-01'),
('Ginny Weasley', 'Female', '1994-08-02'),
('Harry Potter', 'Male', '1995-07-31'),
('Hermione Granger', 'Female', '1994-09-19'),
('Ron Weasley', 'Male', '1995-03-01');


INSERT INTO appointments (patient_id, doctor_id, appointment_date, reason) VALUES
(1, 1, '2025-08-01', 'Chest pain'),
(2, 2, '2025-08-01', 'Headache'),
(3, 3, '2025-08-02', 'Fever'),
(4, 4, '2025-08-02', 'Back pain'),
(5, 5, '2025-08-03', 'Skin rash'),
(6, 6, '2025-08-03', 'Heart checkup'),
(7, 7, '2025-08-04', 'Migraine'),
(8, 8, '2025-08-04', 'Child fever'),
(9, 9, '2025-08-05', 'Knee pain'),
(10, 10, '2025-08-05', 'Acne treatment'),
(11, 1, '2025-08-06', 'Chest tightness'),
(12, 2, '2025-08-06', 'Dizziness'),
(13, 3, '2025-08-07', 'Cough'),
(14, 4, '2025-08-07', 'Arm fracture'),
(15, 5, '2025-08-08', 'Allergy'),
(1, 6, '2025-08-08', 'Blood pressure'),
(2, 7, '2025-08-09', 'Seizure follow-up'),
(3, 8, '2025-08-09', 'Vaccination'),
(4, 9, '2025-08-10', 'Shoulder pain'),
(5, 10, '2025-08-10', 'Hair fall');

SELECT 
    a.appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date,
    a.reason
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.appointment_date = '2025-08-05';

SELECT d.name AS doctor_name, dept.name AS department
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
WHERE dept.name = 'Cardiology';

SELECT 
    doc.name AS doctor_name,
    COUNT(app.appointment_id) AS total_patients
FROM doctors doc
LEFT JOIN appointments app ON doc.doctor_id = app.doctor_id
GROUP BY doc.doctor_id;






