CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    message TEXT
);

INSERT INTO customers (customer_name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- Create View: view_order_summary

CREATE VIEW view_order_summary AS
SELECT 
    o.order_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_name;

-- Create Stored Procedure place_order()
DELIMITER $$

CREATE PROCEDURE place_order(IN p_customer_id INT, IN p_items JSON)
BEGIN
    DECLARE v_order_id INT;
    DECLARE i INT DEFAULT 0;
    DECLARE total_items INT;

    START TRANSACTION;

    INSERT INTO orders (customer_id) VALUES (p_customer_id);
    SET v_order_id = LAST_INSERT_ID();
    SET total_items = JSON_LENGTH(p_items);

    WHILE i < total_items DO
        INSERT INTO order_items (order_id, product_name, quantity, price)
        VALUES (
            v_order_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].product_name'))),
            JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity')),
            JSON_EXTRACT(p_items, CONCAT('$[', i, '].price'))
        );
        SET i = i + 1;
    END WHILE;

    COMMIT;
END$$

DELIMITER ;

-- Call Stored Procedure with JSON Input
CALL place_order(1, '[
  {"product_name": "Shoes", "quantity": 2, "price": 49.99},
  {"product_name": "Hat", "quantity": 1, "price": 19.99}
]');

-- Create Function get_order_total(order_id)
DELIMITER $$

CREATE FUNCTION get_order_total(p_order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(quantity * price) INTO total
    FROM order_items
    WHERE order_id = p_order_id;
    RETURN total;
END$$

DELIMITER ;

SELECT get_order_total(1);

-- Trigger after_order_insert
DELIMITER $$

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (order_id, message)
    VALUES (NEW.order_id, CONCAT('Order placed for customer ID ', NEW.customer_id));
END$$

DELIMITER ;

-- Create Read-Only View for Employee Access
CREATE VIEW view_customer_readonly AS
SELECT customer_name, email
FROM customers;


