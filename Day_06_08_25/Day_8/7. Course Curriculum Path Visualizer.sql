CREATE DATABASE CourseDB;

USE CourseDB;

CREATE TABLE Courses (
  course_id INT PRIMARY KEY,
  course_name VARCHAR(100),
  course_type VARCHAR(20), -- 'required' or 'elective'
  prerequisite_id INT
);

CREATE TABLE Students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100)
);

CREATE TABLE StudentCourses (
  student_id INT,
  course_id INT,
  completion_date DATE,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES Students(student_id),
  FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Courses VALUES
(1, 'Intro to Programming', 'required', NULL),
(2, 'Data Structures', 'required', 1),
(3, 'Algorithms', 'required', 2),
(4, 'Web Development', 'elective', 1),
(5, 'Databases', 'required', 2),
(6, 'Machine Learning', 'elective', 3),
(7, 'AI Fundamentals', 'elective', 6);

INSERT INTO Students VALUES
(101, 'Alice'),
(102, 'Bob');

INSERT INTO StudentCourses VALUES
(101, 1, '2023-01-10'),
(101, 2, '2023-02-12'),
(101, 3, '2023-03-15'),
(101, 6, '2023-04-20'),
(102, 1, '2023-01-15'),
(102, 2, '2023-02-20'),
(102, 5, '2023-03-22');

-- Recursive CTE to list full course paths
WITH RECURSIVE CoursePath AS (
  SELECT course_id, course_name, course_type, prerequisite_id, 1 AS level
  FROM Courses
  WHERE prerequisite_id IS NULL
  UNION ALL
  SELECT c.course_id, c.course_name, c.course_type, c.prerequisite_id, cp.level + 1
  FROM Courses c
  JOIN CoursePath cp ON c.prerequisite_id = cp.course_id
)
SELECT * FROM CoursePath;

-- RANK() to prioritize required vs elective
SELECT 
  course_id, 
  course_name, 
  course_type,
  RANK() OVER (ORDER BY CASE WHEN course_type = 'required' THEN 1 ELSE 2 END) AS priority_rank
FROM Courses;

-- LEAD() to suggest next recommended course based on course path
WITH CourseSequence AS (
  SELECT 
    course_id,
    course_name,
    prerequisite_id
  FROM Courses
)
SELECT 
  c1.course_id,
  c1.course_name,
  LEAD(c2.course_name) OVER (ORDER BY c1.course_id) AS next_course
FROM Courses c1
LEFT JOIN Courses c2 ON c1.course_id = c2.prerequisite_id;

-- CTEs for each student's course progress
WITH StudentProgress AS (
  SELECT 
    sc.student_id,
    s.student_name,
    c.course_name,
    c.course_type,
    sc.completion_date,
    ROW_NUMBER() OVER (PARTITION BY sc.student_id ORDER BY sc.completion_date) AS progress_step
  FROM StudentCourses sc
  JOIN Students s ON sc.student_id = s.student_id
  JOIN Courses c ON sc.course_id = c.course_id
)
SELECT * FROM StudentProgress;
