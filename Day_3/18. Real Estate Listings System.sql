-- Create the database
CREATE DATABASE real_estate_db;
USE real_estate_db;

-- Create tables
CREATE TABLE agents (
  agent_id INT PRIMARY KEY,
  name VARCHAR(100),
  area VARCHAR(100)
);

CREATE TABLE properties (
  property_id INT PRIMARY KEY,
  title VARCHAR(100),
  price DECIMAL(10, 2),
  location VARCHAR(100),
  agent_id INT,
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE TABLE clients (
  client_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);

CREATE TABLE inquiries (
  inquiry_id INT PRIMARY KEY,
  client_id INT,
  property_id INT,
  inquiry_date DATE,
  FOREIGN KEY (client_id) REFERENCES clients(client_id),
  FOREIGN KEY (property_id) REFERENCES properties(property_id)
);

-- Insert into agents
INSERT INTO agents VALUES
(1, 'Agent A', 'Downtown'),
(2, 'Agent B', 'Uptown'),
(3, 'Agent C', 'Downtown');

-- Insert into properties
INSERT INTO properties VALUES
(101, 'Modern Apartment', 7500000.00, 'Downtown', 1),
(102, 'Luxury Villa', 12500000.00, 'Uptown', 2),
(103, 'Studio Flat', 5500000.00, 'Downtown', 1),
(104, 'Penthouse Suite', 15500000.00, 'Uptown', 2),
(105, 'Family Home', 9500000.00, 'Downtown', 3);

-- Insert into clients
INSERT INTO clients VALUES
(1, 'Client X', 'x@email.com'),
(2, 'Client Y', 'y@email.com'),
(3, 'Client Z', 'z@email.com');

-- Insert into inquiries
INSERT INTO inquiries VALUES
(201, 1, 101, '2025-07-10'),
(202, 2, 102, '2025-07-11'),
(203, 3, 101, '2025-07-12'),
(204, 1, 103, '2025-07-13'),
(205, 2, 105, '2025-07-14'),
(206, 3, 105, '2025-07-15'),
(207, 2, 104, '2025-07-16');

-- Count properties listed per agent
SELECT a.name, COUNT(p.property_id) AS total_properties
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
GROUP BY a.name;

-- Average property price per location
SELECT location, AVG(price) AS avg_price
FROM properties
GROUP BY location;

-- Agents with more than 2 inquiries (HAVING)
SELECT a.name, COUNT(i.inquiry_id) AS total_inquiries
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
JOIN inquiries i ON p.property_id = i.property_id
GROUP BY a.name
HAVING COUNT(i.inquiry_id) > 2;

-- INNER JOIN: properties ↔ agents ↔ inquiries
SELECT p.title, a.name AS agent_name, i.inquiry_date
FROM properties p
JOIN agents a ON p.agent_id = a.agent_id
JOIN inquiries i ON p.property_id = i.property_id;

-- LEFT JOIN: properties and inquiries (to show properties without inquiries)
SELECT p.title, i.inquiry_id
FROM properties p
LEFT JOIN inquiries i ON p.property_id = i.property_id;

-- SELF JOIN: agents working in the same area
SELECT a1.name AS agent1, a2.name AS agent2, a1.area
FROM agents a1
JOIN agents a2 ON a1.area = a2.area AND a1.agent_id < a2.agent_id;
