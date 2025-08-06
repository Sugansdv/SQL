
CREATE DATABASE gym_management;
USE gym_management;

-- Members Table
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    join_date DATE
);

-- Trainers Table
CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

-- Plans Table (Normalized)
CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(100),
    duration_months INT,
    fee DECIMAL(10,2)
);

-- Sessions Table (Associates members and trainers)
CREATE TABLE sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    session_date DATE,
    member_id INT,
    trainer_id INT,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

-- Payments Table (Links members with plans)
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    plan_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE INDEX idx_session_date ON sessions(session_date);
CREATE INDEX idx_member_id ON sessions(member_id);
CREATE INDEX idx_trainer_id ON sessions(trainer_id);

INSERT INTO members (name, email, phone, join_date) VALUES 
('Alice', 'alice@example.com', '1234567890', '2023-01-10'),
('Bob', 'bob@example.com', '1234567891', '2023-02-15');

INSERT INTO trainers (name, specialization) VALUES 
('John', 'Weight Training'),
('Emma', 'Yoga');

INSERT INTO plans (plan_name, duration_months, fee) VALUES
('Monthly', 1, 50.00),
('Quarterly', 3, 140.00);

INSERT INTO payments (member_id, plan_id, payment_date, amount_paid) VALUES
(1, 1, '2023-01-10', 50.00),
(2, 2, '2023-02-15', 140.00);

INSERT INTO sessions (session_date, member_id, trainer_id) VALUES
('2023-03-01', 1, 1),
('2023-03-02', 1, 2),
('2023-03-03', 2, 1),
('2023-03-04', 1, 1),
('2023-03-05', 2, 2),
('2023-03-06', 2, 2);

-- Use EXPLAIN to identify slow queries (e.g., trainer performance)
EXPLAIN SELECT trainer_id, COUNT(*) as total_sessions 
FROM sessions 
GROUP BY trainer_id;

-- Subquery to find members with highest attendance
SELECT member_id, COUNT(*) AS attendance_count
FROM sessions
GROUP BY member_id
HAVING attendance_count = (
    SELECT MAX(session_count) FROM (
        SELECT member_id, COUNT(*) AS session_count
        FROM sessions
        GROUP BY member_id
    ) AS temp
);

-- Denormalize: Create trainer-wise session summary table
CREATE TABLE trainer_session_summary AS
SELECT t.trainer_id, t.name AS trainer_name, COUNT(s.session_id) AS total_sessions
FROM trainers t
LEFT JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id, t.name;

-- Use LIMIT to return top 5 most consistent members
SELECT m.member_id, m.name, COUNT(s.session_id) AS session_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id, m.name
ORDER BY session_count DESC
LIMIT 5;
