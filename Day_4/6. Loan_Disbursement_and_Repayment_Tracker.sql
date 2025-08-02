CREATE DATABASE LoanTracker;
USE LoanTracker;

-- Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE loan_types (
    loan_type_id INT PRIMARY KEY,
    type_name VARCHAR(50)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type_id INT,
    amount DECIMAL(10, 2),
    disbursement_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(loan_type_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    amount_paid DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Insert Sample Data
INSERT INTO customers VALUES
(1, 'John Doe', 'john@example.com'),
(2, 'Jane Smith', 'jane@example.com'),
(3, 'Alice Brown', 'alice@example.com');

INSERT INTO loan_types VALUES
(1, 'Home'),
(2, 'Education'),
(3, 'Auto');

INSERT INTO loans VALUES
(101, 1, 1, 500000, '2024-01-01', 'active'),
(102, 2, 2, 200000, '2023-12-01', 'closed'),
(103, 3, 3, 300000, '2024-06-01', 'active');

INSERT INTO payments VALUES
(1, 101, 100000, '2024-02-01'),
(2, 101, 100000, '2024-04-01'),
(3, 102, 200000, '2024-01-01'),
(4, 103, 50000, '2024-07-01');

-- Subquery in SELECT to calculate outstanding loan balance
SELECT 
    l.loan_id,
    c.name AS customer_name,
    l.amount AS total_loan,
    (l.amount - IFNULL((SELECT SUM(p.amount_paid) FROM payments p WHERE p.loan_id = l.loan_id), 0)) AS outstanding_balance
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id;

-- JOIN + GROUP BY to calculate total repayments per loan type
SELECT 
    lt.type_name,
    SUM(p.amount_paid) AS total_repaid
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id
JOIN loan_types lt ON l.loan_type_id = lt.loan_type_id
GROUP BY lt.type_name;

-- CASE to categorize loans as "Closed", "On Track", "Delayed"
SELECT 
    l.loan_id,
    c.name AS customer,
    l.status,
    CASE 
        WHEN l.status = 'closed' THEN 'Closed'
        WHEN (SELECT MAX(payment_date) FROM payments WHERE loan_id = l.loan_id) < CURDATE() - INTERVAL 60 DAY THEN 'Delayed'
        ELSE 'On Track'
    END AS loan_status
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id;

-- UNION ALL to combine active and closed loans
SELECT loan_id, customer_id, 'Active Loan' AS category
FROM loans WHERE status = 'active'
UNION ALL
SELECT loan_id, customer_id, 'Closed Loan' AS category
FROM loans WHERE status = 'closed';

-- Correlated subquery to find customers whose payments are above their own loan average
SELECT DISTINCT c.customer_id, c.name
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
JOIN payments p ON l.loan_id = p.loan_id
WHERE p.amount_paid > (
    SELECT AVG(p2.amount_paid)
    FROM loans l2
    JOIN payments p2 ON l2.loan_id = p2.loan_id
    WHERE l2.customer_id = c.customer_id
);

-- Use DATEDIFF to calculate delay in payments
SELECT 
    p.payment_id,
    p.loan_id,
    DATEDIFF(p.payment_date, l.disbursement_date) AS days_since_disbursement
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id;
