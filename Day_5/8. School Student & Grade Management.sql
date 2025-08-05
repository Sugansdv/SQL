CREATE DATABASE IF NOT EXISTS school_db;
USE school_db;

-- Create students table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'withdrawn') DEFAULT 'active'
);

-- Create subjects table with NOT NULL on subject_name
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);

-- Create grades table with FK to student and subject, and CHECK (grade BETWEEN 0 AND 100)
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    grade INT CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Insert sample students and subjects
INSERT INTO students (name) VALUES ('Alice'), ('Bob');
INSERT INTO subjects (subject_name) VALUES ('Math'), ('Science');

-- Insert grade with FK to student and subject
INSERT INTO grades (student_id, subject_id, grade)
VALUES (1, 1, 85), (1, 2, 92), (2, 1, 40);

-- Update grade on retest (example: Bob improved Math)
UPDATE grades SET grade = 75
WHERE student_id = 2 AND subject_id = 1;

-- Delete failing grades when student withdraws (grade < 50)
-- Mark student as withdrawn
UPDATE students SET status = 'withdrawn' WHERE student_id = 2;

-- Then delete their failing grades
DELETE FROM grades
WHERE student_id = 2 AND grade < 50;

-- Modify CHECK constraint to expand grade scale (0–150)
-- MySQL requires table recreation or a generated workaround
-- Drop old CHECK and recreate table with updated constraint

ALTER TABLE grades DROP CHECK grade;

ALTER TABLE grades
ADD CONSTRAINT chk_grade_range CHECK (grade BETWEEN 0 AND 150);

-- Transaction: batch insert/update with rollback on failure
DELIMITER //

CREATE PROCEDURE batch_grade_update()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Batch operation failed. Rolled back.' AS message;
    END;

    START TRANSACTION;

    -- Insert or update grades in batch
    INSERT INTO grades (student_id, subject_id, grade)
    VALUES 
        (1, 1, 95), 
        (1, 2, 100)
    ON DUPLICATE KEY UPDATE grade = VALUES(grade);

    -- Simulate error (optional test)
    -- SET @fail := 1 / 0;

    COMMIT;
    SELECT 'Batch operation successful.' AS message;
END;
//

DELIMITER ;

-- Ensure UNIQUE constraint for INSERT ... ON DUPLICATE KEY UPDATE to work
ALTER TABLE grades ADD UNIQUE (student_id, subject_id);

-- Call batch insert/update procedure
CALL batch_grade_update();
