CREATE DATABASE job_portal_db;

USE job_portal_db;

CREATE TABLE companies (
  company_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  industry VARCHAR(100)
);

CREATE TABLE jobs (
  job_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100),
  description TEXT,
  company_id INT,
  location VARCHAR(100),
  FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE applicants (
  applicant_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100)
);

CREATE TABLE applications (
  application_id INT PRIMARY KEY AUTO_INCREMENT,
  job_id INT,
  applicant_id INT,
  application_date DATE,
  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
  FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id)
);

INSERT INTO companies (name, industry) VALUES
('TechNova', 'IT'),
('MediCare', 'Healthcare'),
('FinServe', 'Finance'),
('EduNext', 'Education'),
('BuildCorp', 'Construction');

INSERT INTO jobs (title, description, company_id, location) VALUES
('Software Developer', 'Develop web apps.', 1, 'Bangalore'),
('Data Analyst', 'Analyze business data.', 1, 'Hyderabad'),
('Nurse', 'Assist in patient care.', 2, 'Chennai'),
('Accountant', 'Manage financial records.', 3, 'Mumbai'),
('Teacher', 'Teach primary students.', 4, 'Delhi'),
('Site Engineer', 'Monitor construction.', 5, 'Pune'),
('Frontend Developer', 'UI development.', 1, 'Remote'),
('Backend Developer', 'Server-side coding.', 1, 'Bangalore'),
('Pharmacist', 'Dispense medications.', 2, 'Kolkata'),
('Loan Officer', 'Approve loans.', 3, 'Ahmedabad');


INSERT INTO applicants (name, email) VALUES
('Aarav Mehta', 'aarav@example.com'),
('Diya Sharma', 'diya@example.com'),
('Ravi Kumar', 'ravi@example.com'),
('Sneha Patel', 'sneha@example.com'),
('Vikram Singh', 'vikram@example.com');

INSERT INTO applications (job_id, applicant_id, application_date) VALUES
(1, 1, '2025-07-01'),
(2, 1, '2025-07-02'),
(3, 2, '2025-07-03'),
(1, 2, '2025-07-04'),
(4, 3, '2025-07-05'),
(5, 3, '2025-07-06'),
(6, 4, '2025-07-07'),
(7, 4, '2025-07-08'),
(8, 4, '2025-07-08'),
(9, 5, '2025-07-09'),
(10, 5, '2025-07-10'),
(2, 3, '2025-07-10'),
(3, 4, '2025-07-11'),
(4, 1, '2025-07-11'),
(5, 2, '2025-07-11');

SELECT
  j.title,
  j.location,
  c.name AS company,
  a.application_date
FROM applications a
JOIN jobs j ON a.job_id = j.job_id
JOIN companies c ON j.company_id = c.company_id
WHERE a.applicant_id = 1;

SELECT
  c.name AS company,
  COUNT(app.application_id) AS total_applications
FROM applications app
JOIN jobs j ON app.job_id = j.job_id
JOIN companies c ON j.company_id = c.company_id
GROUP BY c.name
ORDER BY total_applications DESC;




