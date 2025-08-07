CREATE DATABASE UniversityPerformance;
USE UniversityPerformance;

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    department VARCHAR(50),
    batch_year INT
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50)
);

CREATE TABLE exams (
    exam_id INT PRIMARY KEY,
    subject_id INT,
    exam_date DATE,
    semester INT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    exam_id INT,
    raw_score VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id)
);

INSERT INTO students VALUES
(1, 'Alice', 'Female', 'Computer Science', 2021),
(2, 'Bob', 'Male', 'Electronics', 2020),
(3, 'Charlie', 'Male', 'Computer Science', 2021);

INSERT INTO subjects VALUES
(101, 'Data Structures', 'Computer Science'),
(102, 'Digital Circuits', 'Electronics');

INSERT INTO exams VALUES
(201, 101, '2023-06-10', 4),
(202, 102, '2023-06-12', 4);

INSERT INTO grades VALUES
(301, 1, 201, '85'),
(302, 2, 202, 'B'),
(303, 3, 201, 'Fail');

-- Star Schema: fact_scores, dim_student, dim_subject, dim_time
CREATE TABLE dim_student (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    department VARCHAR(50),
    batch_year INT
);

CREATE TABLE dim_subject (
    subject_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50)
);

CREATE TABLE dim_time (
    date_id DATE PRIMARY KEY,
    day INT,
    month INT,
    year INT,
    semester INT
);

CREATE TABLE fact_scores (
    score_id INT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    exam_date DATE,
    normalized_score DECIMAL(5,2),
    pass_status VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES dim_student(student_id),
    FOREIGN KEY (subject_id) REFERENCES dim_subject(subject_id),
    FOREIGN KEY (exam_date) REFERENCES dim_time(date_id)
);

-- ETL transforms inconsistent grading formats
INSERT INTO dim_student
SELECT * FROM students;

INSERT INTO dim_subject
SELECT * FROM subjects;

INSERT INTO dim_time
SELECT 
    e.exam_date,
    DAY(e.exam_date),
    MONTH(e.exam_date),
    YEAR(e.exam_date),
    e.semester
FROM exams e;

INSERT INTO fact_scores
SELECT 
    g.grade_id,
    g.student_id,
    e.subject_id,
    e.exam_date,

    CASE 
        WHEN g.raw_score REGEXP '^[0-9]+$' THEN CAST(g.raw_score AS DECIMAL(5,2))
        WHEN g.raw_score = 'A' THEN 90
        WHEN g.raw_score = 'B' THEN 80
        WHEN g.raw_score = 'C' THEN 70
        WHEN g.raw_score = 'Fail' THEN 0
        ELSE NULL
    END AS normalized_score,

    CASE 
        WHEN g.raw_score = 'Fail' THEN 'Fail'
        WHEN g.raw_score REGEXP '^[0-9]+$' AND CAST(g.raw_score AS UNSIGNED) < 40 THEN 'Fail'
        ELSE 'Pass'
    END AS pass_status

FROM grades g
JOIN exams e ON g.exam_id = e.exam_id;


-- Reports: average score by semester, subject-wise failure rate
SELECT 
    dt.semester,
    AVG(fs.normalized_score) AS avg_score
FROM fact_scores fs
JOIN dim_time dt ON fs.exam_date = dt.date_id
GROUP BY dt.semester;

SELECT 
    ds.name AS subject_name,
    COUNT(CASE WHEN fs.pass_status = 'Fail' THEN 1 END) * 100.0 / COUNT(*) AS failure_rate_percentage
FROM fact_scores fs
JOIN dim_subject ds ON fs.subject_id = ds.subject_id
GROUP BY ds.name;

-- Use OLAP to slice/dice performance by department, batch
SELECT 
    ds.department,
    AVG(fs.normalized_score) AS avg_score
FROM fact_scores fs
JOIN dim_student ds ON fs.student_id = ds.student_id
GROUP BY ds.department;

SELECT 
    ds.batch_year,
    AVG(fs.normalized_score) AS avg_score
FROM fact_scores fs
JOIN dim_student ds ON fs.student_id = ds.student_id
GROUP BY ds.batch_year;
