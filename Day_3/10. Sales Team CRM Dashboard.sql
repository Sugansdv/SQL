CREATE DATABASE sales_crm;
USE sales_crm;

CREATE TABLE sales_reps (
    rep_id INT PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE leads (
    lead_id INT PRIMARY KEY,
    rep_id INT,
    client_name VARCHAR(100),
    status VARCHAR(20), -- 'open', 'won', 'lost'
    created_at DATE,
    converted_at DATE,
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    name VARCHAR(100),
    rep_id INT,
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id)
);

CREATE TABLE meetings (
    meeting_id INT PRIMARY KEY,
    client_id INT,
    rep_id INT,
    meeting_date DATE,
    notes TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id)
);

-- Sales Representatives
INSERT INTO sales_reps VALUES
(1, 'Alice', 'North'),
(2, 'Bob', 'North'),
(3, 'Carol', 'South'),
(4, 'David', 'South'),
(5, 'Eve', 'East');

-- Leads
INSERT INTO leads VALUES
(1, 1, 'Client A', 'won', '2025-01-01', '2025-01-05'),
(2, 1, 'Client B', 'lost', '2025-01-02', NULL),
(3, 2, 'Client C', 'won', '2025-01-03', '2025-01-07'),
(4, 2, 'Client D', 'won', '2025-01-04', '2025-01-06'),
(5, 3, 'Client E', 'open', '2025-01-05', NULL),
(6, 4, 'Client F', 'won', '2025-01-06', '2025-01-10'),
(7, 4, 'Client G', 'won', '2025-01-07', '2025-01-09'),
(8, 4, 'Client H', 'won', '2025-01-08', '2025-01-11'),
(9, 4, 'Client I', 'won', '2025-01-09', '2025-01-13'),
(10, 4, 'Client J', 'won', '2025-01-10', '2025-01-14'),
(11, 4, 'Client K', 'won', '2025-01-11', '2025-01-15');

-- Clients
INSERT INTO clients VALUES
(101, 'Client A', 1),
(102, 'Client C', 2),
(103, 'Client D', 2),
(104, 'Client F', 4),
(105, 'Client G', 4),
(106, 'Client H', 4);

-- Meetings
INSERT INTO meetings VALUES
(1, 101, 1, '2025-01-03', 'Initial discussion'),
(2, 102, 2, '2025-01-04', 'Negotiation'),
(3, 104, 4, '2025-01-08', 'Proposal'),
(4, 105, 4, '2025-01-09', 'Demo'),
(5, 106, 4, '2025-01-10', 'Follow-up');

-- 1. Count leads per sales rep
SELECT sr.name AS rep_name, COUNT(l.lead_id) AS total_leads
FROM sales_reps sr
LEFT JOIN leads l ON sr.rep_id = l.rep_id
GROUP BY sr.name;

-- 2. Average conversion time (in days)
SELECT ROUND(AVG(DATEDIFF(l.converted_at, l.created_at)), 2) AS avg_conversion_days
FROM leads l
WHERE l.status = 'won';

-- 3. Reps who closed more than 5 deals (HAVING)
SELECT sr.name AS rep_name, COUNT(l.lead_id) AS deals_closed
FROM sales_reps sr
JOIN leads l ON sr.rep_id = l.rep_id
WHERE l.status = 'won'
GROUP BY sr.name
HAVING COUNT(l.lead_id) > 5;

-- 4. INNER JOIN reps and leads
SELECT sr.name AS rep_name, l.client_name, l.status
FROM sales_reps sr
INNER JOIN leads l ON sr.rep_id = l.rep_id;

-- 5. RIGHT JOIN: reps and clients
SELECT c.name AS client_name, sr.name AS rep_name
FROM clients c
RIGHT JOIN sales_reps sr ON c.rep_id = sr.rep_id;

-- 6. SELF JOIN to compare reps from the same region
SELECT r1.name AS rep1, r2.name AS rep2, r1.region
FROM sales_reps r1
JOIN sales_reps r2 ON r1.region = r2.region AND r1.rep_id < r2.rep_id;

