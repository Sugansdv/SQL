CREATE DATABASE OrgTreeDB;
USE OrgTreeDB;

CREATE TABLE Employees (
  emp_id INT PRIMARY KEY,
  emp_name VARCHAR(100),
  position VARCHAR(100),
  manager_id INT,
  start_date DATE
);

INSERT INTO Employees VALUES 
(1, 'Alice', 'CEO', NULL, '2018-01-01'),
(2, 'Bob', 'Director', 1, '2019-03-15'),
(3, 'Charlie', 'Manager', 2, '2020-06-10'),
(4, 'David', 'Manager', 2, '2020-07-01'),
(5, 'Eva', 'Lead', 3, '2021-01-12'),
(6, 'Frank', 'Lead', 4, '2021-02-20'),
(7, 'Grace', 'Developer', 5, '2022-01-01'),
(8, 'Hank', 'Developer', 6, '2022-03-11'),
(9, 'Ivy', 'Intern', 7, '2023-01-05');

-- WITH RECURSIVE to generate full org chart
WITH RECURSIVE OrgChart AS (
  SELECT 
    emp_id,
    emp_name,
    position,
    manager_id,
    start_date,
    1 AS level,
    CAST(emp_name AS CHAR(1000)) AS path
  FROM Employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT 
    e.emp_id,
    e.emp_name,
    e.position,
    e.manager_id,
    e.start_date,
    oc.level + 1,
    CONCAT(oc.path, ' → ', e.emp_name)
  FROM Employees e
  INNER JOIN OrgChart oc ON e.manager_id = oc.emp_id
)
SELECT * FROM OrgChart;

-- ROW_NUMBER to order direct reports of each manager
SELECT 
  manager_id,
  emp_id,
  emp_name,
  ROW_NUMBER() OVER(PARTITION BY manager_id ORDER BY start_date) AS row_num
FROM Employees
WHERE manager_id IS NOT NULL;

-- RANK managers by number of subordinates
SELECT 
  e.emp_id AS manager_id,
  e.emp_name AS manager_name,
  COUNT(s.emp_id) AS subordinate_count,
  RANK() OVER(ORDER BY COUNT(s.emp_id) DESC) AS rank_by_team_size
FROM Employees e
LEFT JOIN Employees s ON s.manager_id = e.emp_id
GROUP BY e.emp_id, e.emp_name;

-- Compare leadership changes using LAG/LEAD
SELECT 
  emp_id,
  emp_name,
  position,
  start_date,
  LAG(manager_id) OVER(ORDER BY start_date) AS previous_manager,
  LEAD(manager_id) OVER(ORDER BY start_date) AS next_manager
FROM Employees;
