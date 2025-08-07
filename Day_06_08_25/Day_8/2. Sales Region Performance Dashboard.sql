CREATE DATABASE SalesDashboard;

USE SalesDashboard;

CREATE TABLE Locations (
    LocationID INT PRIMARY KEY,
    LocationName VARCHAR(100),
    ParentLocationID INT
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    LocationID INT,
    SaleAmount DECIMAL(10,2),
    SaleDate DATE,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

INSERT INTO Locations VALUES
(1, 'North Region', NULL),
(2, 'South Region', NULL),
(3, 'California', 1),
(4, 'Texas', 2),
(5, 'Los Angeles', 3),
(6, 'San Francisco', 3),
(7, 'Houston', 4),
(8, 'Dallas', 4);

INSERT INTO Sales VALUES
(101, 5, 10000, '2025-07-01'),
(102, 5, 15000, '2025-07-08'),
(103, 6, 12000, '2025-07-09'),
(104, 7, 17000, '2025-07-03'),
(105, 8, 20000, '2025-07-10'),
(106, 5, 14000, '2025-07-15'),
(107, 6, 16000, '2025-07-16'),
(108, 7, 19000, '2025-07-17'),
(109, 8, 21000, '2025-07-18');

-- show sales by region, state, and city (hierarchical)
SELECT 
  l1.LocationName AS Region,
  l2.LocationName AS State,
  l3.LocationName AS City,
  SUM(s.SaleAmount) AS TotalSales
FROM Sales s
JOIN Locations l3 ON s.LocationID = l3.LocationID
JOIN Locations l2 ON l3.ParentLocationID = l2.LocationID
JOIN Locations l1 ON l2.ParentLocationID = l1.LocationID
GROUP BY l1.LocationName, l2.LocationName, l3.LocationName;

-- use WITH RECURSIVE to expand location hierarchy
WITH LocationTree AS (
  SELECT 
    LocationID,
    LocationName,
    ParentLocationID,
    CAST(LocationName AS CHAR(500)) AS FullPath
  FROM Locations
  WHERE ParentLocationID IS NULL

  UNION ALL

  SELECT 
    l.LocationID,
    l.LocationName,
    l.ParentLocationID,
    CAST(t.FullPath + ' > ' + l.LocationName AS CHAR(500))
  FROM Locations l
  JOIN LocationTree t ON l.ParentLocationID = t.LocationID
)
SELECT * FROM LocationTree;



-- create a weekly and monthly performance CTE
WITH WeeklySales AS (
  SELECT 
    DATEPART(WEEK, SaleDate) AS WeekNumber,
    LocationID,
    SUM(SaleAmount) AS WeeklyRevenue
  FROM Sales
  GROUP BY DATEPART(WEEK, SaleDate), LocationID
),
MonthlySales AS (
  SELECT 
    DATEPART(MONTH, SaleDate) AS MonthNumber,
    LocationID,
    SUM(SaleAmount) AS MonthlyRevenue
  FROM Sales
  GROUP BY DATEPART(MONTH, SaleDate), LocationID
)
SELECT * FROM WeeklySales;
-- You can separately query MonthlySales if needed.

-- use RANK(), DENSE_RANK() to rank regions by sales
WITH RegionSales AS (
  SELECT 
    l1.LocationID,
    l1.LocationName AS Region,
    SUM(s.SaleAmount) AS TotalSales
  FROM Sales s
  JOIN Locations l3 ON s.LocationID = l3.LocationID
  JOIN Locations l2 ON l3.ParentLocationID = l2.LocationID
  JOIN Locations l1 ON l2.ParentLocationID = l1.LocationID
  GROUP BY l1.LocationID, l1.LocationName
)
SELECT 
  Region,
  TotalSales,
  RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank,
  DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS DenseSalesRank
FROM RegionSales;

-- compare current week's revenue with last using LAG()
WITH WeeklyRevenue AS (
  SELECT 
    DATEPART(WEEK, SaleDate) AS WeekNo,
    l1.LocationName AS Region,
    SUM(SaleAmount) AS Revenue
  FROM Sales s
  JOIN Locations l3 ON s.LocationID = l3.LocationID
  JOIN Locations l2 ON l3.ParentLocationID = l2.LocationID
  JOIN Locations l1 ON l2.ParentLocationID = l1.LocationID
  GROUP BY DATEPART(WEEK, SaleDate), l1.LocationName
)
SELECT 
  Region,
  WeekNo,
  Revenue,
  LAG(Revenue) OVER (PARTITION BY Region ORDER BY WeekNo) AS PreviousWeekRevenue,
  Revenue - LAG(Revenue) OVER (PARTITION BY Region ORDER BY WeekNo) AS RevenueChange
FROM WeeklyRevenue;

-- flag top-performing regions using window functions
WITH RegionPerformance AS (
  SELECT 
    l1.LocationName AS Region,
    SUM(SaleAmount) AS TotalRevenue
  FROM Sales s
  JOIN Locations l3 ON s.LocationID = l3.LocationID
  JOIN Locations l2 ON l3.ParentLocationID = l2.LocationID
  JOIN Locations l1 ON l2.ParentLocationID = l1.LocationID
  GROUP BY l1.LocationName
),
RankedRegions AS (
  SELECT *,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RankByRevenue
  FROM RegionPerformance
)
SELECT 
  Region,
  TotalRevenue,
  RankByRevenue,
  CASE WHEN RankByRevenue = 1 THEN 'Top Performer' ELSE 'Normal' END AS PerformanceFlag
FROM RankedRegions;
