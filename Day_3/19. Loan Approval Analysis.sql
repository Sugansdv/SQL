-- Create database
CREATE DATABASE loan_analysis_db;
USE loan_analysis_db;

-- Table: officers
CREATE TABLE officers (
  officer_id INT PRIMARY KEY,
  name VARCHAR(100)
);

-- Table: clients
CREATE TABLE clients (
  client_id INT PRIMARY KEY,
  name VARCHAR(100),
  city VARCHAR(100)
);

-- Table: loans
CREATE TABLE loans (
  loan_id INT PRIMARY KEY,
  client_id INT,
  officer_id INT,
  loan_amount DECIMAL(12, 2),
  approval_date DATE,
  FOREIGN KEY (client_id) REFERENCES clients(client_id),
  FOREIGN KEY (officer_id) REFERENCES officers(officer_id)
);

-- Table: repayments
CREATE TABLE repayments (
  repayment_id INT PRIMARY KEY,
  loan_id INT,
  amount_paid DECIMAL(12, 2),
  payment_date DATE,
  FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Officers
INSERT INTO officers VALUES
(1, 'Officer A'), (2, 'Officer B'), (3, 'Officer C');

-- Clients
INSERT INTO clients VALUES
(101, 'Client X', 'Delhi'),
(102, 'Client Y', 'Mumbai'),
(103, 'Client Z', 'Delhi'),
(104, 'Client W', 'Kolkata');

-- Loans
INSERT INTO loans VALUES
(1001, 101, 1, 500000, '2025-06-01'),
(1002, 102, 2, 300000, '2025-06-03'),
(1003, 103, 1, 400000, '2025-06-05'),
(1004, 104, 3, 700000, '2025-06-07'),
(1005, 102, 2, 350000, '2025-06-10');

-- Repayments
INSERT INTO repayments VALUES
(201, 1001, 250000, '2025-07-01'),
(202, 1002, 150000, '2025-07-02'),
(203, 1003, 300000, '2025-07-05'),
(204, 1004, 400000, '2025-07-07'),
(205, 1005, 100000, '2025-07-10');

-- Total loans issued per officer
SELECT o.name AS officer_name, COUNT(l.loan_id) AS total_loans
FROM officers o
JOIN loans l ON o.officer_id = l.officer_id
GROUP BY o.name;

--  Clients with repayment > ₹1,00,000
SELECT c.name AS client_name, SUM(r.amount_paid) AS total_repaid
FROM clients c
JOIN loans l ON c.client_id = l.client_id
JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY c.name
HAVING SUM(r.amount_paid) > 100000;

-- Officers approving more than 1 loan (adjust threshold as needed)
SELECT o.name AS officer_name, COUNT(l.loan_id) AS loans_approved
FROM officers o
JOIN loans l ON o.officer_id = l.officer_id
GROUP BY o.name
HAVING COUNT(l.loan_id) > 1;

-- INNER JOIN: clients ↔ loans ↔ officers
SELECT c.name AS client, l.loan_amount, o.name AS officer
FROM clients c
JOIN loans l ON c.client_id = l.client_id
JOIN officers o ON l.officer_id = o.officer_id;

-- FULL OUTER JOIN: loans ↔ repayments = UNION of LEFT and RIGHT JOIN:
SELECT l.loan_id, r.repayment_id, l.loan_amount, r.amount_paid
FROM loans l
LEFT JOIN repayments r ON l.loan_id = r.loan_id
UNION
SELECT l.loan_id, r.repayment_id, l.loan_amount, r.amount_paid
FROM loans l
RIGHT JOIN repayments r ON l.loan_id = r.loan_id;

-- SELF JOIN: clients from same city
SELECT c1.name AS client1, c2.name AS client2, c1.city
FROM clients c1
JOIN clients c2 ON c1.city = c2.city AND c1.client_id < c2.client_id;
