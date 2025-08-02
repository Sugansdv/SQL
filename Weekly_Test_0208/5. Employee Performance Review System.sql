CREATE DATABASE EmployeeReviewDB;

USE EmployeeReviewDB;

-- departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT,
    department_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- reviews
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    employee_id INT,
    review_date DATE,
    score DECIMAL(5,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO departments VALUES
(1, 'HR'),
(2, 'Engineering'),
(3, 'Sales');

INSERT INTO employees VALUES
(1, 'Alice', NULL, 1),
(2, 'Bob', 1, 1),
(3, 'Charlie', NULL, 2), 
(4, 'David', 3, 2),
(5, 'Eve', 3, 2),
(6, 'Frank', NULL, 3), 
(7, 'Grace', 6, 3);

INSERT INTO reviews VALUES
(1, 2, '2025-01-10', 4.5),
(2, 2, '2025-06-10', 4.7),
(3, 4, '2025-02-01', 3.9),
(4, 5, '2025-07-12', 4.2),
(5, 7, '2025-03-15', 3.0),
(6, 7, '2025-08-01', NULL);

-- Use SELF JOIN to compare employees with their managers
SELECT 
    e.name AS Employee,
    m.name AS Manager
FROM 
    employees e
LEFT JOIN 
    employees m ON e.manager_id = m.employee_id;

-- Use ROW_NUMBER() to order review entries per employee
SELECT 
    employee_id,
    review_date,
    score,
    ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY review_date DESC) AS ReviewOrder
FROM 
    reviews;

-- Aggregate average score per department
SELECT 
    d.name AS Department,
    AVG(r.score) AS AvgScore
FROM 
    reviews r
JOIN 
    employees e ON r.employee_id = e.employee_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    r.score IS NOT NULL
GROUP BY 
    d.name;

-- Use CASE for rating conversion (Excellent/Good/Average)
SELECT 
    e.name AS Employee,
    r.score,
    CASE 
        WHEN r.score >= 4.5 THEN 'Excellent'
        WHEN r.score >= 3.5 THEN 'Good'
        ELSE 'Average'
    END AS Rating
FROM 
    reviews r
JOIN 
    employees e ON r.employee_id = e.employee_id
WHERE 
    r.score IS NOT NULL;

-- Requirement: Use IS NOT NULL to filter completed reviews
SELECT 
    * 
FROM 
    reviews
WHERE 
    score IS NOT NULL;

-- Subquery in SELECT to fetch latest review per employee
SELECT 
    e.name AS Employee,
    (
        SELECT r2.score 
        FROM reviews r2 
        WHERE r2.employee_id = e.employee_id AND r2.score IS NOT NULL
        ORDER BY r2.review_date DESC 
        LIMIT 1
    ) AS LatestReviewScore
FROM 
    employees e;

-- Sort by review score and department
SELECT 
    e.name AS Employee,
    d.name AS Department,
    r.score
FROM 
    reviews r
JOIN 
    employees e ON r.employee_id = e.employee_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    r.score IS NOT NULL
ORDER BY 
    r.score DESC,
    d.name ASC;
