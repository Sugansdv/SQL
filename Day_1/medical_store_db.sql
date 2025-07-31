CREATE DATABASE medical_store_db;

USE medical_store_db;

CREATE TABLE medicines (
  medicine_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  category VARCHAR(50)
);

CREATE TABLE suppliers (
  supplier_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  contact VARCHAR(50)
);

CREATE TABLE stock (
  stock_id INT PRIMARY KEY AUTO_INCREMENT,
  medicine_id INT,
  supplier_id INT,
  batch_no VARCHAR(50),
  expiry_date DATE,
  quantity INT,
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE sales (
  sale_id INT PRIMARY KEY AUTO_INCREMENT,
  medicine_id INT,
  sale_date DATE,
  quantity_sold INT,
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

INSERT INTO medicines (name, category) VALUES
('Paracetamol', 'Painkiller'),
('Amoxicillin', 'Antibiotic'),
('Cetirizine', 'Antihistamine'),
('Ibuprofen', 'Painkiller');

INSERT INTO suppliers (name, contact) VALUES
('MediCorp', '9123456780'),
('HealthPlus', '9876543210'),
('PharmaLink', '9988776655');

INSERT INTO stock (medicine_id, supplier_id, batch_no, expiry_date, quantity) VALUES
(1, 1, 'B001', '2026-01-01', 100),
(2, 2, 'B002', '2025-10-10', 40),
(3, 3, 'B003', '2025-12-31', 20),
(4, 1, 'B004', '2025-09-15', 10),
(1, 2, 'B005', '2026-02-15', 30);

INSERT INTO sales (medicine_id, sale_date, quantity_sold) VALUES
(1, '2025-07-25', 15),
(2, '2025-07-26', 10),
(3, '2025-07-26', 5),
(1, '2025-07-27', 10),
(4, '2025-07-27', 3);

SELECT
  m.name AS medicine,
  s.batch_no,
  s.quantity,
  s.expiry_date
FROM stock s
JOIN medicines m ON s.medicine_id = m.medicine_id
WHERE s.quantity < 20
ORDER BY s.quantity ASC;

SELECT
  m.name AS medicine,
  SUM(s.quantity_sold) AS total_sold
FROM sales s
JOIN medicines m ON s.medicine_id = m.medicine_id
GROUP BY m.name
ORDER BY total_sold DESC;

SELECT
  sup.name AS supplier,
  m.name AS medicine,
  SUM(sl.quantity_sold) AS total_sold
FROM sales sl
JOIN medicines m ON sl.medicine_id = m.medicine_id
JOIN stock st ON m.medicine_id = st.medicine_id
JOIN suppliers sup ON st.supplier_id = sup.supplier_id
GROUP BY sup.name, m.name
ORDER BY sup.name, total_sold DESC;




