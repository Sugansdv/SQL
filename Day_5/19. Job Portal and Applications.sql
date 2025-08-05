CREATE DATABASE job_portal;

USE job_portal;

-- Recruiters Table
CREATE TABLE recruiters (
    recruiter_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

-- Jobs Table
CREATE TABLE jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    recruiter_id INT,
    title VARCHAR(100),
    deadline DATE,
    description TEXT,
    FOREIGN KEY (recruiter_id) REFERENCES recruiters(recruiter_id)
);

-- Applicants Table
CREATE TABLE applicants (
    applicant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    experience INT CHECK (experience >= 0)
);

-- Applications Table
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT,
    applicant_id INT,
    status VARCHAR(50) DEFAULT 'Applied',
    applied_on DATE ,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON DELETE CASCADE,
    UNIQUE (job_id, applicant_id)
);

-- Insert Sample Data
INSERT INTO recruiters (name, email) VALUES ('HR Manager', 'hr@example.com');

INSERT INTO jobs (recruiter_id, title, deadline, description)
VALUES (1, 'Software Engineer', '2025-12-31', 'Develop and maintain web apps.');

INSERT INTO applicants (name, email, experience)
VALUES ('Alice', 'alice@example.com', 2),
       ('Bob', 'bob@example.com', 0);

INSERT INTO applications (job_id, applicant_id) VALUES (1, 1);

-- Update Application Status
UPDATE applications SET status = 'Interview' WHERE application_id = 1;

-- Delete Applications After Deadline
DELETE FROM applications
WHERE job_id IN (
  SELECT job_id FROM jobs WHERE deadline < CURDATE()
);

-- Drop Old CHECK Constraint on Experience (replace with real constraint name)
-- Example only:
-- ALTER TABLE applicants DROP CHECK chk_experience;

-- Recreate CHECK with new rule
ALTER TABLE applicants ADD CHECK (experience >= 1);

-- Transaction: Post Job + Notify Applicants
START TRANSACTION;

INSERT INTO jobs (recruiter_id, title, deadline, description)
VALUES (1, 'Backend Developer', '2025-11-30', 'Work with Node.js and MySQL.');

-- Simulate notifications (in production: INSERT INTO notifications / send email)
SELECT CONCAT(name, ' notified of new job.') AS message FROM applicants;

COMMIT;

