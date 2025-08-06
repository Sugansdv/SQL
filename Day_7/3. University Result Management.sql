CREATE DATABASE IF NOT EXISTS UniversityDB;
USE UniversityDB;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(50)
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    credit INT
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    marks INT,
    evaluator VARCHAR(100),
    is_locked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

CREATE TABLE grade_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT,
    old_marks INT,
    new_marks INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students (name, department) VALUES
('Alice', 'Computer Science'),
('Bob', 'Mathematics'),
('Charlie', 'Physics');

INSERT INTO subjects (name, credit) VALUES
('Data Structures', 4),
('Calculus', 3),
('Quantum Mechanics', 4);

INSERT INTO grades (student_id, subject_id, marks, evaluator) VALUES
(1, 1, 85, 'Dr. Smith'),
(1, 2, 90, 'Dr. John'),
(2, 2, 75, 'Dr. John'),
(3, 3, 65, 'Dr. Tesla');

-- View view_student_grades to show subject-wise marks (hiding evaluator info)
CREATE VIEW view_student_grades AS
SELECT g.grade_id, s.name AS student_name, sb.name AS subject_name, g.marks
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sb ON g.subject_id = sb.subject_id;

-- Procedure update_grade() to update a student’s marks with audit log
DELIMITER $$
CREATE PROCEDURE update_grade(IN p_grade_id INT, IN p_new_marks INT)
BEGIN
    DECLARE v_old_marks INT;

    SELECT marks INTO v_old_marks FROM grades WHERE grade_id = p_grade_id;

    INSERT INTO grade_audit (grade_id, old_marks, new_marks)
    VALUES (p_grade_id, v_old_marks, p_new_marks);

    UPDATE grades SET marks = p_new_marks WHERE grade_id = p_grade_id;
END $$
DELIMITER ;

-- Function calculate_gpa(student_id) to return GPA
DELIMITER $$
CREATE FUNCTION calculate_gpa(p_student_id INT) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_points DECIMAL(10,2) DEFAULT 0;
    DECLARE total_credits INT DEFAULT 0;

    SELECT SUM(
        CASE
            WHEN marks >= 90 THEN 10
            WHEN marks >= 80 THEN 9
            WHEN marks >= 70 THEN 8
            WHEN marks >= 60 THEN 7
            WHEN marks >= 50 THEN 6
            ELSE 0
        END * sb.credit
    ),
    SUM(sb.credit)
    INTO total_points, total_credits
    FROM grades g
    JOIN subjects sb ON g.subject_id = sb.subject_id
    WHERE g.student_id = p_student_id;

    IF total_credits = 0 THEN
        RETURN 0;
    END IF;

    RETURN total_points / total_credits;
END $$
DELIMITER ;

-- View view_final_results for students to view only final marks
CREATE VIEW view_final_results AS
SELECT s.student_id, s.name AS student_name, sb.name AS subject_name, g.marks
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sb ON g.subject_id = sb.subject_id;

-- Trigger before_update_grades to prevent update if locked
DELIMITER $$
CREATE TRIGGER before_update_grades
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    IF OLD.is_locked THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Update not allowed: grade is locked.';
    END IF;
END $$
DELIMITER ;
