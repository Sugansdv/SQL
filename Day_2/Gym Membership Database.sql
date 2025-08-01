CREATE DATABASE gym_db;

USE gym_db;

-- Table: members: member_id, name, age, plan_type, start_date, status
CREATE TABLE member (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    plan_type VARCHAR(50),
    start_date DATE,
    status VARCHAR(20)
);

INSERT INTO member (name, age, plan_type, start_date, status) VALUES
('Sonia Mehta', 25, 'Premium', '2025-07-15', 'Active'),
('Raj Kumar', 34, 'Standard', '2025-06-20', 'Inactive'),
('Suresh Nair', 29, 'Basic', '2025-07-10', 'Active'),
('Anita Rao', 42, 'Premium', '2025-05-25', 'Active'),
('Sneha Singh', 22, 'Standard', '2025-07-01', NULL),
('David Joseph', 38, 'Basic', '2025-07-18', 'Active'),
('Sara Khan', 27, 'Premium', '2025-07-22', 'Active');

-- Retrieve active members aged between 20 and 40.
SELECT member_id, name, age, plan_type, start_date
FROM member
WHERE status = 'Active'
  AND age BETWEEN 20 AND 40;

-- Select name, age, plan_type.
SELECT name, age, plan_type
FROM member;

-- Use DISTINCT to list all plan types.
SELECT DISTINCT plan_type
FROM member;

-- Use LIKE to find names starting with "S".
SELECT member_id, name, age, plan_type, start_date, status
FROM member
WHERE name LIKE 'S%';

-- Check members with NULL status.
SELECT member_id, name, age, plan_type, start_date
FROM member
WHERE status IS NULL;

-- Sort by age ASC, name ASC.
SELECT member_id, name, age, plan_type, start_date, status
FROM member
ORDER BY age ASC, name ASC;
