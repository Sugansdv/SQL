CREATE DATABASE IF NOT EXISTS voting_db;
USE voting_db;

-- Voters table
CREATE TABLE voters (
    voter_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT CHECK (age >= 18),
    unique_id VARCHAR(20) UNIQUE,
    test_mode BOOLEAN DEFAULT FALSE
);

-- Elections table
CREATE TABLE elections (
    election_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    election_date DATE
);

-- Candidates table
CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT,
    name VARCHAR(100),
    FOREIGN KEY (election_id) REFERENCES elections(election_id) ON DELETE CASCADE
);

-- Votes table
CREATE TABLE votes (
    vote_id INT AUTO_INCREMENT PRIMARY KEY,
    voter_id INT,
    election_id INT,
    candidate_id INT,
    vote_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (voter_id) REFERENCES voters(voter_id) ON DELETE CASCADE,
    FOREIGN KEY (election_id) REFERENCES elections(election_id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id) ON DELETE CASCADE,
    UNIQUE (voter_id, election_id)  -- only one vote per voter per election
);

-- Insert voters
INSERT INTO voters (name, age, unique_id) VALUES
('Alice', 30, 'ID123'),
('Bob', 22, 'ID456'),
('Charlie', 19, 'ID789');

-- Insert election
INSERT INTO elections (title, election_date) VALUES
('2025 General Election', '2025-11-10');

-- Insert candidates
INSERT INTO candidates (election_id, name) VALUES
(1, 'Candidate A'),
(1, 'Candidate B');

-- Update Vote Status After Submission
ALTER TABLE voters ADD COLUMN has_voted BOOLEAN DEFAULT FALSE;

-- After vote submission
UPDATE voters SET has_voted = TRUE WHERE voter_id = 1;

-- Delete invalid votes using FOREIGN KEY cascade.
DELETE FROM voters WHERE voter_id = 2;

-- Modify Constraint for Re-voting in Test Mode
ALTER TABLE votes DROP INDEX voter_id;  -- drop the UNIQUE(voter_id, election_id)

-- Use Transaction to Cast Vote + Log + Confirm
START TRANSACTION;

-- Step 1: Cast the vote
INSERT INTO votes (voter_id, election_id, candidate_id)
VALUES (1, 1, 1);

-- Step 2: Update voter's has_voted status
UPDATE voters SET has_voted = TRUE WHERE voter_id = 1;

-- Step 3: Log (example: insert into audit_log if you have it)

-- Step 4: Confirm and commit
COMMIT;

-- If any part fails, rollback:
ROLLBACK;

