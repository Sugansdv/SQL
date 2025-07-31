CREATE DATABASE event_portal;

USE event_portal;

CREATE TABLE events (
  event_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  event_date DATE NOT NULL,
  location VARCHAR(200)
);

CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE registrations (
  registration_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  event_id INT NOT NULL,
  registration_date DATE NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (event_id) REFERENCES events(event_id)
);

INSERT INTO events (name, event_date, location) VALUES
('Tech Conference 2025', '2025-08-20', 'New Delhi'),
('Startup Workshop', '2025-07-15', 'Mumbai'),
('Health & Wellness Expo', '2025-09-05', 'Chennai'),
('Art & Culture Fest', '2025-08-10', 'Kolkata'),
('Music Fiesta', '2025-07-25', 'Bangalore');

INSERT INTO users (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Lee', 'charlie@example.com'),
('Daisy Green', 'daisy@example.com'),
('Ethan Hunt', 'ethan@example.com');

INSERT INTO registrations (user_id, event_id, registration_date) VALUES
(1, 1, CURDATE()),
(2, 1, CURDATE()),
(3, 1, CURDATE()),
(2, 2, CURDATE()),
(4, 3, CURDATE()),
(5, 3, CURDATE()),
(1, 4, CURDATE()),
(3, 4, CURDATE()),
(5, 5, CURDATE());

SELECT
  e.name AS event,
  e.event_date,
  COUNT(r.registration_id) AS num_registrations
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id
ORDER BY num_registrations DESC;

SELECT
  name,
  event_date,
  location
FROM events
WHERE event_date >= CURDATE()
ORDER BY event_date ASC;






