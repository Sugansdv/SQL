CREATE DATABASE ProductAnalysis;

USE ProductAnalysis;

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100),
    ParentCategoryID INT
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    AvailableFrom DATE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

INSERT INTO Categories VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Laptops', 2),
(4, 'Desktops', 2),
(5, 'Mobiles', 1),
(6, 'Furniture', NULL),
(7, 'Chairs', 6),
(8, 'Tables', 6);

INSERT INTO Products VALUES
(101, 'Dell XPS 13', 3, '2024-01-01'),
(102, 'MacBook Air', 3, '2024-02-01'),
(103, 'iPhone 14', 5, '2024-01-15'),
(104, 'Gaming Desktop', 4, '2024-03-10'),
(105, 'Office Chair', 7, '2024-01-20'),
(106, 'Dining Table', 8, '2024-04-05'),
(107, 'Samsung Galaxy', 5, '2024-03-01'),
(108, 'Mac Mini', 4, '2024-05-01');

-- products belong to categories → subcategories (hierarchical)
SELECT 
  c1.CategoryName AS RootCategory,
  c2.CategoryName AS SubCategory,
  c3.CategoryName AS LeafCategory,
  p.ProductName
FROM Products p
JOIN Categories c3 ON p.CategoryID = c3.CategoryID
LEFT JOIN Categories c2 ON c3.ParentCategoryID = c2.CategoryID
LEFT JOIN Categories c1 ON c2.ParentCategoryID = c1.CategoryID;

-- use WITH RECURSIVE to display full category tree
WITH RECURSIVE CategoryTree AS (
  SELECT 
    CategoryID,
    CategoryName,
    ParentCategoryID,
  CAST(LocationName AS CHAR(500)) AS FullPath
  FROM Categories
  WHERE ParentCategoryID IS NULL

  UNION ALL

  SELECT 
    c.CategoryID,
    c.CategoryName,
    c.ParentCategoryID,
    CAST(ct.FullPath + ' → ' + c.CategoryName AS CHAR(500))
  FROM Categories c
  JOIN CategoryTree ct ON c.ParentCategoryID = ct.CategoryID
)
SELECT * FROM CategoryTree;

-- rank categories by total product count
WITH ProductCounts AS (
  SELECT 
    CategoryID,
    COUNT(*) AS ProductCount
  FROM Products
  GROUP BY CategoryID
)
SELECT 
  c.CategoryName,
  pc.ProductCount,
  RANK() OVER (ORDER BY pc.ProductCount DESC) AS RankByProductCount
FROM ProductCounts pc
JOIN Categories c ON pc.CategoryID = c.CategoryID;

-- use LEAD()/LAG() to track category movement over time
WITH ProductTimeline AS (
  SELECT 
    ProductID,
    ProductName,
    CategoryID,
    AvailableFrom,
    LAG(CategoryID) OVER (PARTITION BY ProductID ORDER BY AvailableFrom) AS PrevCategory,
    LEAD(CategoryID) OVER (PARTITION BY ProductID ORDER BY AvailableFrom) AS NextCategory
  FROM Products
)
SELECT 
  pt.ProductID,
  pt.ProductName,
  c.CategoryName AS CurrentCategory,
  pc.CategoryName AS PrevCategory,
  nc.CategoryName AS NextCategory
FROM ProductTimeline pt
LEFT JOIN Categories c ON pt.CategoryID = c.CategoryID
LEFT JOIN Categories pc ON pt.PrevCategory = pc.CategoryID
LEFT JOIN Categories nc ON pt.NextCategory = nc.CategoryID;

-- use CTEs to create product availability report
WITH AvailableProducts AS (
  SELECT 
    p.ProductName,
    c.CategoryName,
    p.AvailableFrom
  FROM Products p
  JOIN Categories c ON p.CategoryID = c.CategoryID
  WHERE p.AvailableFrom <= CURRENT_DATE
),
UpcomingProducts AS (
  SELECT 
    p.ProductName,
    c.CategoryName,
    p.AvailableFrom
  FROM Products p
  JOIN Categories c ON p.CategoryID = c.CategoryID
  WHERE p.AvailableFrom > CURRENT_DATE
)
SELECT * FROM AvailableProducts;
-- You can separately query UpcomingProducts if needed.
