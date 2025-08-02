CREATE DATABASE employee_db;

USE employee_db;

SELECT * FROM employees limit 5 offset 2;

-- Create departments table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

-- Create employees table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2),
    dept_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

-- Insert sample departments
INSERT INTO departments (dept_id, dept_name) VALUES
(1, 'HR'),
(2, 'Engineering'),
(3, 'Sales'),
(4, 'Marketing');

-- Insert sample employees
INSERT INTO employees (emp_id, name, salary, dept_id, manager_id) VALUES
(101, 'Alice', 70000, 2, NULL),
(102, 'Bob', 50000, 2, 101),
(103, 'Carol', 45000, 1, NULL),
(104, 'David', 60000, 2, 101),
(105, 'Eve', 48000, 1, 103),
(106, 'Frank', 40000, 3, NULL),
(107, 'Grace', 42000, 3, 106),
(108, 'Heidi', 43000, 3, 106),
(109, 'Ivan', 41000, 3, 106),
(110, 'Jack', 39000, 3, 106),
(111, 'Karen', 39500, 3, 106);

-- 1. Show average salary per department
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- 2. Count employees per department
SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- 3. Find departments with more than 5 employees
SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING COUNT(e.emp_id) > 5;

-- 4. INNER JOIN to show employees and their department names
SELECT e.name AS employee_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- 5. LEFT JOIN to find departments without employees
SELECT d.dept_name, e.name AS employee_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL or e.emp_id = '';

-- 6. SELF JOIN to show each employee with their manager name
SELECT 
  e1.name AS employee_name,
  e2.name AS manager_name
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id;
