CREATE DATABASE GymSystem;
USE GymSystem;

CREATE TABLE members (
  member_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  contact_info VARCHAR(100),
  membership_status VARCHAR(20) DEFAULT 'active',
  points INT DEFAULT 0
);

CREATE TABLE trainers (
  trainer_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100)
);

CREATE TABLE sessions (
  session_id INT PRIMARY KEY AUTO_INCREMENT,
  trainer_id INT,
  session_date DATE,
  session_time TIME,
  FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

CREATE TABLE attendance (
  attendance_id INT PRIMARY KEY AUTO_INCREMENT,
  member_id INT,
  session_id INT,
  attendance_date DATE,
  FOREIGN KEY (member_id) REFERENCES members(member_id),
  FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

INSERT INTO members (name, contact_info) VALUES
('John Doe', 'john@example.com'),
('Alice Smith', 'alice@example.com'),
('Bob Lee', 'bob@example.com');

INSERT INTO trainers (name, email) VALUES
('Trainer One', 't1@gym.com'),
('Trainer Two', 't2@gym.com');

INSERT INTO sessions (trainer_id, session_date, session_time) VALUES
(1, '2025-08-01', '08:00:00'),
(2, '2025-08-02', '09:00:00');

-- View - view_attendance_summary (hide contact info)
CREATE VIEW view_attendance_summary AS
SELECT 
  m.member_id,
  m.name AS member_name,
  s.session_id,
  s.session_date,
  s.session_time,
  t.name AS trainer_name
FROM attendance a
JOIN members m ON a.member_id = m.member_id
JOIN sessions s ON a.session_id = s.session_id
JOIN trainers t ON s.trainer_id = t.trainer_id;

-- Procedure - log_attendance
DELIMITER //
CREATE PROCEDURE log_attendance(IN p_member_id INT, IN p_session_id INT)
BEGIN
  INSERT INTO attendance (member_id, session_id, attendance_date)
  VALUES (p_member_id, p_session_id, CURDATE());
END;
//
DELIMITER ;

-- Function - get_monthly_visits
DELIMITER //
CREATE FUNCTION get_monthly_visits(p_member_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE visit_count INT;
  SELECT COUNT(*) INTO visit_count
  FROM attendance
  WHERE member_id = p_member_id
    AND MONTH(attendance_date) = MONTH(CURDATE())
    AND YEAR(attendance_date) = YEAR(CURDATE());
  RETURN visit_count;
END;
//
DELIMITER ;

-- Trigger - after_attendance
DELIMITER //
CREATE TRIGGER after_attendance
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
  UPDATE members
  SET points = points + 10
  WHERE member_id = NEW.member_id;
END;
//
DELIMITER ;

-- View - view_active_members (public dashboard, only active)
CREATE VIEW view_active_members AS
SELECT member_id, name
FROM members
WHERE membership_status = 'active';

-- Test Calls (optional)
-- CALL log_attendance(1, 1);
-- SELECT get_monthly_visits(1);
-- SELECT * FROM view_attendance_summary;
-- SELECT * FROM view_active_members;
-- SELECT * FROM members;
