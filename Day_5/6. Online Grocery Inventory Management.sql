CREATE DATABASE IF NOT EXISTS grocery_db;
USE grocery_db;

-- Create categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- Create suppliers table
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL
);

-- Create products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE, -- will be dropped and recreated later
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    supplier_id INT,
    price DECIMAL(10,2) NOT NULL,
    quantity INT CHECK (quantity >= 0),
    expiry_date DATE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Create stock_logs table
CREATE TABLE stock_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    change_type ENUM('add', 'remove', 'update') NOT NULL,
    quantity_change INT,
    log_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample category and supplier
INSERT INTO categories (category_name) VALUES ('Fruits'), ('Vegetables');
INSERT INTO suppliers (supplier_name) VALUES ('Local Farm'), ('Fresh Supply Co.');

-- Insert product with FK to category and supplier
INSERT INTO products (product_code, product_name, category_id, supplier_id, price, quantity, expiry_date)
VALUES ('APL123', 'Apple', 1, 1, 50.00, 100, '2025-12-31');

-- Update price and quantity with validation (done manually)
UPDATE products
SET price = 55.00, quantity = 120
WHERE product_id = 1 AND price > 0 AND quantity >= 0;

-- Delete expired products
DELETE FROM products
WHERE expiry_date < CURDATE();

-- Drop UNIQUE constraint on product_code
ALTER TABLE products DROP INDEX product_code;

-- Recreate UNIQUE constraint on product_code
ALTER TABLE products ADD UNIQUE (product_code);

-- Use SAVEPOINT during bulk price updates
START TRANSACTION;

SAVEPOINT before_price_update;

-- Bulk price updates
UPDATE products SET price = price * 1.10 WHERE category_id = 1;

-- Simulate failure (optional test)
-- SET @fail := 1/0;  -- Uncomment to test rollback

-- Rollback if something fails (manual or app-level error detection)
-- ROLLBACK TO before_price_update; -- Uncomment if failure occurs

COMMIT;

-- Ensure atomicity of updating inventory and logging
DELIMITER //

CREATE PROCEDURE update_inventory_and_log (
    IN p_product_id INT,
    IN p_quantity_change INT,
    IN p_change_type ENUM('add', 'remove', 'update')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Inventory update failed, rolled back.' AS message;
    END;

    START TRANSACTION;

    UPDATE products
    SET quantity = quantity + p_quantity_change
    WHERE product_id = p_product_id AND (quantity + p_quantity_change) >= 0;

    INSERT INTO stock_logs (product_id, change_type, quantity_change)
    VALUES (p_product_id, p_change_type, p_quantity_change);

    COMMIT;
    SELECT 'Inventory and stock log updated successfully.' AS message;
END;
//

DELIMITER ;

-- call to procedure
CALL update_inventory_and_log(1, -10, 'remove');
