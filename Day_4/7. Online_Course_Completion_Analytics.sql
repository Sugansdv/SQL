CREATE DATABASE IF NOT EXISTS online_course_analytics;
USE online_course_analytics;

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    batch VARCHAR(50),
    enrollment_date DATE
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE completion (
    completion_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    score INT,
    completion_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Insert values
INSERT INTO courses VALUES
(1, 'SQL'),
(2, 'Python'),
(3, 'Java');

INSERT INTO students VALUES
(101, 'Alice', 'Batch A', '2024-08-01'),
(102, 'Bob', 'Batch B', '2024-09-15'),
(103, 'Charlie', 'Batch A', '2024-08-10'),
(104, 'David', 'Batch B', '2024-10-20');

INSERT INTO enrollments VALUES
(1, 101, 1, '2024-08-05'),
(2, 102, 1, '2024-09-20'),
(3, 101, 2, '2024-08-10'),
(4, 103, 2, '2024-08-12'),
(5, 104, 3, '2024-10-25');

INSERT INTO completion VALUES
(1, 101, 1, 85, '2024-09-01'),
(2, 101, 2, 92, '2024-09-20'),
(3, 102, 1, 78, '2024-10-01'),
(4, 103, 2, 95, '2024-09-30'),
(5, 104, 3, 60, '2024-11-01');

-- Subquery in FROM to get completion rate per course
SELECT 
    c.course_name,
    cr.completed,
    e.total,
    ROUND((cr.completed * 100.0) / e.total, 2) AS completion_rate
FROM 
    (SELECT course_id, COUNT(*) AS total FROM enrollments GROUP BY course_id) AS e
JOIN 
    (SELECT course_id, COUNT(*) AS completed FROM completion GROUP BY course_id) AS cr
ON e.course_id = cr.course_id
JOIN courses c ON c.course_id = e.course_id;

-- INTERSECT to find students who completed both SQL and Python
SELECT student_id
FROM completion
WHERE course_id = 1
  AND student_id IN (
    SELECT student_id FROM completion WHERE course_id = 2
);


-- UNION to list all students from two batches
SELECT name, batch FROM students WHERE batch = 'Batch A'
UNION
SELECT name, batch FROM students WHERE batch = 'Batch B';

-- REQUIREMENT: CASE for grading: A/B/C/F based on score
SELECT 
    s.name,
    c.course_name,
    comp.score,
    CASE 
        WHEN comp.score >= 90 THEN 'A'
        WHEN comp.score >= 75 THEN 'B'
        WHEN comp.score >= 60 THEN 'C'
        ELSE 'F'
    END AS grade
FROM completion comp
JOIN students s ON s.student_id = comp.student_id
JOIN courses c ON c.course_id = comp.course_id;

-- Correlated subquery to find student with highest grade in each course
SELECT 
    s.name,
    c.course_name,
    comp.score
FROM completion comp
JOIN students s ON s.student_id = comp.student_id
JOIN courses c ON c.course_id = comp.course_id
WHERE comp.score = (
    SELECT MAX(c2.score) 
    FROM completion c2 
    WHERE c2.course_id = comp.course_id
);

-- Use DATE functions to show completion trends over months
SELECT 
    DATE_FORMAT(completion_date, '%Y-%m') AS month,
    COUNT(*) AS completions
FROM completion
GROUP BY DATE_FORMAT(completion_date, '%Y-%m')
ORDER BY month;
