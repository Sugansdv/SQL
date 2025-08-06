CREATE DATABASE IF NOT EXISTS movie_booking;
USE movie_booking;

CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    duration INT, -- in minutes
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE shows (
    show_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT,
    show_time DATETIME,
    total_seats INT,
    available_seats INT,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    show_id INT,
    customer_name VARCHAR(100),
    seats_booked INT,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (show_id) REFERENCES shows(show_id)
);

INSERT INTO movies (title, genre, duration) VALUES
('Inception', 'Sci-Fi', 148),
('Avengers: Endgame', 'Action', 181),
('Toy Story 4', 'Animation', 100);

INSERT INTO shows (movie_id, show_time, total_seats, available_seats) VALUES
(1, '2025-08-06 18:00:00', 100, 100),
(2, '2025-08-06 20:00:00', 120, 120),
(3, '2025-08-06 16:00:00', 80, 80);

-- View view_now_showing for app frontend (hide backend seat hold logic). 
CREATE VIEW view_now_showing AS
SELECT m.title, s.show_id, s.show_time, s.available_seats
FROM movies m
JOIN shows s ON m.movie_id = s.movie_id
WHERE m.is_active = TRUE AND s.show_time >= NOW();

-- Procedure book_ticket() to reserve seat and update availability. 

-- Function get_available_seats(show_id). 
DELIMITER //

CREATE FUNCTION get_available_seats(show_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE seats INT;
  SELECT available_seats INTO seats FROM shows WHERE show_id = show_id;
  RETURN seats;
END //

DELIMITER ;

-- Trigger before_booking to prevent booking if houseful. 
DELIMITER //

CREATE TRIGGER before_booking
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE available INT;
  SELECT available_seats INTO available FROM shows WHERE show_id = NEW.show_id;
  IF NEW.seats_booked > available THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Houseful! Not enough seats.';
  END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE book_ticket(
  IN p_show_id INT,
  IN p_customer_name VARCHAR(100),
  IN p_seats INT
)
BEGIN
  DECLARE available INT;

  START TRANSACTION;

  SELECT available_seats INTO available FROM shows WHERE show_id = p_show_id;

  IF p_seats > available THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough seats available.';
  ELSE
    INSERT INTO tickets (show_id, customer_name, seats_booked)
    VALUES (p_show_id, p_customer_name, p_seats);

    UPDATE shows SET available_seats = available_seats - p_seats
    WHERE show_id = p_show_id;
  END IF;

  COMMIT;
END //

DELIMITER ;

-- Only allow public access via abstracted views.
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'securepass';
GRANT SELECT ON movie_booking.view_now_showing TO 'app_user'@'localhost';

