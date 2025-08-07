CREATE DATABASE EmployeeTracker;

USE EmployeeTracker;

CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    ManagerID INT
);

CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY,
    EmpID INT,
    RoleTitle VARCHAR(100),
    Salary DECIMAL(10,2),
    PromotionDate DATE,
    FOREIGN KEY (EmpID) REFERENCES Employees(EmpID)
);

INSERT INTO Employees VALUES 
(1, 'Alice', NULL),
(2, 'Bob', 1),
(3, 'Charlie', 1),
(4, 'David', 2),
(5, 'Eva', 2);

INSERT INTO Promotions VALUES 
(101, 1, 'Junior Dev', 50000, '2018-01-01'),
(102, 1, 'Dev', 65000, '2019-06-15'),
(103, 1, 'Senior Dev', 85000, '2021-01-10'),
(104, 2, 'Support Engineer', 40000, '2019-02-20'),
(105, 2, 'DevOps Engineer', 60000, '2020-07-30'),
(106, 3, 'Intern', 30000, '2020-01-01'),
(107, 3, 'Junior Dev', 50000, '2021-09-10'),
(108, 4, 'Intern', 28000, '2021-05-01'),
(109, 5, 'Intern', 29000, '2021-06-01');

-- use ROW_NUMBER() to list promotions chronologically
WITH RankedPromotions AS (
  SELECT 
    EmpID,
    RoleTitle,
    Salary,
    PromotionDate,
    ROW_NUMBER() OVER (PARTITION BY EmpID ORDER BY PromotionDate) AS RowNum
  FROM Promotions
)
SELECT * FROM RankedPromotions;

-- use LEAD() to compare previous and current roles/salaries
WITH LeadData AS (
  SELECT 
    EmpID,
    RoleTitle,
    Salary,
    PromotionDate,
    LEAD(RoleTitle) OVER (PARTITION BY EmpID ORDER BY PromotionDate) AS NextRole,
    LEAD(Salary) OVER (PARTITION BY EmpID ORDER BY PromotionDate) AS NextSalary,
    LEAD(PromotionDate) OVER (PARTITION BY EmpID ORDER BY PromotionDate) AS NextPromotionDate
  FROM Promotions
)
SELECT * FROM LeadData;

-- create a report showing the time between promotions
WITH TimeDiff AS (
  SELECT 
    EmpID,
    RoleTitle,
    PromotionDate,
    LEAD(PromotionDate) OVER (PARTITION BY EmpID ORDER BY PromotionDate) AS NextDate
  FROM Promotions
)
SELECT 
  EmpID,
  RoleTitle,
  DATEDIFF(NextDate, PromotionDate) AS DaysBetweenPromotions
FROM TimeDiff
WHERE NextDate IS NOT NULL;


-- build a recursive hierarchy showing manager → employee chain
WITH EmpHierarchy AS (
  SELECT 
    EmpID,
    EmpName,
    ManagerID,
    CAST(EmpName AS CHAR(500)) AS Chain
  FROM Employees
  WHERE ManagerID IS NULL

  UNION ALL

  SELECT 
    e.EmpID,
    e.EmpName,
    e.ManagerID,
    CAST(h.Chain + ' → ' + e.EmpName AS CHAR(500)) AS Chain  -- 🔧 ALIAS ADDED
  FROM Employees e
  INNER JOIN EmpHierarchy h ON e.ManagerID = h.EmpID
)
SELECT * FROM EmpHierarchy;


-- use RANK() to identify fastest-promoted employees
WITH PromotionDurations AS (
  SELECT 
    EmpID,
    DATEDIFF(DAY, MIN(PromotionDate), MAX(PromotionDate)) AS TotalDays,
    COUNT(*) AS PromotionCount
  FROM Promotions
  GROUP BY EmpID
  HAVING COUNT(*) > 1
),
RankedPromotions AS (
  SELECT *,
    RANK() OVER (ORDER BY TotalDays ASC) AS PromotionRank
  FROM PromotionDurations
)
SELECT * FROM RankedPromotions;

-- use CTEs to modularize query logic
WITH PromoRank AS (
  SELECT 
    EmpID,
    DATEDIFF(DAY, MIN(PromotionDate), MAX(PromotionDate)) AS Duration,
    COUNT(*) AS Promotions
  FROM Promotions
  GROUP BY EmpID
  HAVING COUNT(*) > 1
),
FinalReport AS (
  SELECT 
    p.EmpID,
    e.EmpName,
    p.Promotions,
    p.Duration,
    RANK() OVER (ORDER BY p.Duration) AS FastestPromoRank
  FROM PromoRank p
  JOIN Employees e ON e.EmpID = p.EmpID
)
SELECT * FROM FinalReport;
