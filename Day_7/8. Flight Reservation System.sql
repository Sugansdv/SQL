CREATE DATABASE FlightReservationDB;
USE FlightReservationDB;

CREATE TABLE flights (
  flight_id INT PRIMARY KEY AUTO_INCREMENT,
  flight_number VARCHAR(10),
  origin VARCHAR(50),
  destination VARCHAR(50),
  departure_time DATETIME,
  arrival_time DATETIME,
  internal_notes TEXT,
  aircraft_model VARCHAR(50),
  capacity INT
);

CREATE TABLE passengers (
  passenger_id INT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20)
);

CREATE TABLE reservations (
  reservation_id INT PRIMARY KEY AUTO_INCREMENT,
  flight_id INT,
  passenger_id INT,
  booking_time DATETIME DEFAULT NOW(),
  pnr VARCHAR(10) UNIQUE,
  checkin_status BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
  FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

INSERT INTO flights (flight_number, origin, destination, departure_time, arrival_time, internal_notes, aircraft_model, capacity)
VALUES 
('AI101', 'Delhi', 'Mumbai', '2025-08-10 10:00:00', '2025-08-10 12:00:00', 'VIP flight', 'Boeing 737', 180),
('AI202', 'Chennai', 'Bangalore', '2025-08-11 09:30:00', '2025-08-11 11:00:00', 'Maintenance required', 'Airbus A320', 150);

INSERT INTO passengers (full_name, email, phone)
VALUES 
('Ravi Kumar', 'ravi@example.com', '9999999999'),
('Anita Desai', 'anita@example.com', '8888888888');

-- View view_flight_schedule (excludes internal notes and employee info). 
CREATE VIEW view_flight_schedule AS
SELECT 
  flight_id, 
  flight_number, 
  origin, 
  destination, 
  departure_time, 
  arrival_time, 
  aircraft_model, 
  capacity
FROM flights;

-- Procedure book_flight() handles insert and returns PNR. 
DELIMITER //

CREATE PROCEDURE book_flight (
  IN in_flight_id INT,
  IN in_passenger_id INT,
  OUT out_pnr VARCHAR(10)
)
BEGIN
  DECLARE new_pnr VARCHAR(10);

  -- Generate a simple PNR
  SET new_pnr = CONCAT('PNR', LPAD(FLOOR(RAND()*1000000), 6, '0'));

  -- Insert into reservation
  INSERT INTO reservations (flight_id, passenger_id, pnr)
  VALUES (in_flight_id, in_passenger_id, new_pnr);

  -- Return the generated PNR
  SET out_pnr = new_pnr;
END //

DELIMITER ;

CALL book_flight(1, 1, @pnr);
SELECT @pnr;


-- Function get_passenger_count(flight_id) for admin dashboard. 
DELIMITER //

CREATE FUNCTION get_passenger_count(f_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;

  SELECT COUNT(*) INTO total
  FROM reservations
  WHERE flight_id = f_id;

  RETURN total;
END //

DELIMITER ;

SELECT get_passenger_count(1);

-- Trigger after_checkin marks passenger as boarded. 
DELIMITER //
CREATE TRIGGER after_checkin
AFTER UPDATE ON reservations
FOR EACH ROW
BEGIN
  IF NEW.checkin_status = TRUE AND OLD.checkin_status = FALSE THEN
    -- Example: update a field or log audit
    UPDATE passengers 
    SET boarded = TRUE 
    WHERE passenger_id = NEW.passenger_id;
  END IF;
END //

DELIMITER ;

UPDATE reservations SET checkin_status = TRUE WHERE reservation_id = 1;

