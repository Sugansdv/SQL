CREATE DATABASE IF NOT EXISTS crm_system;
USE crm_system;


CREATE TABLE leads (
    lead_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'new',
    created_at DATE
);


CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    converted_from_lead INT,
    FOREIGN KEY (converted_from_lead) REFERENCES leads(lead_id)
);

CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2),
    sale_date DATE ,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE followups (
    followup_id INT AUTO_INCREMENT PRIMARY KEY,
    lead_id INT,
    followup_date DATE,
    followup_count INT CHECK (followup_count <= 5),
    FOREIGN KEY (lead_id) REFERENCES leads(lead_id) ON DELETE CASCADE
);

-- Insert lead with UNIQUE phone/email (Already enforced by schema)
INSERT INTO leads (name, phone, email) 
VALUES ('Alice', '9876543210', 'alice@example.com');

-- Update lead status after conversion
UPDATE leads SET status = 'converted' WHERE lead_id = 1;

-- Delete leads older than 1 year
DELETE FROM leads WHERE created_at < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Drop and reapply FOREIGN KEY on sales
ALTER TABLE sales DROP FOREIGN KEY sales_ibfk_1;
ALTER TABLE sales ADD CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Transaction: Convert lead to customer + log sale

DELIMITER //
CREATE PROCEDURE ConvertLeadToCustomerAndSale(
  IN lead_id_input INT,
  IN sale_amount DECIMAL(10,2)
)
BEGIN
  DECLARE lead_name VARCHAR(100);
  DECLARE lead_phone VARCHAR(15);
  DECLARE lead_email VARCHAR(100);
  DECLARE customer_id_new INT;

  START TRANSACTION;

  -- Get lead data
  SELECT name, phone, email INTO lead_name, lead_phone, lead_email
  FROM leads WHERE lead_id = lead_id_input;

  -- Insert into customers
  INSERT INTO customers (name, phone, email, converted_from_lead)
  VALUES (lead_name, lead_phone, lead_email, lead_id_input);

  SET customer_id_new = LAST_INSERT_ID();

  -- Log sale
  INSERT INTO sales (customer_id, amount) VALUES (customer_id_new, sale_amount);

  -- Update lead status
  UPDATE leads SET status = 'converted' WHERE lead_id = lead_id_input;

  COMMIT;
END;
//
DELIMITER ;

-- Example call
-- CALL ConvertLeadToCustomerAndSale(1, 5000.00);

-- Sample followup insertion (CHECK constraint on count)
INSERT INTO followups (lead_id, followup_date, followup_count)
VALUES (1, CURDATE(), 3);
