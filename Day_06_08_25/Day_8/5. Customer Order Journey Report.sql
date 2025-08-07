CREATE DATABASE CustomerJourney;

USE CustomerJourney;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE OrderStates (
    StateID INT PRIMARY KEY,
    StateName VARCHAR(50),
    ParentStateID INT
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    StateID INT,
    StateTime DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StateID) REFERENCES OrderStates(StateID)
);

INSERT INTO Customers VALUES 
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO OrderStates VALUES
(1, 'Placed', NULL),
(2, 'Processed', 1),
(3, 'Shipped', 2),
(4, 'Delivered', 3),
(5, 'Cancelled', 1);

INSERT INTO Orders VALUES
(1001, 1, 1, '2025-08-01 10:00:00'),
(1002, 1, 2, '2025-08-01 12:00:00'),
(1003, 1, 3, '2025-08-02 09:00:00'),
(1004, 1, 4, '2025-08-03 14:00:00'),
(1005, 2, 1, '2025-08-01 11:00:00'),
(1006, 2, 5, '2025-08-01 13:00:00'),
(1007, 3, 1, '2025-08-02 10:00:00'),
(1008, 3, 2, '2025-08-02 13:00:00'),
(1009, 3, 3, '2025-08-03 11:00:00');

-- track the journey of customers through the order process
SELECT 
  c.CustomerName,
  os.StateName,
  o.StateTime
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderStates os ON o.StateID = os.StateID
ORDER BY c.CustomerName, o.StateTime;

-- use ROW_NUMBER() to order events per customer
SELECT 
  o.CustomerID,
  c.CustomerName,
  os.StateName,
  o.StateTime,
  ROW_NUMBER() OVER (PARTITION BY o.CustomerID ORDER BY o.StateTime) AS StepOrder
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderStates os ON o.StateID = os.StateID;

-- use LAG() to find time between each order stage
SELECT 
  o.CustomerID,
  c.CustomerName,
  os.StateName,
  o.StateTime,
  LAG(o.StateTime) OVER (PARTITION BY o.CustomerID ORDER BY o.StateTime) AS PreviousStateTime,
  DATEDIFF(MINUTE, LAG(o.StateTime) OVER (PARTITION BY o.CustomerID ORDER BY o.StateTime), o.StateTime) AS MinutesBetweenStages
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderStates os ON o.StateID = os.StateID;

-- use WITH RECURSIVE if order states are hierarchical
WITH RECURSIVE StateHierarchy AS (
  SELECT 
    StateID,
    StateName,
    ParentStateID,
    CAST(StateName AS VARCHAR(500)) AS Path
  FROM OrderStates
  WHERE ParentStateID IS NULL

  UNION ALL

  SELECT 
    os.StateID,
    os.StateName,
    os.ParentStateID,
    CAST(sh.Path + ' → ' + os.StateName AS VARCHAR(500))
  FROM OrderStates os
  JOIN StateHierarchy sh ON os.ParentStateID = sh.StateID
)
SELECT * FROM StateHierarchy;

-- use RANK() to find customers with highest frequency
WITH CustomerFrequency AS (
  SELECT 
    CustomerID,
    COUNT(*) AS TotalEvents
  FROM Orders
  GROUP BY CustomerID
)
SELECT 
  cf.CustomerID,
  c.CustomerName,
  cf.TotalEvents,
  RANK() OVER (ORDER BY cf.TotalEvents DESC) AS FrequencyRank
FROM CustomerFrequency cf
JOIN Customers c ON cf.CustomerID = c.CustomerID;
