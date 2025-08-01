CREATE DATABASE online_courses;

USE online_courses;

-- Table: courses: course_id, title, category, duration, price, instructor, status
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    category VARCHAR(50),
    duration INT, -- in hours
    price DECIMAL(10,2),
    instructor VARCHAR(100),
    status VARCHAR(20)
);

-- Sample data
INSERT INTO courses (title, category, duration, price, instructor, status) VALUES
('Data Science Basics', 'Tech', 40, 999.00, 'Dr. Roy', 'active'),
('Business Growth Mastery', 'Business', 25, 899.00, 'Ms. Kapoor', 'active'),
('Data Analysis with Excel', 'Tech', 20, 750.00, NULL, 'active'),
('Creative Writing', 'Arts', 15, 500.00, 'Mr. Mehta', 'inactive'),
('Marketing Strategies', 'Business', 30, 1200.00, 'Mrs. Shah', 'active'),
('Data Engineering', 'Tech', 50, 1100.00, 'Dr. Roy', 'active'),
('Introduction to Python', 'Tech', 35, 950.00, 'Mr. Iyer', 'active');

-- 1. Get courses that are active and under ₹1000
SELECT title, category, price
FROM courses
WHERE status = 'active' AND price < 1000;

-- 2. Use DISTINCT to list all instructors
SELECT DISTINCT instructor
FROM courses;

-- 3. Use LIKE to find courses starting with "Data"
SELECT course_id, title, category
FROM courses
WHERE title LIKE 'Data%';

-- 4. Filter courses by category IN (‘Tech’, ‘Business’)
SELECT course_id, title, category, price
FROM courses
WHERE category IN ('Tech', 'Business');

-- 5. Identify courses with NULL instructor
SELECT course_id, title, category
FROM courses
WHERE instructor IS NULL;

-- 6. Sort by price DESC, duration ASC
SELECT title, category, price, duration
FROM courses
ORDER BY price DESC, duration ASC;
