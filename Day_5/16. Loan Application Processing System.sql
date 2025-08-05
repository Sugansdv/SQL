-- Create database
DROP DATABASE IF EXISTS loan_system;
CREATE DATABASE loan_system;
USE loan_system;

-- Create applicants table
CREATE TABLE applicants (
    applicant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE
);

-- Create loans table with amount check
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    applicant_id INT,
    amount DECIMAL(12,2) CHECK (amount <= 1000000),
    status ENUM('applied', 'verified', 'approved', 'disbursed', 'rejected') DEFAULT 'applied',
    applied_on DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id)
);

-- Step 4: Create documents table
CREATE TABLE documents (
    doc_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT,
    doc_type VARCHAR(50),
    is_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Create disbursements table
CREATE TABLE disbursements (
    disbursement_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT,
    disbursed_amount DECIMAL(12,2),
    disbursed_on DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Insert sample applicant
INSERT INTO applicants (name, email, phone)
VALUES ('John Doe', 'john@example.com', '9998887777');

-- Insert sample loan (valid amount)
INSERT INTO loans (applicant_id, amount)
VALUES (1, 500000);

-- Insert documents
INSERT INTO documents (loan_id, doc_type, is_verified)
VALUES 
(1, 'ID Proof', TRUE),
(1, 'Income Proof', TRUE),
(1, 'Address Proof', TRUE);

-- Transaction to verify docs, approve loan, disburse
START TRANSACTION;

-- Check if all documents are verified
SELECT COUNT(*) INTO @unverified_docs 
FROM documents 
WHERE loan_id = 1 AND is_verified = FALSE;

-- If unverified docs exist, rollback
SELECT COUNT(*) AS unverified_docs
FROM documents
WHERE loan_id = 1 AND is_verified = FALSE;

    -- Update loan status to 'verified'
    UPDATE loans SET status = 'verified' WHERE loan_id = 1;

    -- Set savepoint before disbursement
    SAVEPOINT before_disbursement;

    -- Approve and disburse
    UPDATE loans SET status = 'approved' WHERE loan_id = 1;

    INSERT INTO disbursements (loan_id, disbursed_amount)
    VALUES (1, 500000);

    -- Final status update
   -- Change delimiter - procedure blocks
DELIMITER $$

-- Create stored procedure
CREATE PROCEDURE process_loan_disbursement(IN p_loan_id INT)
BEGIN
  DECLARE unverified_docs INT DEFAULT 0;

  -- Start transaction
  START TRANSACTION;

  -- Count unverified documents
  SELECT COUNT(*) INTO unverified_docs
  FROM documents
  WHERE loan_id = p_loan_id AND is_verified = FALSE;

  -- Conditional check
  IF unverified_docs > 0 THEN
    ROLLBACK;
  ELSE
    -- Step: Mark as verified
    UPDATE loans SET status = 'verified' WHERE loan_id = p_loan_id;

    -- Savepoint
    SAVEPOINT before_disbursement;

    -- Step: Approve loan
    UPDATE loans SET status = 'approved' WHERE loan_id = p_loan_id;

    -- Step: Disburse funds
    INSERT INTO disbursements (loan_id, disbursed_amount)
    VALUES (
      p_loan_id,
      (SELECT amount FROM loans WHERE loan_id = p_loan_id)
    );

    -- Final status update
    UPDATE loans SET status = 'disbursed' WHERE loan_id = p_loan_id;

    -- Commit all
    COMMIT;
  END IF;
END$$

-- Restore default delimiter
DELIMITER ;

-- Call the procedure
CALL process_loan_disbursement(1);


-- Delete unverified applications (no verified docs)
DELETE FROM loans
WHERE loan_id IN (
    SELECT l.loan_id
    FROM loans l
    LEFT JOIN documents d ON l.loan_id = d.loan_id
    GROUP BY l.loan_id
    HAVING SUM(CASE WHEN d.is_verified = TRUE THEN 1 ELSE 0 END) = 0
);
