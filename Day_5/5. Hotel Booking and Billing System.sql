CREATE DATABASE IF NOT EXISTS hotel_db;
USE hotel_db;

-- Create guests table with NOT NULL and UNIQUE phone
CREATE TABLE guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100)
);

-- Create rooms table
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    room_capacity INT NOT NULL,
    status ENUM('available', 'occupied', 'maintenance') DEFAULT 'available'
);

-- Create bookings table with CHECK for number_of_guests ≤ room_capacity
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    number_of_guests INT NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    CHECK (number_of_guests <= 10) -- Initial fixed CHECK (we’ll update it below)
);

-- Create payments table with ON DELETE CASCADE
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE DEFAULT (CURDATE()),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- Modify CHECK constraint: ensure number_of_guests ≤ actual room capacity
-- First drop the fixed constraint (simulate by altering the table in MySQL)
ALTER TABLE bookings DROP CHECK number_of_guests;

-- Re-add proper CHECK using trigger (since MySQL doesn't support cross-table CHECK)
DELIMITER //

CREATE TRIGGER check_room_capacity
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    DECLARE capacity INT;
    SELECT room_capacity INTO capacity FROM rooms WHERE room_id = NEW.room_id;
    IF NEW.number_of_guests > capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Number of guests exceeds room capacity';
    END IF;
END;
//

DELIMITER ;

-- Create stored procedure to handle booking + payment transactionally
DELIMITER //

CREATE PROCEDURE book_room_with_payment(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_number_of_guests INT,
    IN p_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Booking failed. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    INSERT INTO bookings (guest_id, room_id, check_in, check_out, number_of_guests)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, p_number_of_guests);

    SET @last_booking_id = LAST_INSERT_ID();

    INSERT INTO payments (booking_id, amount)
    VALUES (@last_booking_id, p_amount);

    UPDATE rooms SET status = 'occupied' WHERE room_id = p_room_id;

    COMMIT;
    SELECT 'Booking and payment successful.' AS message;
END;
//

DELIMITER ;

-- Example INSERTs
INSERT INTO guests (name, phone, email)
VALUES ('John Doe', '9999999999', 'john@example.com');

INSERT INTO rooms (room_number, room_capacity, status)
VALUES ('101', 4, 'available');

-- Call the stored procedure
CALL book_room_with_payment(1, 1, '2025-08-10', '2025-08-15', 2, 12000.00);

-- Update room status to 'available' on checkout
UPDATE rooms SET status = 'available'
WHERE room_id = 1;

-- Delete a booking (and its payment due to ON DELETE CASCADE)
DELETE FROM bookings WHERE booking_id = 1;
