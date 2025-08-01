CREATE DATABASE student;

USE student;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    grade INT,
    attendance DECIMAL(5,2),
    subject VARCHAR(50),
    email VARCHAR(100)
);


INSERT INTO students (name, grade, attendance, subject, email)
VALUES 
('Devi', 85, 95.5, 'Math', 'devi@example.com'),
('Dharun', 78, 88.0, 'Science', 'dharun@example.com'),
('Mani', 92, 91.0, 'English', 'mani@example.com'),
('Manoj', 81, 94.0, 'Science', NULL),
('Santoz', 67, 72.0, 'History', 'santoz@example.com'),
('Sugan', 88, 96.0, 'Math', 'sugan@example.com'),
('Vaishu', 83, 89.0, 'Math', NULL),
('Vishwa', 79, 92.0, 'Math', 'vishwa@example.com');

-- Retrieve students with grades above 80 and attendance > 90%. 
-- Show only names and grades. 
SELECT name, grade
FROM students
WHERE grade > 80 AND attendance > 90;

-- Use DISTINCT to list all subjects offered. 
SELECT DISTINCT subject 
FROM students;

-- Filter students whose name starts with "A". 
SELECT name
FROM students
WHERE name LIKE 'A%';

-- Use IN for specific subjects (Math, Science). 
SELECT name, subject
FROM students
WHERE subject IN ('Math', 'Science');

-- Find students with NULL email addresses. 
SELECT name, email
FROM students
WHERE email IS NULL;

-- Sort results by grade DESC, then name ASC. 
SELECT name, grade
FROM students
ORDER BY grade DESC, name ASC;


DROP DATABASE student;

