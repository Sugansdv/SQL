
CREATE DATABASE IF NOT EXISTS shopping_cart_system;
USE shopping_cart_system;

-- Create tables
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0)
);

CREATE TABLE cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity BETWEEN 1 AND 10),
    added_date DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date DATETIME DEFAULT NOW(),
    total_price DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Drop & re-add uniqueness constraint on cart (user-product combo)
ALTER TABLE cart_items DROP INDEX user_product_unique;

-- Re-add
ALTER TABLE cart_items ADD UNIQUE INDEX user_product_unique (user_id, product_id);

-- Delete abandoned carts older than 7 days
DELETE FROM cart_items
WHERE added_date < NOW() - INTERVAL 7 DAY;

-- Transaction: Place order, update stock, clear cart
START TRANSACTION;

SET @user_id = 1;

-- Calculate total
SELECT SUM(p.price * c.quantity) INTO @total_price
FROM cart_items c
JOIN products p ON c.product_id = p.product_id
WHERE c.user_id = @user_id;

-- Insert order
INSERT INTO orders (user_id, total_price)
VALUES (@user_id, @total_price);

-- Update stock
UPDATE products p
JOIN cart_items c ON p.product_id = c.product_id
SET p.stock = p.stock - c.quantity
WHERE c.user_id = @user_id;

-- Rollback if stock < 0
SELECT COUNT(*) INTO @invalid_stock
FROM products WHERE stock < 0;

-- Conditional rollback or commit
DELIMITER //

CREATE PROCEDURE PlaceOrder(IN input_user_id INT)
BEGIN
    DECLARE total_price DECIMAL(10,2);
    DECLARE invalid_stock_count INT DEFAULT 0;

    START TRANSACTION;

    -- Calculate total price
    SELECT SUM(p.price * c.quantity)
    INTO total_price
    FROM cart_items c
    JOIN products p ON c.product_id = p.product_id
    WHERE c.user_id = input_user_id;

    -- Insert order
    INSERT INTO orders (user_id, total_price)
    VALUES (input_user_id, total_price);

    -- Update stock
    UPDATE products p
    JOIN cart_items c ON p.product_id = c.product_id
    SET p.stock = p.stock - c.quantity
    WHERE c.user_id = input_user_id;

    -- Check for invalid stock
    SELECT COUNT(*) INTO invalid_stock_count
    FROM products
    WHERE stock < 0;

    -- Conditional commit or rollback
    IF invalid_stock_count > 0 THEN
        ROLLBACK;
    ELSE
        DELETE FROM cart_items WHERE user_id = input_user_id;
        COMMIT;
    END IF;
END //

DELIMITER ;

-- Call the procedure
CALL PlaceOrder(1);  -- Replace 1 with actual user_id

