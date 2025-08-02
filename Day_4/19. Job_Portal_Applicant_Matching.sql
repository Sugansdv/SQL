CREATE DATABASE JobPortalDB;
USE JobPortalDB;

CREATE TABLE companies (
    company_id INT PRIMARY KEY,
    company_name VARCHAR(100)
);

CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    job_title VARCHAR(100),
    job_type VARCHAR(20),  -- 'full-time' or 'internship'
    company_id INT,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE applicants (
    applicant_id INT PRIMARY KEY,
    applicant_name VARCHAR(100)
);

CREATE TABLE applications (
    application_id INT PRIMARY KEY,
    job_id INT,
    applicant_id INT,
    status VARCHAR(20), -- 'shortlisted', 'rejected', 'in review'
    application_date DATE,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id)
);

INSERT INTO companies VALUES
(1, 'TechCorp'),
(2, 'InnovateX'),
(3, 'DevSolutions');

INSERT INTO jobs VALUES
(1, 'Frontend Developer', 'full-time', 1),
(2, 'Backend Intern', 'internship', 2),
(3, 'Data Analyst', 'full-time', 3),
(4, 'Marketing Intern', 'internship', 1);

INSERT INTO applicants VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO applications VALUES
(1, 1, 1, 'in review', '2025-08-01'),
(2, 2, 1, 'shortlisted', '2025-08-02'),
(3, 3, 1, 'rejected', '2025-08-03'),
(4, 4, 1, 'in review', '2025-08-04'),
(5, 1, 2, 'shortlisted', '2025-08-01'),
(6, 3, 2, 'in review', '2025-08-02'),
(7, 2, 3, 'rejected', '2025-08-03');

-- Subquery to show jobs applied by applicants with > 3 applications. 
SELECT job_id, job_title
FROM jobs
WHERE job_id IN (
    SELECT a.job_id
    FROM applications a
    WHERE a.applicant_id IN (
        SELECT applicant_id
        FROM applications
        GROUP BY applicant_id
        HAVING COUNT(*) > 3
    )
);

-- CASE to mark application status: Shortlisted, Rejected, In Review. 
SELECT 
    a.application_id,
    ap.applicant_name,
    j.job_title,
    a.status,
    CASE 
        WHEN a.status = 'shortlisted' THEN 'Shortlisted'
        WHEN a.status = 'rejected' THEN 'Rejected'
        ELSE 'In Review'
    END AS status_description
FROM applications a
JOIN applicants ap ON a.applicant_id = ap.applicant_id
JOIN jobs j ON a.job_id = j.job_id;

-- JOIN + GROUP BY to calculate applications per job. 
SELECT j.job_title, COUNT(a.application_id) AS total_applications
FROM applications a
JOIN jobs j ON a.job_id = j.job_id
GROUP BY j.job_title;

-- UNION to combine full-time and internship roles.
SELECT job_title, 'Full-Time' AS job_category
FROM jobs
WHERE job_type = 'full-time'
UNION
SELECT job_title, 'Internship'
FROM jobs
WHERE job_type = 'internship';
 
-- Correlated subquery to find most applied job per applicant. 
SELECT ap.applicant_name, j.job_title
FROM applicants ap
JOIN applications a ON ap.applicant_id = a.applicant_id
JOIN jobs j ON a.job_id = j.job_id
WHERE a.job_id = (
    SELECT job_id
    FROM applications a2
    WHERE a2.applicant_id = ap.applicant_id
    GROUP BY job_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Date filter for recent applications. 
SELECT ap.applicant_name, j.job_title, a.application_date
FROM applications a
JOIN applicants ap ON a.applicant_id = ap.applicant_id
JOIN jobs j ON a.job_id = j.job_id
WHERE a.application_date >= CURDATE() - INTERVAL 7 DAY;-- 