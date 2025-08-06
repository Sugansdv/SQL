CREATE DATABASE HotelDB;
USE HotelDB;

CREATE TABLE Rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_type VARCHAR(50),
    rate_per_night DECIMAL(10, 2),
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_name VARCHAR(100),
    room_id INT,
    check_in DATE,
    check_out DATE,
    total_cost DECIMAL(10, 2),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

CREATE TABLE Maintenance (
    maintenance_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT,
    maintenance_date DATE,
    description TEXT,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

INSERT INTO Rooms (room_type, rate_per_night, is_available)
VALUES 
('Single', 1000.00, TRUE),
('Double', 1800.00, TRUE),
('Suite', 3000.00, TRUE);

INSERT INTO Maintenance (room_id, maintenance_date, description)
VALUES 
(1, '2025-08-10', 'AC Repair'),
(3, '2025-08-12', 'Plumbing Check');

-- View view_available_rooms that hides internal maintenance schedules
CREATE VIEW view_available_rooms AS
SELECT room_id, room_type, rate_per_night
FROM Rooms
WHERE is_available = TRUE;

DELIMITER //
CREATE PROCEDURE book_room(
    IN p_guest_name VARCHAR(100),
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    DECLARE v_rate DECIMAL(10, 2);
    DECLARE v_days INT;
    DECLARE v_total_cost DECIMAL(10, 2);

    START TRANSACTION;

    SELECT rate_per_night INTO v_rate FROM Rooms WHERE room_id = p_room_id AND is_available = TRUE;

    SET v_days = DATEDIFF(p_check_out, p_check_in);
    SET v_total_cost = v_rate * v_days;

    INSERT INTO Bookings (guest_name, room_id, check_in, check_out, total_cost)
    VALUES (p_guest_name, p_room_id, p_check_in, p_check_out, v_total_cost);

    UPDATE Rooms SET is_available = FALSE WHERE room_id = p_room_id;

    COMMIT;
END //
DELIMITER ;

-- Function calculate_stay_cost() based on room rate and duration
DELIMITER //
CREATE FUNCTION calculate_stay_cost(
    p_room_id INT,
    p_check_in DATE,
    p_check_out DATE
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE v_rate DECIMAL(10, 2);
    DECLARE v_days INT;

    SELECT rate_per_night INTO v_rate FROM Rooms WHERE room_id = p_room_id;

    SET v_days = DATEDIFF(p_check_out, p_check_in);

    RETURN v_rate * v_days;
END //
DELIMITER ;

-- Trigger after_booking to update room availability
DELIMITER //
CREATE TRIGGER after_booking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Rooms SET is_available = FALSE WHERE room_id = NEW.room_id;
END //
DELIMITER ;

-- Receptionists use restricted views instead of base tables
CREATE VIEW view_receptionist_bookings AS
SELECT booking_id, guest_name, room_id, check_in, check_out, total_cost
FROM Bookings;
