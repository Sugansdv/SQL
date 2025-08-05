-- Create Database
CREATE DATABASE IF NOT EXISTS warehouse_inventory;
USE warehouse_inventory;

-- Create Table: suppliers
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(200)
);

-- Create Table: products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    stock INT DEFAULT 0
);

-- Create Table: batches
CREATE TABLE batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    manufactured_date DATE,
    expiry_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (expiry_date > manufactured_date)
);

-- Create Table: deliveries
CREATE TABLE deliveries (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    product_id INT,
    quantity INT,
    delivery_date DATE DEFAULT NULL,  
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert Sample Data
INSERT INTO suppliers (name, contact_info)
VALUES ('ABC Suppliers', 'abc@example.com'), ('XYZ Distributors', 'xyz@example.com');

INSERT INTO products (name, stock)
VALUES ('Detergent', 50), ('Toothpaste', 80);

-- Delete expired batches (Assume today is 2025-08-05)
DELETE FROM batches
WHERE expiry_date < CURDATE();

-- Drop and Re-add Foreign Key on deliveries (if needed)
ALTER TABLE deliveries DROP FOREIGN KEY deliveries_ibfk_1;
ALTER TABLE deliveries
ADD CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id);

-- Transaction — Register delivery and update stock
START TRANSACTION;

-- Validate supplier (will fail if invalid)
SET @supplier_id = 1;
SET @product_id = 1;
SET @quantity = 20;

-- Insert into deliveries
INSERT INTO deliveries (supplier_id, product_id, quantity)
VALUES (@supplier_id, @product_id, @quantity);

-- Update product stock
UPDATE products
SET stock = stock + @quantity
WHERE product_id = @product_id;

-- Insert a batch record (optional but realistic)
INSERT INTO batches (product_id, manufactured_date, expiry_date)
VALUES (@product_id, '2025-08-01', '2026-08-01');

COMMIT;
