CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  age INT,
  gender VARCHAR(10)
);

CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  specialization VARCHAR(100),
  available BOOLEAN DEFAULT TRUE
);

CREATE TABLE appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  appointment_date DATETIME,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE billing (
  billing_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  amount DECIMAL(10,2),
  billing_date DATE,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Create a view view_patient_summary to show name, age, latest appointment (hide billing)
CREATE VIEW view_patient_summary AS
SELECT 
  p.name,
  p.age,
  MAX(a.appointment_date) AS latest_appointment
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id;

-- Create a stored procedure add_patient_visit() to insert visit and auto-log
DELIMITER //
CREATE PROCEDURE add_patient_visit(
  IN pat_id INT,
  IN doc_id INT,
  IN appt_date DATETIME
)
BEGIN
  INSERT INTO appointments (patient_id, doctor_id, appointment_date)
  VALUES (pat_id, doc_id, appt_date);

  -- Log entry (you can customize or extend this)
  INSERT INTO billing (patient_id, amount, billing_date)
  VALUES (pat_id, 200.00, CURDATE());  -- fixed amount for simplicity
END;
//
DELIMITER ;

-- Create a function get_doctor_schedule() to retrieve appointments for a doctor
DELIMITER //
CREATE FUNCTION get_doctor_schedule(doc_id INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
  DECLARE result TEXT DEFAULT '';
  DECLARE appt_date DATETIME;
  DECLARE cur CURSOR FOR 
    SELECT appointment_date FROM appointments WHERE doctor_id = doc_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET result = CONCAT(result, ' [End]');
  
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO appt_date;
    IF appt_date IS NULL THEN
      LEAVE read_loop;
    END IF;
    SET result = CONCAT(result, ' | ', appt_date);
  END LOOP;
  CLOSE cur;
  RETURN result;
END;
//
DELIMITER ;

-- Create a trigger after_insert_appointment to update doctor availability
DELIMITER //
CREATE TRIGGER after_insert_appointment
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
  UPDATE doctors
  SET available = FALSE
  WHERE doctor_id = NEW.doctor_id;
END;
//
DELIMITER ;

-- Abstraction - Create a user with restricted access and grant view-only permission
CREATE USER 'hospital_user'@'localhost' IDENTIFIED BY 'securepass';
GRANT SELECT ON view_patient_summary TO 'hospital_user'@'localhost';
-- Do NOT grant access to base tables like patients, appointments, billing
