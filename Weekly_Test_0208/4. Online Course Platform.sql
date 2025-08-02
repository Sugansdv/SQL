CREATE DATABASE CoursePlatformDB;

USE CoursePlatformDB;

-- Students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100),
    instructor VARCHAR(100)
);

-- Enrollments table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Grades table
CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT,
    marks INT,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Insert data

-- Students
INSERT INTO students (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com'),
('David', 'david@example.com');

-- Courses
INSERT INTO courses (course_name, instructor) VALUES
('Data Science', 'Dr. Smith'),
('Web Development', 'Prof. John'),
('Cybersecurity', 'Dr. Alice');

-- Enrollments
INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1), (2, 1), (3, 1),
(1, 2), (4, 2),
(2, 3);

-- Grades
INSERT INTO grades (enrollment_id, marks) VALUES
(1, 88), (2, 76), (3, 92), 
(4, 85), (5, 70),      
(6, 90);                  


-- Get list of students using SELECT, filter by course name.
SELECT s.name, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_name = 'Data Science';

--  Use INNER JOIN to show enrolled students with scores.
SELECT s.name AS student_name, c.course_name, g.marks
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
INNER JOIN grades g ON e.enrollment_id = g.enrollment_id;

-- CASE: assign grade categories
SELECT 
    s.name AS student_name,
    c.course_name,
    g.marks,
    CASE 
        WHEN g.marks >= 85 THEN 'A'
        WHEN g.marks >= 70 THEN 'B'
        ELSE 'C'
    END AS grade_category
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id;

--  AVG() to get average marks per course.
SELECT 
    c.course_name,
    AVG(g.marks) AS avg_marks
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN courses c ON e.course_id = c.course_id
GROUP BY c.course_name;

-- GROUP BY + HAVING to show only courses with more than 50 students.
SELECT 
    c.course_name,
    COUNT(e.enrollment_id) AS total_students
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name
HAVING COUNT(e.enrollment_id) > 2;

-- IN to get students enrolled in specific courses.
SELECT s.name, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_name IN ('Data Science', 'Web Development');

-- correlated subquery to get top student in each course.
SELECT 
    c.course_name,
    s.name AS top_student,
    g.marks
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
JOIN students s ON e.student_id = s.student_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
WHERE g.marks = (
    SELECT MAX(g2.marks)
    FROM enrollments e2
    JOIN grades g2 ON e2.enrollment_id = g2.enrollment_id
    WHERE e2.course_id = c.course_id
);
