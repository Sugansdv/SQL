CREATE DATABASE elearning_db;
USE elearning_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(100),
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    user_id INT,
    course_id INT,
    completed BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Instructors
INSERT INTO instructors VALUES
(1, 'Dr. Smith'),
(2, 'Prof. Meena'),
(3, 'John Doe');

-- Courses
INSERT INTO courses VALUES
(101, 'Python Basics', 1),
(102, 'Data Science', 1),
(103, 'Web Development', 2),
(104, 'Digital Marketing', 3),
(105, 'AI for Beginners', 3);

-- Users
INSERT INTO users VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com'),
(4, 'David', 'david@example.com'),
(5, 'Eva', 'eva@example.com');

-- Enrollments
INSERT INTO enrollments VALUES
(1, 1, 101, TRUE),
(2, 2, 101, TRUE),
(3, 3, 101, FALSE),
(4, 4, 102, TRUE),
(5, 1, 102, TRUE),
(6, 2, 102, TRUE),
(7, 5, 103, FALSE),
(8, 3, 103, TRUE),
(9, 4, 104, TRUE),
(10, 5, 105, FALSE),
(11, 1, 105, TRUE),
(12, 2, 105, TRUE),
(13, 3, 105, TRUE),
(14, 4, 105, TRUE),
(15, 5, 101, TRUE),
(16, 2, 104, FALSE);


-- 1. Total enrollments per course
SELECT c.title AS course_title, COUNT(e.enrollment_id) AS total_enrollments
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.title;

-- 2. Average completion rate per instructor
SELECT i.name AS instructor_name,
       ROUND(AVG(CASE WHEN e.completed THEN 1 ELSE 0 END) * 100, 2) AS avg_completion_rate
FROM instructors i
JOIN courses c ON i.instructor_id = c.instructor_id
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY i.name;

-- 3. Courses with more than 20 completions (HAVING)
SELECT c.title, COUNT(*) AS completions
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
WHERE e.completed = TRUE
GROUP BY c.title
HAVING COUNT(*) > 20;

-- 4. INNER JOIN users and courses (via enrollments)
SELECT u.name AS user_name, c.title AS course_title
FROM users u
INNER JOIN enrollments e ON u.user_id = e.user_id
INNER JOIN courses c ON e.course_id = c.course_id;

-- 5. LEFT JOIN to list courses without enrollments
SELECT c.title AS course_title, e.enrollment_id
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- 6. SELF JOIN to compare users who completed the same course
SELECT u1.name AS user1, u2.name AS user2, c.title AS course_title
FROM enrollments e1
JOIN enrollments e2 ON e1.course_id = e2.course_id 
                   AND e1.user_id < e2.user_id 
                   AND e1.completed = TRUE 
                   AND e2.completed = TRUE
JOIN users u1 ON e1.user_id = u1.user_id
JOIN users u2 ON e2.user_id = u2.user_id
JOIN courses c ON e1.course_id = c.course_id;

