CREATE DATABASE InsuranceDB;
USE InsuranceDB;

CREATE TABLE clients (
  client_id INT PRIMARY KEY,
  name VARCHAR(100),
  dob DATE,
  city VARCHAR(50)
);

CREATE TABLE agents (
  agent_id INT PRIMARY KEY,
  name VARCHAR(100),
  city VARCHAR(50)
);

CREATE TABLE claims (
  claim_id INT PRIMARY KEY,
  client_id INT,
  agent_id INT,
  insurance_type VARCHAR(50),
  claim_amount DECIMAL(10,2),
  claim_date DATE,
  status VARCHAR(20),
  FOREIGN KEY (client_id) REFERENCES clients(client_id),
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  claim_id INT,
  paid_amount DECIMAL(10,2),
  paid_date DATE,
  FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

INSERT INTO clients VALUES 
(1, 'Alice', '1990-05-01', 'Delhi'),
(2, 'Bob', '1985-08-10', 'Mumbai'),
(3, 'Charlie', '1992-02-20', 'Bangalore');

INSERT INTO agents VALUES 
(1, 'Agent Smith', 'Delhi'),
(2, 'Agent Maya', 'Mumbai');

INSERT INTO claims VALUES 
(101, 1, 1, 'Health', 50000, '2025-06-01', 'Approved'),
(102, 2, 2, 'Vehicle', 30000, '2025-06-10', 'Pending'),
(103, 3, 1, 'Health', 80000, '2025-07-15', 'Rejected'),
(104, 1, 2, 'Life', 60000, '2025-08-01', 'Approved');

INSERT INTO payments VALUES 
(1001, 101, 50000, '2025-06-05'),
(1002, 104, 60000, '2025-08-02');

-- Subquery to calculate average claim per insurance type. 
SELECT insurance_type, AVG(claim_amount) AS avg_claim
FROM claims
GROUP BY insurance_type;

-- CASE to show claim status: Approved, Pending, Rejected. 
SELECT claim_id, client_id, claim_amount,
  CASE
    WHEN status = 'Approved' THEN 'Approved'
    WHEN status = 'Pending' THEN 'Pending'
    WHEN status = 'Rejected' THEN 'Rejected'
    ELSE 'Unknown'
  END AS claim_status
FROM claims;

-- UNION ALL for old and new policy claims. 
-- Old = Before 2025-07-01 | New = After
SELECT claim_id, client_id, claim_date, 'Old Policy' AS policy_type
FROM claims
WHERE claim_date < '2025-07-01'

UNION ALL

SELECT claim_id, client_id, claim_date, 'New Policy' AS policy_type
FROM claims
WHERE claim_date >= '2025-07-01';

-- Correlated subquery to get highest claim per client. 
SELECT c.client_id, c.name, cl.claim_id, cl.claim_amount
FROM clients c
JOIN claims cl ON c.client_id = cl.client_id
WHERE cl.claim_amount = (
  SELECT MAX(cl2.claim_amount)
  FROM claims cl2
  WHERE cl2.client_id = c.client_id
);

-- JOIN + GROUP BY to find average claims per agent.
SELECT a.agent_id, a.name, AVG(c.claim_amount) AS avg_claim_per_agent
FROM agents a
JOIN claims c ON a.agent_id = c.agent_id
GROUP BY a.agent_id, a.name;
 
-- Date filtering for claims filed this quarter. 
SELECT claim_date
FROM claims
WHERE claim_date BETWEEN '2025-07-01' AND '2025-09-30';

