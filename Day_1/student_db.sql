CREATE DATABASE school_db;

USE school_db;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    dob DATE
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100),
    course_code VARCHAR(20)
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    subject VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO students (name, email, dob) VALUES
('Arun', 'arun@mail.com', '2005-01-15'),
('Devi', 'devi@mail.com', '2004-12-10'),
('Dharun', 'dharun@mail.com', '2005-03-22'),
('Mani', 'mani@mail.com', '2006-06-30'),
('Manoj', 'manoj@mail.com', '2004-11-02'),
('Santoz', 'santoz@mail.com', '2005-09-19'),
('Sugan', 'sugan@mail.com', '2003-07-12'),
('Vaishu', 'vaish@mail.com', '2006-02-28'),
('Vishwa', 'vishwa@mail.com', '2004-05-25'),
('Vikan', 'vikan@mail.com', '2005-08-17');

INSERT INTO courses (course_name, course_code) VALUES
('Mathematics', 'MATH101'),
('Science', 'SCI102'),
('English', 'ENG103'),
('Computer Science', 'CS104'),
('History', 'HIS105'),
('Geography', 'GEO106'),
('Physics', 'PHY107'),
('Chemistry', 'CHE108'),
('Biology', 'BIO109'),
('Economics', 'ECO110');

INSERT INTO teachers (name, subject, email) VALUES
('Mr. Sharma', 'Mathematics', 'sharma@school.com'),
('Mrs. Rao', 'Science', 'rao@school.com'),
('Ms. Khan', 'English', 'khan@school.com'),
('Mr. Das', 'Computer Science', 'das@school.com'),
('Ms. Verma', 'History', 'verma@school.com'),
('Mr. Roy', 'Geography', 'roy@school.com'),
('Mrs. Iyer', 'Physics', 'iyer@school.com'),
('Mr. Singh', 'Chemistry', 'singh@school.com'),
('Mrs. Paul', 'Biology', 'paul@school.com'),
('Ms. Nair', 'Economics', 'nair@school.com');


INSERT INTO enrollments (student_id, course_id, enrollment_date) VALUES
(1, 1, '2025-06-01'),
(1, 2, '2025-06-02'),
(2, 3, '2025-06-03'),
(3, 1, '2025-06-01'),
(3, 4, '2025-06-04'),
(4, 5, '2025-06-05'),
(5, 6, '2025-06-06'),
(6, 7, '2025-06-07'),
(6, 8, '2025-06-08'),
(7, 2, '2025-06-09'),
(8, 9, '2025-06-10'),
(9, 10, '2025-06-11');

INSERT INTO students (name, email, dob)
VALUES ('Nilan', 'nilan@mail.com', '2005-04-20');

INSERT INTO enrollments (student_id, course_id, enrollment_date)
VALUES (10, 3, '2025-07-01');

UPDATE teachers
SET email = 'updated_email@school.com'
WHERE name = 'Mr. Sharma';

DELETE FROM students
WHERE student_id = 11;

SELECT c.course_name, s.name AS student_name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
ORDER BY c.course_name;

SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

SELECT s.student_id, s.name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

select * from students;
select * from enrollments;

delete from enrollments where student_id = 4;











