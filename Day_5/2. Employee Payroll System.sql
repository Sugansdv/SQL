CREATE DATABASE PayrollDB;

USE PayrollDB;

-- Table: departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL
);

-- Table: employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,  -- email must be unique
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Table: salaries
CREATE TABLE salaries (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL CHECK (base_salary > 10000),
    bonus DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- Insert departments
INSERT INTO departments (department_name)
VALUES 
('HR'), 
('Engineering'), 
('Finance');

-- Insert employees (email must be UNIQUE, department_id is NOT NULL)
INSERT INTO employees (employee_name, email, department_id)
VALUES 
('Anjali Mehta', 'anjali.hr@example.com', 1),
('Raj Verma', 'raj.eng@example.com', 2),
('Meena Rao', 'meena.fin@example.com', 3);

-- Insert salaries
INSERT INTO salaries (employee_id, base_salary, bonus)
VALUES 
(1, 15000.00, 2000.00),
(2, 30000.00, 5000.00),
(3, 22000.00, 3000.00);

-- Update salary records for promotions
UPDATE salaries
SET base_salary = base_salary + 5000
WHERE employee_id = 2;

-- Delete employees who have resigned
DELETE FROM employees
WHERE employee_id = 1;

-- Modify constraint on email length (Assume we want to limit email to 50 chars)
-- First alter to add a constraint
ALTER TABLE employees MODIFY email VARCHAR(50) UNIQUE;

-- Then drop the constraint (Note: some SQL engines require constraint name to drop explicitly)
-- If constraint name known: ALTER TABLE employees DROP INDEX email;
-- For MySQL: drop index
DROP INDEX email ON employees;

-- Use transaction for bulk bonus insert with SAVEPOINT and ROLLBACK

START TRANSACTION;

-- Set savepoint before bonus update
SAVEPOINT before_bonus_update;

-- bulk bonus update
UPDATE salaries SET bonus = bonus + 1000 WHERE base_salary > 20000;

-- Introduce an intentional error (uncomment below line to simulate failure)
-- UPDATE salaries SET bonus = 'invalid' WHERE salary_id = 2;

-- If error occurs, rollback
-- ROLLBACK TO before_bonus_update;

-- If all is good, commit
COMMIT;
