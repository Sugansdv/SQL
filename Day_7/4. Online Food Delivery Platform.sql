CREATE DATABASE IF NOT EXISTS food_delivery;
USE food_delivery;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(20)
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100),
    description TEXT,
    price DECIMAL(8,2),
    supplier_cost DECIMAL(8,2),
    stock INT
);

CREATE TABLE food_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    item_id INT,
    quantity INT,
    price DECIMAL(8,2),
    FOREIGN KEY (order_id) REFERENCES food_orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE delivery_queue (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    status VARCHAR(50) DEFAULT 'Pending',
    eta_time DATETIME,
    FOREIGN KEY (order_id) REFERENCES food_orders(order_id)
);

INSERT INTO customers (name, address, phone) VALUES
('Alice', '123 Main St', '9876543210'),
('Bob', '456 Park Ave', '9123456789');

INSERT INTO menu_items (item_name, description, price, supplier_cost, stock) VALUES
('Pizza', 'Cheesy crust pizza', 250.00, 150.00, 10),
('Burger', 'Chicken burger', 120.00, 70.00, 20),
('Pasta', 'Italian white sauce pasta', 180.00, 100.00, 15);

-- View for customers (hides supplier cost)
CREATE VIEW view_menu_items AS
SELECT item_id, item_name, description, price, stock
FROM menu_items;

--  Procedure to place order, deduct stock, return receipt
DELIMITER $$
CREATE PROCEDURE place_food_order(
    IN p_customer_id INT,
    IN p_items JSON,
    OUT p_order_id INT
)
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE total_items INT;
    DECLARE v_item_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(8,2);

    SET total_items = JSON_LENGTH(p_items);

    INSERT INTO food_orders (customer_id, total_amount) VALUES (p_customer_id, 0);
    SET p_order_id = LAST_INSERT_ID();

    WHILE i < total_items DO
        SET v_item_id = JSON_EXTRACT(p_items, CONCAT('$[', i, '].item_id'));
        SET v_quantity = JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity'));
        SELECT price INTO v_price FROM menu_items WHERE item_id = v_item_id;

        INSERT INTO order_items (order_id, item_id, quantity, price)
        VALUES (p_order_id, v_item_id, v_quantity, v_price);

        UPDATE menu_items SET stock = stock - v_quantity WHERE item_id = v_item_id;

        SET total = total + (v_price * v_quantity);
        SET i = i + 1;
    END WHILE;

    UPDATE food_orders SET total_amount = total WHERE order_id = p_order_id;
END$$
DELIMITER ;

-- Function to get delivery ETA
DELIMITER $$
CREATE FUNCTION get_delivery_eta(p_order_id INT)
RETURNS DATETIME
DETERMINISTIC
BEGIN
    RETURN (SELECT eta_time FROM delivery_queue WHERE order_id = p_order_id);
END$$
DELIMITER ;

-- Trigger to insert into delivery queue after placing an order
DELIMITER $$
CREATE TRIGGER after_order_placed
AFTER INSERT ON food_orders
FOR EACH ROW
BEGIN
    INSERT INTO delivery_queue (order_id, eta_time)
    VALUES (NEW.order_id, DATE_ADD(NOW(), INTERVAL 30 MINUTE));
END$$
DELIMITER ;

