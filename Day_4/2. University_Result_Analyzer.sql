CREATE DATABASE university_result_analyzer;
USE university_result_analyzer;

-- Tables: students, subjects, results, courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    level VARCHAR(50) 
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    enroll_date DATE,
    course_id INT,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100),
    course_id INT,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE results (
    result_id INT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    exam_type VARCHAR(20), 
    marks INT,
    result_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Insert Data
INSERT INTO courses VALUES
(1, 'BSc Computer Science', 'Undergraduate'),
(2, 'MSc Data Science', 'Postgraduate');

INSERT INTO students VALUES
(1, 'Alice', '2024-08-01', 1),
(2, 'Bob', '2023-06-15', 1),
(3, 'Charlie', '2022-05-20', 2);

INSERT INTO subjects VALUES
(1, 'Mathematics', 1),
(2, 'Programming', 1),
(3, 'Machine Learning', 2);

INSERT INTO results VALUES
(1, 1, 1, 'midterm', 75, '2025-03-01'),
(2, 1, 1, 'final', 80, '2025-06-01'),
(3, 2, 1, 'midterm', 65, '2025-03-01'),
(4, 2, 1, 'final', 70, '2025-06-01'),
(5, 1, 2, 'midterm', 85, '2025-03-02'),
(6, 1, 2, 'final', 90, '2025-06-02'),
(7, 3, 3, 'midterm', 60, '2025-03-05'),
(8, 3, 3, 'final', 70, '2025-06-05');

-- Use subquery in WHERE to get students who scored above class average (final exam)
SELECT s.student_id, s.name, r.marks
FROM students s
JOIN results r ON s.student_id = r.student_id
WHERE r.exam_type = 'final'
  AND r.marks > (
      SELECT AVG(marks)
      FROM results
      WHERE subject_id = r.subject_id AND exam_type = 'final'
  );

-- FROM subquery to calculate average marks per subject
SELECT subject_name, avg_table.avg_marks
FROM (
    SELECT subject_id, AVG(marks) AS avg_marks
    FROM results
    GROUP BY subject_id
) avg_table
JOIN subjects ON avg_table.subject_id = subjects.subject_id;

-- UNION ALL to combine midterm and final results
SELECT student_id, subject_id, exam_type, marks FROM results WHERE exam_type = 'midterm'
UNION ALL
SELECT student_id, subject_id, exam_type, marks FROM results WHERE exam_type = 'final';

-- CASE to grade students based on score ranges
SELECT 
    s.student_id,
    s.name,
    r.subject_id,
    r.marks,
    CASE 
        WHEN r.marks >= 85 THEN 'A'
        WHEN r.marks >= 70 THEN 'B'
        WHEN r.marks >= 50 THEN 'C'
        ELSE 'F'
    END AS grade
FROM students s
JOIN results r ON s.student_id = r.student_id;

-- JOIN students ↔ results ↔ subjects, with GROUP BY on course level
SELECT 
    c.level,
    COUNT(DISTINCT s.student_id) AS total_students,
    AVG(r.marks) AS avg_marks
FROM students s
JOIN courses c ON s.course_id = c.course_id
JOIN results r ON s.student_id = r.student_id
GROUP BY c.level;

-- Use date functions to calculate students enrolled within last year
SELECT * FROM students
WHERE enroll_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
