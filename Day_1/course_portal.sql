CREATE DATABASE course_portal;
USE course_portal;

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    expertise VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO instructors (name, expertise) VALUES
('Dr. Alice Smith', 'Data Science'),
('Prof. Bob Johnson', 'Web Development'),
('Dr. Carol Lee', 'Cybersecurity');

INSERT INTO courses (title, instructor_id) VALUES
('Intro to Python', 1),
('Full Stack Web Dev', 2),
('Machine Learning', 1),
('Network Security', 3),
('React & NodeJS', 2);

INSERT INTO students (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Roe', 'jane@example.com'),
('Ethan Hunt', 'ethan@example.com'),
('Mia Wong', 'mia@example.com'),
('Lucas Ray', 'lucas@example.com'),
('Nina Patel', 'nina@example.com'),
('Owen Shaw', 'owen@example.com'),
('Ivy Clark', 'ivy@example.com');

INSERT INTO registrations (student_id, course_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 2),
(6, 4),
(1, 3),
(2, 5);

SELECT c.title AS course, COUNT(r.student_id) AS student_count
FROM courses c
LEFT JOIN registrations r ON c.course_id = r.course_id
GROUP BY c.course_id;

SELECT s.name, s.email
FROM students s
LEFT JOIN registrations r ON s.student_id = r.student_id
WHERE r.registration_id IS NULL;



