CREATE DATABASE IF NOT EXISTS event_management;
USE event_management;

-- Create tables
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_title VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    age_restriction BOOLEAN DEFAULT FALSE,
    UNIQUE (event_title)
);

CREATE TABLE attendees (
    attendee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age >= 0)
);

CREATE TABLE tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    attendee_id INT,
    ticket_type VARCHAR(50),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id) ON DELETE CASCADE
);

-- Enforce CHECK: Age restriction for attendees (enforced via trigger)
DELIMITER //

CREATE TRIGGER check_age_restriction
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE restricted BOOLEAN;
  DECLARE attendee_age INT;

  SELECT age_restriction INTO restricted FROM events WHERE event_id = NEW.event_id;
  SELECT age INTO attendee_age FROM attendees WHERE attendee_id = NEW.attendee_id;

  IF restricted AND attendee_age < 18 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendee must be 18+ for this event';
  END IF;
END;
//

DELIMITER ;

--  Insert sample data
INSERT INTO events (event_title, event_date, age_restriction)
VALUES 
('Tech Conference 2025', '2025-10-01', FALSE),
('Wine Tasting', '2025-09-15', TRUE);

INSERT INTO attendees (name, age) VALUES
('Alice', 25),
('Bob', 17),
('Charlie', 19);

-- Insert new attendee registrations (valid only if age condition matches)
INSERT INTO tickets (event_id, attendee_id, ticket_type)
VALUES (1, 1, 'Standard'); -- Alice to Tech Conference

-- Update ticket type or event date
UPDATE tickets SET ticket_type = 'VIP' WHERE ticket_id = 1;
UPDATE events SET event_date = '2025-10-15' WHERE event_id = 1;

-- Delete expired events and dependent tickets
DELETE FROM events WHERE event_date < CURDATE();

-- Modify UNIQUE constraint on event title
-- Drop first
ALTER TABLE events DROP INDEX event_title;

-- Re-add with different name
ALTER TABLE events ADD UNIQUE INDEX unique_event_title (event_title);

-- Transaction for bulk registration with rollback on duplicate
DELIMITER //

CREATE PROCEDURE RegisterAttendeesBulk(
    IN eventId INT,
    IN attendeeList TEXT  -- Comma-separated attendee_ids
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE att_id INT;
    DECLARE dup_count INT DEFAULT 0;
    DECLARE cur CURSOR FOR 
        SELECT CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(attendeeList, ',', n.n), ',', -1)) AS UNSIGNED) as att_id
        FROM (
          SELECT a.N + b.N * 10 + 1 AS n
          FROM 
            (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
             UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
            (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
             UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
        ) n
        WHERE n.n <= 1 + LENGTH(attendeeList) - LENGTH(REPLACE(attendeeList, ',', ''));

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO att_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check duplicate
        SELECT COUNT(*) INTO dup_count 
        FROM tickets 
        WHERE event_id = eventId AND attendee_id = att_id;

        IF dup_count > 0 THEN
            ROLLBACK;
            LEAVE read_loop;
        END IF;

        -- Insert ticket
        INSERT INTO tickets (event_id, attendee_id, ticket_type)
        VALUES (eventId, att_id, 'Standard');
    END LOOP;

    IF dup_count = 0 THEN
        COMMIT;
    END IF;

    CLOSE cur;
END;
//

DELIMITER ;

--  Register multiple attendees (1 and 3) for event 1
CALL RegisterAttendeesBulk(1, '1,3');
