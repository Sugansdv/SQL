CREATE DATABASE BankLoanAnalytics;
USE BankLoanAnalytics;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender CHAR(1)
);

CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    branch_id INT,
    loan_type VARCHAR(50),
    amount DECIMAL(12,2),
    status VARCHAR(20),
    issued_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

INSERT INTO customers VALUES
(1, 'Arun Mehta', '1985-06-12', 'M'),
(2, 'Priya Das', '1990-08-23', 'F');

INSERT INTO branches VALUES
(101, 'Main Branch', 'Mumbai'),
(102, 'City Branch', 'Delhi');

INSERT INTO loans VALUES
(1001, 1, 101, 'Home Loan', 5000000, 'Active', '2022-01-10'),
(1002, 2, 102, 'Car Loan', 800000, 'Closed', '2021-09-15');

INSERT INTO payments VALUES
(5001, 1001, '2022-02-10', 50000, 'On-Time'),
(5002, 1001, '2022-03-10', 50000, 'Delayed'),
(5003, 1002, '2021-10-10', 40000, 'On-Time');

-- Snowflake Schema for normalized customer and loan details
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender CHAR(1),
    dob DATE
);

CREATE TABLE dim_branch (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE dim_loan (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    branch_id INT,
    loan_type VARCHAR(50),
    amount DECIMAL(12,2),
    issued_date DATE,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (branch_id) REFERENCES dim_branch(branch_id)
);

CREATE TABLE fact_payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (loan_id) REFERENCES dim_loan(loan_id)
);

-- ETL to extract repayment history, transform statuses
INSERT INTO dim_customer
SELECT DISTINCT customer_id, name, gender, dob FROM customers;

INSERT INTO dim_branch
SELECT DISTINCT branch_id, branch_name, city FROM branches;

INSERT INTO dim_loan
SELECT loan_id, customer_id, branch_id, loan_type, amount, issued_date
FROM loans;

INSERT INTO fact_payments
SELECT payment_id, loan_id, payment_date, amount_paid, 
       CASE 
           WHEN status = 'Delayed' THEN 'Late'
           WHEN status = 'On-Time' THEN 'OnTime'
           ELSE 'Unknown'
       END AS status
FROM payments;

-- Reports: default rate by branch, loan product performance
SELECT 
    db.branch_name,
    COUNT(CASE WHEN l.status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(*) AS default_rate
FROM dim_loan l
JOIN dim_branch db ON l.branch_id = db.branch_id
GROUP BY db.branch_name;

SELECT 
    loan_type,
    COUNT(*) AS total_loans,
    SUM(amount) AS total_amount
FROM dim_loan
GROUP BY loan_type;

-- OLAP reports to support risk assessment and audit
SELECT 
    loan_type,
    status,
    COUNT(*) AS count_status
FROM fact_payments fp
JOIN dim_loan dl ON fp.loan_id = dl.loan_id
GROUP BY loan_type, status;

SELECT 
    city,
    loan_type,
    AVG(amount_paid) AS avg_payment
FROM fact_payments fp
JOIN dim_loan dl ON fp.loan_id = dl.loan_id
JOIN dim_branch db ON dl.branch_id = db.branch_id
GROUP BY city, loan_type;
