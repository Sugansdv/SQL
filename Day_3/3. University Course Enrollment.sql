CREATE DATABASE university_db;

USE university_db;

-- 1. Create Tables

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    teacher_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade DECIMAL(5,2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 2. Insert Sample Data

-- Students
INSERT INTO students (student_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eva');

-- Teachers
INSERT INTO teachers (teacher_id, name) VALUES
(1, 'Dr. Smith'),
(2, 'Prof. Lee');

-- Courses
INSERT INTO courses (course_id, course_name, teacher_id) VALUES
(101, 'Math', 1),
(102, 'Physics', 2),
(103, 'Chemistry', 2);

-- Enrollments
INSERT INTO enrollments (enrollment_id, student_id, course_id, grade) VALUES
(1, 1, 101, 80),
(2, 2, 101, 70),
(3, 3, 102, 90),
(4, 4, 101, 85),
(5, 5, 102, 75),
(6, 1, 102, 88),
(7, 2, 103, 78);

-- 3. Count enrollments per course
SELECT 
    c.course_name,
    COUNT(e.enrollment_id) AS total_enrollments
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- 4. Average grade per course
SELECT 
    c.course_name,
    AVG(e.grade) AS average_grade
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- 5. Courses with avg grade > 75 (HAVING)
SELECT 
    c.course_name,
    AVG(e.grade) AS avg_grade
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name
HAVING AVG(e.grade) > 75;

-- 6. INNER JOIN: students and their course grades
SELECT 
    s.name AS student_name,
    c.course_name,
    e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

-- 7. LEFT JOIN: list courses without enrollments
SELECT 
    c.course_name,
    e.enrollment_id
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- 8. SELF JOIN: students with same course and same grade (peer pairing)
SELECT 
    s1.name AS student_1,
    s2.name AS student_2,
    c.course_name,
    e1.grade
FROM enrollments e1
JOIN enrollments e2 
    ON e1.course_id = e2.course_id 
    AND e1.grade = e2.grade 
    AND e1.student_id < e2.student_id
JOIN students s1 ON e1.student_id = s1.student_id
JOIN students s2 ON e2.student_id = s2.student_id
JOIN courses c ON e1.course_id = c.course_id;
