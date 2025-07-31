CREATE DATABASE exam_db;
USE exam_db;
CREATE TABLE teachers (
  teacher_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  subject VARCHAR(50)
);

CREATE TABLE students (
  student_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  class VARCHAR(20)
);

CREATE TABLE subjects (
  subject_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  teacher_id INT,
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

CREATE TABLE marks (
  mark_id INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT,
  subject_id INT,
  mark INT,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

INSERT INTO teachers (name, subject) VALUES
('Mr. Arun', 'Math'),
('Ms. Priya', 'Science'),
('Mrs. Latha', 'English');

INSERT INTO students (name, class) VALUES
('Ravi Kumar', '10-A'),
('Meena Rani', '10-A'),
('Arjun Das', '10-A');

INSERT INTO subjects (name, teacher_id) VALUES
('Math', 1),
('Science', 2),
('English', 3);

INSERT INTO marks (student_id, subject_id, mark) VALUES
(1, 1, 78), -- Ravi - Math
(1, 2, 88), -- Ravi - Science
(1, 3, 75), -- Ravi - English
(2, 1, 90), -- Meena - Math
(2, 2, 92), -- Meena - Science
(2, 3, 89), -- Meena - English
(3, 1, 80), -- Arjun - Math
(3, 2, 72), -- Arjun - Science
(3, 3, 70); -- Arjun - English

SELECT 
  s.name AS student_name,
  ROUND(AVG(m.mark), 2) AS average_mark
FROM marks m
JOIN students s ON m.student_id = s.student_id
GROUP BY m.student_id;

SELECT 
  s.name AS student_name,
  m.mark,
  RANK() OVER (ORDER BY m.mark DESC) AS `rank`
FROM marks m
JOIN students s ON m.student_id = s.student_id
WHERE m.subject_id = (
  SELECT subject_id FROM subjects WHERE name = 'Math'
);








