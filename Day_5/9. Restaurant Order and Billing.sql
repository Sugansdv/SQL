CREATE DATABASE IF NOT EXISTS restaurant_db;
USE restaurant_db;

-- Create customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE
);

-- Create menu_items table
CREATE TABLE menu_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    available_quantity INT DEFAULT 0 CHECK (available_quantity >= 0)
);

-- Create orders table with FK to customer and item, CHECK on quantity ≤ 10
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    item_id INT,
    table_number INT,
    quantity INT CHECK (quantity <= 10),
    order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- Create bills table
CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    total_amount DECIMAL(10, 2) NOT NULL,
    bill_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert sample data
INSERT INTO customers (name, phone) VALUES ('Alice', '9999999999');
INSERT INTO menu_items (item_name, price, available_quantity)
VALUES ('Pasta', 250.00, 50), ('Pizza', 350.00, 30);

-- Insert order with FK to customer and menu_item
INSERT INTO orders (customer_id, item_id, table_number, quantity)
VALUES (1, 1, 5, 2);

-- Update item availability after order (Pasta ordered 2)
UPDATE menu_items
SET available_quantity = available_quantity - 2
WHERE item_id = 1;

-- Delete unpaid orders after timeout (e.g., older than 30 mins and unpaid)
DELETE FROM orders
WHERE paid = FALSE AND order_time < NOW() - INTERVAL 30 MINUTE;

-- Drop NOT NULL constraint on table_number (requires recreate in MySQL)
ALTER TABLE orders MODIFY table_number INT NULL;

-- Reapply NOT NULL constraint on table_number
ALTER TABLE orders MODIFY table_number INT NOT NULL;

-- Use a transaction to insert order and bill together
DELIMITER //

CREATE PROCEDURE place_order_and_bill(
    IN p_customer_id INT,
    IN p_item_id INT,
    IN p_table_number INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_total DECIMAL(10, 2);
    DECLARE v_order_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Order failed. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    SELECT price INTO v_price FROM menu_items WHERE item_id = p_item_id;

    SET v_total = v_price * p_quantity;

    INSERT INTO orders (customer_id, item_id, table_number, quantity)
    VALUES (p_customer_id, p_item_id, p_table_number, p_quantity);

    SET v_order_id = LAST_INSERT_ID();

    UPDATE menu_items
    SET available_quantity = available_quantity - p_quantity
    WHERE item_id = p_item_id AND available_quantity >= p_quantity;

    INSERT INTO bills (order_id, total_amount)
    VALUES (v_order_id, v_total);

    COMMIT;
    SELECT 'Order and bill successfully created.' AS message;
END;
//

DELIMITER ;

-- Call the procedure to place order and generate bill
CALL place_order_and_bill(1, 2, 10, 3);
