CREATE DATABASE loan_tracker;

USE loan_tracker;

-- Table: loans: loan_id, applicant_name, amount, loan_type, status, approval_date
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    applicant_name VARCHAR(100),
    amount DECIMAL(12, 2),
    loan_type VARCHAR(50),
    status VARCHAR(20),
    approval_date DATE
);

INSERT INTO loans (applicant_name, amount, loan_type, status, approval_date) VALUES
('Arjun Mehta', 75000, 'Home', 'Approved', '2025-07-10'),
('Bhavna Rao', 125000, 'Education', 'Pending', NULL),
('Chirag Verma', 300000, 'Business', 'Rejected', '2025-07-15'),
('Deepa Singh', 200000, 'Home', 'Approved', '2025-07-20'),
('Eshan Patel', 45000, 'Education', 'Pending', NULL),
('Farah Ali', 160000, 'Education', 'Approved', '2025-07-25'),
('Gautam Roy', 50000, 'Personal', 'Approved', NULL);

-- Filter loans where amount BETWEEN 50k and 2L.
SELECT loan_id, applicant_name, amount, loan_type, status, approval_date
FROM loans
WHERE amount BETWEEN 50000 AND 200000;

-- Use IN for loan types (Home, Education).
SELECT loan_id, applicant_name, amount, loan_type, status, approval_date
FROM loans
WHERE loan_type IN ('Home', 'Education');

-- Check NULL for approval_date.
SELECT loan_id, applicant_name, amount, loan_type, status
FROM loans
WHERE approval_date IS NULL;

-- Show applicant_name, amount, and status.
SELECT applicant_name, amount, status
FROM loans;

-- Sort by amount DESC.
SELECT loan_id, applicant_name, amount, loan_type, status, approval_date
FROM loans
ORDER BY amount DESC;
