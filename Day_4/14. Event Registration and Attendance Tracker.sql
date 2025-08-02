CREATE DATABASE IF NOT EXISTS EventTrackerDB;
USE EventTrackerDB;

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(100),
    event_type VARCHAR(50), -- 'Online' or 'Offline'
    event_date DATE,
    total_seats INT
);

CREATE TABLE attendees (
    attendee_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE registrations (
    reg_id INT PRIMARY KEY,
    attendee_id INT,
    event_id INT,
    registration_date DATE,
    attended BOOLEAN,
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);

CREATE TABLE feedback (
    feedback_id INT PRIMARY KEY,
    reg_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    FOREIGN KEY (reg_id) REFERENCES registrations(reg_id)
);

INSERT INTO events VALUES
(1, 'Tech Summit', 'Online', '2025-08-20', 100),
(2, 'AI Workshop', 'Offline', '2025-08-25', 50),
(3, 'Marketing Bootcamp', 'Online', '2025-09-10', 70);

INSERT INTO attendees VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com'),
(4, 'David', 'david@example.com');

INSERT INTO registrations VALUES
(1, 1, 1, '2025-08-01', TRUE),
(2, 2, 1, '2025-08-02', FALSE),
(3, 3, 2, '2025-08-05', TRUE),
(4, 4, 3, '2025-08-10', TRUE);

INSERT INTO feedback VALUES
(1, 1, 5, 'Excellent event'),
(2, 3, 4, 'Very informative'),
(3, 4, 3, 'Good session');

-- Subquery in SELECT to calculate feedback rating per event
SELECT
    e.event_id,
    e.event_name,
    (SELECT ROUND(AVG(f.rating), 2)
     FROM registrations r
     JOIN feedback f ON r.reg_id = f.reg_id
     WHERE r.event_id = e.event_id) AS avg_rating
FROM events e;

-- CASE to classify events based on turnout percentage
SELECT
    e.event_name,
    COUNT(r.reg_id) AS total_registrations,
    SUM(r.attended) AS attendees,
    CASE
        WHEN (SUM(r.attended) / COUNT(r.reg_id)) >= 0.8 THEN 'Highly Attended'
        WHEN (SUM(r.attended) / COUNT(r.reg_id)) >= 0.5 THEN 'Moderate'
        ELSE 'Low Turnout'
    END AS turnout_status
FROM events e
JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id;

-- UNION ALL to combine online and offline events
SELECT event_id, event_name, 'Online' AS mode FROM events WHERE event_type = 'Online'
UNION ALL
SELECT event_id, event_name, 'Offline' AS mode FROM events WHERE event_type = 'Offline';

-- Correlated subquery to find top participant (highest rated) per event
SELECT
    a.name,
    e.event_name,
    f.rating
FROM attendees a
JOIN registrations r ON a.attendee_id = r.attendee_id
JOIN events e ON r.event_id = e.event_id
JOIN feedback f ON r.reg_id = f.reg_id
WHERE f.rating = (
    SELECT MAX(f2.rating)
    FROM registrations r2
    JOIN feedback f2 ON r2.reg_id = f2.reg_id
    WHERE r2.event_id = r.event_id
);

-- JOIN + GROUP BY to show event-wise engagement (no. of attendees)
SELECT
    e.event_name,
    COUNT(r.reg_id) AS total_registered,
    SUM(r.attended) AS total_attended
FROM events e
JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id;

-- Date filtering for upcoming events
SELECT event_name, event_date
FROM events
WHERE event_date > CURDATE();
