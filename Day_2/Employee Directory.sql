CREATE DATABASE employee_directory;

use employee_directory;

CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    email VARCHAR(100),
    hire_date DATE,
    manager_id INT
);

INSERT INTO employees (name, department, salary, email, hire_date, manager_id) VALUES
('Alice Morgan', 'Sales', 60000, 'alice.m@example.com', '2020-04-15', 3),
('Brian Han', 'Marketing', 55000, 'brian.o@example.com', '2021-06-12', 2),
('Catherine Dilan', 'HR', 45000, 'catherine.d@example.com', '2019-08-10', NULL),
('David Nolan', 'Sales', 70000, 'david.n@example.com', '2018-01-03', 3),
('Eva Ryan', 'Finance', 50000, 'eva.r@example.com', '2022-03-19', NULL),
('Frank Allan', 'Marketing', 75000, 'frank.a@example.com', '2017-09-22', 1),
('George Milan', 'IT', 80000, 'george.m@example.com', '2020-12-05', 4),
('Helen Sohan', 'Sales', 30000, 'helen.s@example.com', '2023-01-17', 3);

-- Select employees with salary greater than 50,000 in either Sales or Marketing department
-- Show only the columns: name, salary, and department
SELECT name, salary, department 
FROM employees
WHERE salary > 50000 and department = 'Sales' OR 'Marketing';

-- List all distinct departments from the employees table
SELECT DISTINCT department 
FROM employees;

-- Find employees whose names end with 'an' using the LIKE operator
SELECT name
FROM employees 
WHERE name like '%an';

-- Identify employees who do not have a manager (manager_id is NULL)
SELECT name, manager_id
FROM employees
WHERE manager_id IS NULL;

-- Use BETWEEN for salaries between 40,000 and 80,000.
SELECT name, salary
FROM employees
WHERE salary BETWEEN 40000 AND 80000;

-- Sort by department ASC, salary DESC. 
SELECT name, department, salary
FROM employees
ORDER BY department ASC, salary DESC;




