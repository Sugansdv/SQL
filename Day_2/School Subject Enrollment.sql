CREATE DATABASE subj_enroll;

USE subj_enroll;

-- Table: subject_enrollments: enroll_id, student_name, subject, grade, status
CREATE TABLE subject_enrollments (
    enroll_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100),
    subject VARCHAR(50),
    grade INT,
    status VARCHAR(20)
);

INSERT INTO subject_enrollments (student_name, subject, grade, status) VALUES
('Alice Johnson', 'Math', 85, 'Active'),
('Bob Smith', 'English', 90, 'Active'),
('Charlie Lee', 'Science', 75, 'Inactive'),
('Diana Cruz', 'Math', 78, 'Active'),
('Evan Williams', 'English', 88, NULL),
('Fiona Green', 'History', 82, 'Active'),
('George Hall', 'Math', 92, NULL),
('Helen Thomas', 'English', 81, 'Inactive');

-- Filter students with grades >= 80 in Math or English.
SELECT * 
FROM subject_enrollments
WHERE grade >= 80 
  AND subject IN ('Math', 'English');

-- LIKE search on student_name.
SELECT * 
FROM subject_enrollments
WHERE student_name LIKE '%son%';

-- NULL check for status.
SELECT * 
FROM subject_enrollments
WHERE status IS NULL;

-- Use DISTINCT to list all subjects.
SELECT DISTINCT subject 
FROM subject_enrollments;

-- Sort by grade DESC.
SELECT * 
FROM subject_enrollments
ORDER BY grade DESC;
