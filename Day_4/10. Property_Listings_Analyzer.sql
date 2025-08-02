CREATE DATABASE IF NOT EXISTS real_estate;
USE real_estate;

CREATE TABLE agents (
  agent_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE properties (
  property_id INT PRIMARY KEY,
  name VARCHAR(100),
  type VARCHAR(50),
  city VARCHAR(50),
  listing_date DATE
);

CREATE TABLE clients (
  client_id INT PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE sales (
  sale_id INT PRIMARY KEY,
  property_id INT,
  agent_id INT,
  client_id INT,
  sale_date DATE,
  sale_amount DECIMAL(10,2),
  FOREIGN KEY (property_id) REFERENCES properties(property_id),
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
  FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

INSERT INTO agents VALUES 
(1, 'Alice'), 
(2, 'Bob'), 
(3, 'Charlie');

INSERT INTO properties VALUES 
(101, 'Green Villa', 'House', 'New York', '2024-11-10'),
(102, 'Sunset Office', 'Office', 'Chicago', '2024-12-05'),
(103, 'Ocean Apartment', 'Apartment', 'Los Angeles', '2025-01-20'),
(104, 'Sky Tower', 'Shop', 'Chicago', '2025-02-01');

INSERT INTO clients VALUES 
(201, 'John Doe'),
(202, 'Jane Smith'),
(203, 'Robert Lee');

INSERT INTO sales VALUES 
(301, 101, 1, 201, '2025-02-20', 750000.00),
(302, 102, 2, 202, '2025-03-15', 900000.00),
(303, 103, 1, 203, '2025-04-01', 600000.00);

-- Subquery to fing Agents whose total sales are above company average
SELECT a.agent_id, a.name, SUM(s.sale_amount) AS total_sales
FROM agents a
JOIN sales s ON a.agent_id = s.agent_id
GROUP BY a.agent_id, a.name
HAVING SUM(s.sale_amount) > (
    SELECT AVG(total_agent_sales)
    FROM (
        SELECT agent_id, SUM(sale_amount) AS total_agent_sales
        FROM sales
        GROUP BY agent_id
    ) AS agent_totals
);

-- use CASE to Categorize property types
SELECT p.property_id, p.name,
  CASE 
    WHEN p.type IN ('Apartment', 'House', 'Villa') THEN 'Residential'
    WHEN p.type IN ('Office', 'Shop', 'Warehouse') THEN 'Commercial'
    ELSE 'Other'
  END AS property_category
FROM properties p;

-- UNION ALL for properties sold vs still listed. 
SELECT property_id, 'Sold' AS status
FROM sales
UNION ALL
SELECT property_id, 'Listed' AS status
FROM properties
WHERE property_id NOT IN (SELECT property_id FROM sales);

-- Correlated subquery to find highest sale per agent
SELECT s.sale_id, s.agent_id, s.sale_amount
FROM sales s
WHERE s.sale_amount = (
    SELECT MAX(s2.sale_amount)
    FROM sales s2
    WHERE s2.agent_id = s.agent_id
);

-- JOIN + GROUP BY to show agent sales by city. 
SELECT a.name AS agent_name, p.city, SUM(s.sale_amount) AS total_sales
FROM agents a
JOIN sales s ON a.agent_id = s.agent_id
JOIN properties p ON s.property_id = p.property_id
GROUP BY a.name, p.city;

-- Use DATEDIFF to calculate time between listing and sale.
SELECT p.property_id, p.name, 
       DATEDIFF(s.sale_date, p.listing_date) AS days_on_market
FROM properties p
JOIN sales s ON p.property_id = s.property_id;
