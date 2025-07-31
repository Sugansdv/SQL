CREATE DATABASE loan_db;
USE loan_db;

CREATE TABLE borrowers (
  borrower_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20)
);

CREATE TABLE loan_types (
  type_id INT PRIMARY KEY AUTO_INCREMENT,
  type_name VARCHAR(50),
  interest_rate DECIMAL(5,2)
);

CREATE TABLE loans (
  loan_id INT PRIMARY KEY AUTO_INCREMENT,
  borrower_id INT,
  type_id INT,
  amount DECIMAL(10,2),
  disbursement_date DATE,
  due_date DATE,
  FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id),
  FOREIGN KEY (type_id) REFERENCES loan_types(type_id)
);

CREATE TABLE repayments (
  repayment_id INT PRIMARY KEY AUTO_INCREMENT,
  loan_id INT,
  amount DECIMAL(10,2),
  repayment_date DATE,
  FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);


INSERT INTO borrowers (name, email, phone) VALUES
('Ravi Kumar', 'ravi@example.com', '9876543210'),
('Meena Rani', 'meena@example.com', '9876543211');

INSERT INTO loan_types (type_name, interest_rate) VALUES
('Home Loan', 7.50),
('Personal Loan', 12.00),
('Education Loan', 9.25);

INSERT INTO loans (borrower_id, type_id, amount, disbursement_date, due_date) VALUES
(1, 1, 500000.00, '2025-01-15', '2026-01-15'),
(1, 2, 100000.00, '2025-04-10', '2025-10-10'),
(2, 3, 200000.00, '2025-02-20', '2026-02-20');

INSERT INTO repayments (loan_id, amount, repayment_date) VALUES
(1, 50000.00, '2025-03-15'),
(1, 50000.00, '2025-06-15'),
(2, 20000.00, '2025-05-01'),
(3, 30000.00, '2025-04-01'),
(3, 30000.00, '2025-07-01');

SELECT 
  b.name AS borrower_name,
  SUM(r.amount) AS total_repaid
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY b.borrower_id;

SELECT 
  b.name AS borrower_name,
  l.loan_id,
  l.due_date
FROM loans l
JOIN borrowers b ON l.borrower_id = b.borrower_id
WHERE l.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);












