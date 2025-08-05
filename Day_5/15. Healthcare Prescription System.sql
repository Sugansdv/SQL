DROP DATABASE IF EXISTS healthcare_db;
CREATE DATABASE healthcare_db;
USE healthcare_db;

-- Create doctors table
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);

-- Create patients table
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT
);

-- Step 4: Create medications table
CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    stock INT NOT NULL
);

-- Create prescriptions table with constraints
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT,
    patient_id INT,
    medication_id INT,
    dosage INT,
    prescribed_on DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (medication_id) REFERENCES medications(medication_id),
    CHECK (dosage >= 1 AND dosage <= 5)
);

-- Insert sample data into doctors
INSERT INTO doctors (name, specialization)
VALUES 
('Dr. Smith', 'Cardiology'),
('Dr. Alice', 'Neurology');

-- Insert sample data into patients
INSERT INTO patients (name, age)
VALUES 
('John Doe', 45),
('Jane Roe', 30);

-- Step 8: Insert sample data into medications
INSERT INTO medications (name, stock)
VALUES 
('Aspirin', 100),
('Paracetamol', 200);

-- Begin transaction for prescription + stock update
START TRANSACTION;

-- Insert prescription (example)
INSERT INTO prescriptions (doctor_id, patient_id, medication_id, dosage)
VALUES (1, 1, 1, 2);

-- Update medication stock
UPDATE medications SET stock = stock - 2
WHERE medication_id = 1;

-- Commit transaction
COMMIT;

-- Delete prescriptions older than 6 months
DELETE FROM prescriptions
WHERE prescribed_on < CURDATE() - INTERVAL 6 MONTH;

-- Modify medication_id to be optional (drop NOT NULL)
ALTER TABLE prescriptions MODIFY medication_id INT NULL;

-- (Optional) Re-add NOT NULL if needed
-- ALTER TABLE prescriptions MODIFY medication_id INT NOT NULL;
