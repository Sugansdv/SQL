CREATE DATABASE company_hr;
USE company_hr;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    date DATE NOT NULL,
    in_time TIME,
    out_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO departments (name) VALUES
('HR'),
('IT'),
('Finance'),
('Marketing'),
('Operations');

INSERT INTO employees (name, email, department_id) VALUES
('Alice Johnson', 'alice@company.com', 1),
('Bob Smith', 'bob@company.com', 2),
('Charlie Brown', 'charlie@company.com', 2),
('Daisy Adams', 'daisy@company.com', 3),
('Ethan Clark', 'ethan@company.com', 3),
('Fiona Davis', 'fiona@company.com', 4),
('George Evans', 'george@company.com', 4),
('Hannah Ford', 'hannah@company.com', 5),
('Ian Green', 'ian@company.com', 5),
('Julia Hall', 'julia@company.com', 1),
('Kevin Miles', 'kevin@company.com', 2),
('Laura North', 'laura@company.com', 3),
('Mike Owen', 'mike@company.com', 4),
('Nina Patel', 'nina@company.com', 5),
('Oscar Queen', 'oscar@company.com', 1);

-- insert 2 days of records for 15 employees
INSERT INTO attendance (employee_id, date, in_time, out_time) VALUES
(1, '2025-07-28', '09:00:00', '17:00:00'),
(2, '2025-07-28', '09:15:00', '17:10:00'),
(3, '2025-07-28', NULL, NULL), -- Absent
(4, '2025-07-28', '08:55:00', '16:45:00'),
(5, '2025-07-28', '09:05:00', '17:00:00'),
(6, '2025-07-28', '09:30:00', '17:30:00'),
(7, '2025-07-28', NULL, NULL), -- Absent
(8, '2025-07-28', '09:00:00', '16:55:00'),
(9, '2025-07-28', '08:45:00', '17:10:00'),
(10, '2025-07-28', '09:00:00', '17:00:00'),
(11, '2025-07-28', '09:10:00', '16:50:00'),
(12, '2025-07-28', '09:05:00', '17:05:00'),
(13, '2025-07-28', NULL, NULL), -- Absent
(14, '2025-07-28', '09:20:00', '17:25:00'),
(15, '2025-07-28', '09:00:00', '17:00:00'),

(1, '2025-07-29', '09:00:00', '17:00:00'),
(2, '2025-07-29', '09:10:00', '17:00:00'),
(3, '2025-07-29', '09:00:00', '17:00:00'),
(4, '2025-07-29', '08:50:00', '16:50:00'),
(5, '2025-07-29', '09:05:00', '17:10:00'),
(6, '2025-07-29', NULL, NULL), -- Absent
(7, '2025-07-29', '09:00:00', '17:00:00'),
(8, '2025-07-29', '09:10:00', '16:55:00'),
(9, '2025-07-29', NULL, NULL), -- Absent
(10, '2025-07-29', '09:00:00', '17:05:00'),
(11, '2025-07-29', '09:00:00', '17:00:00'),
(12, '2025-07-29', '09:15:00', '17:20:00'),
(13, '2025-07-29', '09:05:00', '17:00:00'),
(14, '2025-07-29', '09:10:00', '17:15:00'),
(15, '2025-07-29', '09:00:00', '17:00:00');

SELECT 
    a.employee_id,
    e.name,
    a.date,
    TIMEDIFF(a.out_time, a.in_time) AS working_hours
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id
WHERE a.in_time IS NOT NULL AND a.out_time IS NOT NULL;

SELECT 
    e.employee_id,
    e.name,
    COUNT(CASE WHEN a.in_time IS NOT NULL THEN 1 END) AS present_days,
    COUNT(CASE WHEN a.in_time IS NULL THEN 1 END) AS absent_days
FROM employees e
LEFT JOIN attendance a ON e.employee_id = a.employee_id
GROUP BY e.employee_id;
