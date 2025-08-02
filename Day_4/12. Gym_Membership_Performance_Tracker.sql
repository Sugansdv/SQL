CREATE DATABASE IF NOT EXISTS GymDB;
USE GymDB;

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    goal_completion INT,
    join_date DATE,
    membership_expiry DATE
);

CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    member_id INT,
    trainer_id INT,
    session_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    member_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

INSERT INTO members VALUES
(1, 'Alice', 80, '2024-01-15', '2025-08-15'),
(2, 'Bob', 50, '2024-03-01', '2025-08-10'),
(3, 'Charlie', 20, '2024-04-10', '2024-07-30'),
(4, 'Diana', 95, '2023-12-01', '2025-08-25');

INSERT INTO trainers VALUES
(1, 'Jake', 'Weight Loss'),
(2, 'Nina', 'Bodybuilding');

INSERT INTO sessions VALUES
(1, 1, 1, '2025-07-01'),
(2, 1, 1, '2025-07-05'),
(3, 2, 2, '2025-07-02'),
(4, 2, 2, '2025-07-09'),
(5, 3, 1, '2025-07-03'),
(6, 4, 2, '2025-07-01'),
(7, 4, 2, '2025-07-10'),
(8, 4, 2, '2025-07-15');

INSERT INTO payments VALUES
(1, 1, 5000, '2025-06-01'),
(2, 2, 4000, '2025-06-02'),
(3, 3, 3000, '2025-06-03'),
(4, 4, 6000, '2025-06-05');

-- Subquery to calculate average sessions per member. 
SELECT 
    member_id,
    (SELECT COUNT(*) FROM sessions s WHERE s.member_id = m.member_id) AS total_sessions,
    (SELECT COUNT(*)/COUNT(DISTINCT member_id) FROM sessions) AS avg_sessions_per_member
FROM members m;

-- CASE to bucket members by fitness goal completion. 
SELECT 
    name,
    goal_completion,
    CASE 
        WHEN goal_completion >= 80 THEN 'Excellent'
        WHEN goal_completion >= 50 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_category
FROM members;

-- Correlated subquery to find most active member per trainer. 
SELECT 
    s.trainer_id,
    (SELECT m.name 
     FROM members m 
     WHERE m.member_id = s.member_id 
     GROUP BY m.member_id
     ORDER BY COUNT(*) DESC 
     LIMIT 1) AS most_active_member
FROM sessions s
GROUP BY s.trainer_id;

-- Use JOIN + GROUP BY to show session count per trainer. 
SELECT 
    t.name AS trainer_name,
    COUNT(s.session_id) AS total_sessions
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id;

-- UNION ALL for expired and active memberships. 
SELECT name, membership_expiry, 'Active' AS status
FROM members
WHERE membership_expiry >= CURDATE()
UNION ALL
SELECT name, membership_expiry, 'Expired' AS status
FROM members
WHERE membership_expiry < CURDATE();

-- Date filter for memberships expiring this month.
SELECT 
    name, 
    membership_expiry
FROM members
WHERE MONTH(membership_expiry) = MONTH(CURDATE()) 
  AND YEAR(membership_expiry) = YEAR(CURDATE());
