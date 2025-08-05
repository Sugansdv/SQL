CREATE DATABASE IF NOT EXISTS vehicle_rental_db;
USE vehicle_rental_db;

-- Table: customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL
);

--  Table: vehicles
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    available BOOLEAN DEFAULT TRUE,
    mileage INT DEFAULT 0,
    fuel_level DECIMAL(5,2) DEFAULT 0.0
);

--  Table: rentals with CHECK and FK
CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    vehicle_id INT,
    rental_date DATE NOT NULL,
    return_date DATE,
    CHECK (return_date IS NULL OR return_date > rental_date),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

--  Table: invoices
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-- Insert sample data
INSERT INTO customers (name, phone) VALUES ('John Doe', '9876543210');
INSERT INTO vehicles (model, license_plate, available, mileage, fuel_level)
VALUES ('Toyota Innova', 'KA01AB1234', TRUE, 50000, 80.0);

-- Transaction: RENTAL with SAVEPOINT and rollback on pricing error
DELIMITER //

CREATE PROCEDURE rent_vehicle(
    IN p_customer_id INT,
    IN p_vehicle_id INT,
    IN p_rental_date DATE,
    IN p_return_date DATE,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_rental_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed. Rolled back.' AS status;
    END;

    START TRANSACTION;

    -- Check availability
    IF (SELECT available FROM vehicles WHERE vehicle_id = p_vehicle_id) = FALSE THEN
        ROLLBACK;
        SELECT 'Vehicle not available' AS status;
        LEAVE rent_vehicle;
    END IF;

    -- Insert rental record
    INSERT INTO rentals (customer_id, vehicle_id, rental_date, return_date)
    VALUES (p_customer_id, p_vehicle_id, p_rental_date, p_return_date);

    SET v_rental_id = LAST_INSERT_ID();

    -- Mark vehicle as unavailable
    UPDATE vehicles SET available = FALSE WHERE vehicle_id = p_vehicle_id;

    SAVEPOINT pricing_save;

    -- Pricing check (simulate error if amount is negative)
    IF p_amount < 0 THEN
        ROLLBACK TO pricing_save;
        ROLLBACK;
        SELECT 'Invalid amount, rolled back to pricing savepoint' AS status;
        LEAVE rent_vehicle;
    END IF;

    -- Create invoice
    INSERT INTO invoices (rental_id, amount)
    VALUES (v_rental_id, p_amount);

    COMMIT;
    SELECT 'Rental and invoice completed' AS status;
END;
//
DELIMITER ;

-- Call the procedure to simulate rental
CALL rent_vehicle(1, 1, '2025-08-05', '2025-08-10', 1500.00);

-- Return vehicle → update mileage and fuel
UPDATE vehicles
SET mileage = mileage + 500,
    fuel_level = 60.0,
    available = TRUE
WHERE vehicle_id = 1;

-- Delete rentals completed > 3 months ago
DELETE FROM rentals
WHERE return_date IS NOT NULL
  AND return_date < CURDATE() - INTERVAL 3 MONTH;

-- Demonstrate durability
-- Assume the last COMMIT was successful, so even if MySQL crashes, the rental and invoice are permanently saved.
-- To verify durability, re-run:
SELECT * FROM rentals;
SELECT * FROM invoices;
