CREATE DATABASE voting_db;

USE voting_db;

CREATE TABLE elections (
    election_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    date DATE
);

CREATE TABLE voters (
    voter_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE candidates (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    party VARCHAR(100),
    election_id INT,
    FOREIGN KEY (election_id) REFERENCES elections(election_id)
);

CREATE TABLE votes (
    vote_id INT PRIMARY KEY AUTO_INCREMENT,
    voter_id INT,
    candidate_id INT,
    election_id INT,
    vote_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (voter_id, election_id), -- ensures one vote per voter per election
    FOREIGN KEY (voter_id) REFERENCES voters(voter_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
    FOREIGN KEY (election_id) REFERENCES elections(election_id)
);

INSERT INTO elections (name, date) VALUES
('Presidential Election', '2025-08-10'),
('Parliament Election', '2025-09-15'),
('Local Body Election', '2025-10-01');

INSERT INTO voters (name, email) VALUES
('Ravi Kumar', 'ravi@example.com'),
('Anita Sharma', 'anita@example.com'),
('Deepak Singh', 'deepak@example.com'),
('Priya Das', 'priya@example.com'),
('Meena Iyer', 'meena@example.com');

INSERT INTO candidates (name, party, election_id) VALUES
('Arjun Mehta', 'Party A', 1),
('Neha Jain', 'Party B', 1),
('Sohail Khan', 'Party A', 2),
('Raj Patel', 'Party B', 2),
('Kavita Rao', 'Party A', 3),
('Manoj Reddy', 'Party B', 3);

-- Presidential Election
INSERT INTO votes (voter_id, candidate_id, election_id) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 1, 1);

-- Parliament Election
INSERT INTO votes (voter_id, candidate_id, election_id) VALUES
(1, 3, 2),
(2, 4, 2),
(4, 3, 2);

-- Local Body Election
INSERT INTO votes (voter_id, candidate_id, election_id) VALUES
(1, 5, 3),
(2, 6, 3),
(5, 5, 3);

SELECT 
    c.name AS candidate,
    e.name AS election,
    COUNT(v.vote_id) AS vote_count
FROM votes v
JOIN candidates c ON v.candidate_id = c.candidate_id
JOIN elections e ON v.election_id = e.election_id
GROUP BY c.candidate_id, e.election_id
ORDER BY e.name, vote_count DESC;

SELECT 
    e.name AS election,
    c.name AS candidate,
    COUNT(v.vote_id) AS total_votes
FROM votes v
JOIN candidates c ON v.candidate_id = c.candidate_id
JOIN elections e ON v.election_id = e.election_id
GROUP BY e.election_id, c.candidate_id
HAVING COUNT(v.vote_id) = (
    SELECT MAX(vc) FROM (
        SELECT COUNT(v2.vote_id) AS vc
        FROM votes v2
        WHERE v2.election_id = e.election_id
        GROUP BY v2.candidate_id
    ) AS sub
);

UPDATE votes
SET candidate_id = 1, vote_time = CURRENT_TIMESTAMP
WHERE voter_id = 2 AND election_id = 1;

select * from votes;


