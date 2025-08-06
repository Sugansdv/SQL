CREATE DATABASE online_learning_platform;

USE online_learning_platform;

CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE
);

CREATE TABLE instructors (
  instructor_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  expertise VARCHAR(100)
);

CREATE TABLE courses (
  course_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100),
  description TEXT,
  instructor_id INT,
  FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE enrollments (
  enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  course_id INT,
  enrollment_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE completions (
  completion_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  course_id INT,
  completion_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');

INSERT INTO instructors (name, expertise) VALUES
('Dr. Smith', 'Data Science'),
('Prof. Jane', 'Web Development');

INSERT INTO courses (title, description, instructor_id) VALUES
('Intro to Python', 'Basics of Python.', 1),
('Full Stack Web', 'Frontend + Backend.', 2);

INSERT INTO enrollments (user_id, course_id, enrollment_date) VALUES
(1, 1, '2025-06-01'),
(1, 2, '2025-07-01'),
(2, 1, '2025-06-10');

INSERT INTO completions (user_id, course_id, completion_date) VALUES
(1, 1, '2025-06-15'),
(1, 2, '2025-07-20'),
(2, 1, '2025-06-25');

-- Create indexes to improve performance
CREATE INDEX idx_course_id ON completions(course_id);
CREATE INDEX idx_user_id ON completions(user_id);
CREATE INDEX idx_completion_date ON completions(completion_date);

-- Use EXPLAIN to analyze completion reports
EXPLAIN
SELECT u.name, c.title, comp.completion_date
FROM completions comp
JOIN users u ON comp.user_id = u.user_id
JOIN courses c ON comp.course_id = c.course_id
WHERE comp.completion_date >= '2025-06-01';

-- Subquery to find users who completed more than 3 courses
SELECT u.user_id, u.name
FROM users u
WHERE (
  SELECT COUNT(*)
  FROM completions c
  WHERE c.user_id = u.user_id
) > 3;

-- Create a denormalized leaderboard table
CREATE TABLE course_leaderboard AS
SELECT
  u.user_id,
  u.name AS user_name,
  c.course_id,
  cr.title AS course_title,
  c.completion_date
FROM completions c
JOIN users u ON c.user_id = u.user_id
JOIN courses cr ON c.course_id = cr.course_id;


-- Show top 5 trending courses based on completion count
SELECT cr.title, COUNT(*) AS completions
FROM completions c
JOIN courses cr ON c.course_id = cr.course_id
GROUP BY c.course_id
ORDER BY completions DESC
LIMIT 5;




