CREATE DATABASE CourseRegistrationDB;

USE CourseRegistrationDB;

-- Table: students
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Table: courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    available_seats INT NOT NULL CHECK (available_seats >= 0)
);

-- Table: enrollments
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade INT CHECK (grade BETWEEN 0 AND 100),  -- CHECK constraint for grade
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Insert students
INSERT INTO students (student_name, email)
VALUES 
('Ravi Kumar', 'ravi@example.com'),
('Anita Mehta', 'anita@example.com'),
('Mohit Das', 'mohit@example.com');

-- Insert courses
INSERT INTO courses (course_name, available_seats)
VALUES 
('SQL Basics', 2),
('Python Programming', 2),
('Data Structures', 1);

-- Enroll students using INSERT INTO with FK checks
INSERT INTO enrollments (student_id, course_id, grade)
VALUES 
(1, 1, 85),
(2, 2, 90);

-- Update course availability based on enrollments
-- reduce available seats after successful enrollment
UPDATE courses
SET available_seats = available_seats - 1
WHERE course_id = 1;

UPDATE courses
SET available_seats = available_seats - 1
WHERE course_id = 2;

-- DELETE student and cascade remove enrollments
-- (Delete student with ID = 2)
DELETE FROM students WHERE student_id = 2;
-- The corresponding enrollment for student_id 2 will be auto-deleted

-- Drop and recreate the CHECK constraint (e.g., new grading out of 10 instead of 100)

-- SDrop CHECK constraint on grade
-- MySQL doesn't support named CHECK constraints before v8.0.16; so recreate table:
ALTER TABLE enrollments DROP CHECK grade;

-- ALTER TABLE enrollments MODIFY grade INT;

-- Add new CHECK constraint: grade between 0 and 10
ALTER TABLE enrollments
ADD CONSTRAINT chk_grade_10 CHECK (grade BETWEEN 0 AND 10);

-- Use transaction for bulk enrollment
START TRANSACTION;

-- SAVEPOINT before enrollments
SAVEPOINT before_bulk_enrollment;

-- Attempt to enroll two students
INSERT INTO enrollments (student_id, course_id, grade)
VALUES 
(3, 1, 9),  -- Valid grade under new scale
(1, 3, 11); -- Invalid grade, will trigger constraint failure

-- If any failure occurs, rollback
-- ROLLBACK TO before_bulk_enrollment;

-- If all goes well
-- COMMIT;
COMMIT;

-- Highlight consistency when partially updating multiple tables

-- Example: Updating both enrollment grade and course seat in a consistent transaction
START TRANSACTION;

UPDATE enrollments
SET grade = 8
WHERE student_id = 3 AND course_id = 1;

UPDATE courses
SET available_seats = available_seats - 1
WHERE course_id = 3;

-- Assume failure occurs here or constraint breaks
-- ROLLBACK;

-- Otherwise, if all successful
-- COMMIT;
