CREATE DATABASE university_registration;
USE university_registration;

-- Departments Table
CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL
);

-- Faculty Table
CREATE TABLE faculty (
  faculty_id INT AUTO_INCREMENT PRIMARY KEY,
  faculty_name VARCHAR(100) NOT NULL,
  department_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Courses Table
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  course_name VARCHAR(100) NOT NULL,
  department_id INT,
  faculty_id INT,
  credits INT,
  FOREIGN KEY (department_id) REFERENCES departments(department_id),
  FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
);

-- Students Table
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  dob DATE,
  email VARCHAR(100)
);

-- Enrollments Table
CREATE TABLE enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  course_id INT,
  grade CHAR(2),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Normalize data: move department and course dependencies to separate tables

-- Index student_id, course_id, faculty_id

CREATE INDEX idx_student_id ON enrollments(student_id);
CREATE INDEX idx_course_id ON enrollments(course_id);
CREATE INDEX idx_faculty_id ON courses(faculty_id);

-- Use EXPLAIN to analyze joins for student performance reports

EXPLAIN
SELECT 
  s.student_id,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  c.course_name,
  e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Optimize queries retrieving students enrolled in more than 3 courses (subquery)

SELECT 
  student_id,
  CONCAT(first_name, ' ', last_name) AS student_name
FROM students
WHERE student_id IN (
  SELECT student_id
  FROM enrollments
  GROUP BY student_id
  HAVING COUNT(course_id) > 3
);

-- Denormalize data into a student performance summary

CREATE VIEW student_performance_summary AS
SELECT 
  s.student_id,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  COUNT(e.course_id) AS total_courses,
  ROUND(AVG(CASE 
      WHEN e.grade = 'A' THEN 4.0
      WHEN e.grade = 'B' THEN 3.0
      WHEN e.grade = 'C' THEN 2.0
      WHEN e.grade = 'D' THEN 1.0
      ELSE 0.0
  END), 2) AS gpa
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name;

-- Use LIMIT for paginated course lists

SELECT 
  course_id,
  course_name,
  credits
FROM courses
ORDER BY course_name
LIMIT 0, 10;

-- To get the next page of 10 courses:
-- LIMIT 10, 10;
