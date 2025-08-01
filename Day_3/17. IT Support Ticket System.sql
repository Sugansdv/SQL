CREATE DATABASE it_support;
USE it_support;

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE technicians (
    technician_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    client_id INT,
    technician_id INT,
    issue_type VARCHAR(100),
    created_at DATETIME,
    resolved_at DATETIME,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (technician_id) REFERENCES technicians(technician_id)
);

-- Clients
INSERT INTO clients VALUES
(1, 'Alpha Corp', 'alpha@mail.com'),
(2, 'Beta Ltd', 'beta@mail.com'),
(3, 'Gamma Inc', 'gamma@mail.com');

-- Technicians
INSERT INTO technicians VALUES
(1, 'Raj Verma', 'Networking'),
(2, 'Priya Nair', 'Hardware'),
(3, 'Alok Das', 'Software');

-- Tickets
INSERT INTO tickets VALUES
(1, 1, 1, 'Network Down', '2025-07-01 09:00:00', '2025-07-01 12:00:00'),
(2, 2, 2, 'Hardware Failure', '2025-07-01 10:00:00', '2025-07-02 10:00:00'),
(3, 3, 3, 'Software Bug', '2025-07-01 11:00:00', '2025-07-01 15:00:00'),
(4, 1, 1, 'Network Down', '2025-07-02 09:00:00', '2025-07-02 12:00:00'),
(5, 2, 2, 'Hardware Failure', '2025-07-03 10:00:00', '2025-07-03 13:00:00'),
(6, 3, 3, 'Software Bug', '2025-07-04 11:00:00', '2025-07-04 16:00:00'),
(7, 1, 1, 'Firewall Issue', '2025-07-05 08:00:00', '2025-07-05 09:30:00'),
(8, 2, 2, 'Hardware Failure', '2025-07-06 10:00:00', '2025-07-06 11:30:00'),
(9, 3, 3, 'Software Bug', '2025-07-07 12:00:00', '2025-07-07 14:00:00'),
(10, 1, 1, 'Network Down', '2025-07-08 09:00:00', '2025-07-08 11:00:00'),
(11, 1, 1, 'Router Setup', '2025-07-09 09:00:00', '2025-07-09 10:00:00'),
(12, 2, 1, 'Network Down', '2025-07-10 10:00:00', '2025-07-10 12:00:00');

-- 1. Count of tickets per technician
SELECT t.name AS technician_name, COUNT(k.ticket_id) AS total_tickets
FROM technicians t
JOIN tickets k ON t.technician_id = k.technician_id
GROUP BY t.technician_id, t.name;

-- 2. Average resolution time per technician (in hours)
SELECT t.name AS technician_name, 
       ROUND(AVG(TIMESTAMPDIFF(HOUR, k.created_at, k.resolved_at)), 2) AS avg_resolution_time_hours
FROM technicians t
JOIN tickets k ON t.technician_id = k.technician_id
GROUP BY t.technician_id, t.name;

-- 3. Technicians handling more than 10 tickets
SELECT t.name AS technician_name, COUNT(k.ticket_id) AS total_tickets
FROM technicians t
JOIN tickets k ON t.technician_id = k.technician_id
GROUP BY t.technician_id, t.name
HAVING total_tickets > 10;

-- 4. INNER JOIN tickets ↔ technicians
SELECT k.ticket_id, t.name AS technician_name, k.issue_type, k.created_at
FROM tickets k
INNER JOIN technicians t ON k.technician_id = t.technician_id;

-- 5. LEFT JOIN clients ↔ tickets (includes clients with no tickets)
SELECT c.name AS client_name, k.ticket_id, k.issue_type
FROM clients c
LEFT JOIN tickets k ON c.client_id = k.client_id;

-- 6. SELF JOIN: Tickets with same issue_type
SELECT t1.ticket_id AS ticket1_id, t2.ticket_id AS ticket2_id, t1.issue_type
FROM tickets t1
JOIN tickets t2 ON t1.issue_type = t2.issue_type AND t1.ticket_id < t2.ticket_id;

