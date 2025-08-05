
CREATE DATABASE IF NOT EXISTS flight_booking_db;
USE flight_booking_db;

-- Table: passengers
CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    passport_no VARCHAR(20) UNIQUE NOT NULL
);

-- Table: flights
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_name VARCHAR(100) NOT NULL,
    flight_date DATE NOT NULL,
    status ENUM('Scheduled', 'Cancelled', 'Departed') DEFAULT 'Scheduled',
    total_seats INT NOT NULL,
    available_seats INT NOT NULL,
    CHECK (flight_date >= CURRENT_DATE)
);

--  Table: tickets
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_name VARCHAR(100) NOT NULL,
    flight_date DATE NOT NULL,
    status ENUM('Scheduled', 'Cancelled', 'Departed') DEFAULT 'Scheduled',
    total_seats INT NOT NULL,
    available_seats INT NOT NULL
);


-- Table: payments
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT,
    amount DECIMAL(10,2) NOT NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);

-- Insert sample data
INSERT INTO passengers (name, passport_no) VALUES ('Alice Kumar', 'IND123456');
INSERT INTO flights (flight_name, flight_date, total_seats, available_seats)
VALUES ('AI202 - Mumbai to Delhi', CURDATE() + INTERVAL 2 DAY, 180, 180);

-- Drop NOT NULL from seat_no
ALTER TABLE tickets MODIFY seat_no VARCHAR(10);

--  Reapply NOT NULL on seat_no
ALTER TABLE tickets MODIFY seat_no VARCHAR(10) NOT NULL;

--  Transaction: Book ticket and process payment
DELIMITER //

CREATE PROCEDURE book_ticket_with_payment(
    IN p_passenger_id INT,
    IN p_flight_id INT,
    IN p_seat_no VARCHAR(10),
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_ticket_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Booking Failed. Rolled back.' AS status;
    END;

    START TRANSACTION;

    -- Check if seats are available
    IF (SELECT available_seats FROM flights WHERE flight_id = p_flight_id) <= 0 THEN
        ROLLBACK;
        SELECT 'No seats available' AS status;
        LEAVE book_ticket_with_payment;
    END IF;

    -- Insert ticket
    INSERT INTO tickets (passenger_id, flight_id, seat_no)
    VALUES (p_passenger_id, p_flight_id, p_seat_no);

    SET v_ticket_id = LAST_INSERT_ID();

    -- Update flight seat count
    UPDATE flights
    SET available_seats = available_seats - 1
    WHERE flight_id = p_flight_id;

    -- Simulate payment error
    IF p_amount < 0 THEN
        ROLLBACK;
        SELECT 'Invalid payment amount. Rolled back.' AS status;
        LEAVE book_ticket_with_payment;
    END IF;

    -- Insert payment
    INSERT INTO payments (ticket_id, amount)
    VALUES (v_ticket_id, p_amount);

    COMMIT;
    SELECT 'Ticket booked and payment successful' AS status;
END;
//
DELIMITER ;

-- Call procedure to test
CALL book_ticket_with_payment(1, 1, '12A', 3500.00);

-- Update flight status manually
UPDATE flights SET status = 'Departed' WHERE flight_id = 1;

-- Delete unpaid tickets older than 1 day
DELETE FROM tickets
WHERE ticket_id NOT IN (SELECT ticket_id FROM payments)
  AND booking_date < CURDATE() - INTERVAL 1 DAY;
