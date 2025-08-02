CREATE DATABASE UniversityDashboard;

USE UniversityDashboard;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade INT,
    status VARCHAR(20), -- 'enrolled', 'dropped', 'completed'
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO departments VALUES (1, 'Computer Science'), (2, 'Mathematics');

INSERT INTO students VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com');

INSERT INTO courses VALUES
(101, 'Python Programming', 1),
(102, 'SQL Databases', 1),
(103, 'Calculus', 2);

INSERT INTO enrollments VALUES
(1, 1, 101, 85, 'completed'),
(2, 1, 102, 90, 'completed'),
(3, 2, 101, 40, 'completed'),
(4, 2, 103, 60, 'dropped'),
(5, 3, 103, 78, 'completed');

-- GROUP BY to get enrollment count per course.
SELECT
    c.course_name,
    COUNT(e.student_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

--  subquery in FROM to find courses with highest dropout.
SELECT course_name, dropout_count
FROM (
    SELECT
        c.course_name,
        COUNT(*) AS dropout_count
    FROM enrollments e
    JOIN courses c ON e.course_id = c.course_id
    WHERE e.status = 'dropped'
    GROUP BY c.course_name
) AS drop_summary
ORDER BY dropout_count DESC;

-- LEFT JOIN to find students not enrolled in any course
SELECT s.student_id, s.name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;

-- Use CASE for pass/fail grade mapping.
SELECT
    s.name,
    c.course_name,
    e.grade,
    CASE
        WHEN e.grade >= 50 THEN 'Pass'
        ELSE 'Fail'
    END AS result
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE e.status = 'completed';

-- IN for filtering courses by a list of codes.
SELECT *
FROM courses
WHERE course_id IN (101, 102);

-- Use INTERSECT to find students who completed both Python and SQL.
SELECT student_id
FROM enrollments
WHERE course_id = 101 AND status = 'completed'
  AND student_id IN (
      SELECT student_id
      FROM enrollments
      WHERE course_id = 102 AND status = 'completed'
  );

