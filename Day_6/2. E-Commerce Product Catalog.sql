CREATE DATABASE ecommerce_catalog;
USE ecommerce_catalog;

-- Categories Table
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL
);

-- Suppliers Table
CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(100) NOT NULL
);

-- Products Table
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(150) NOT NULL,
  category_id INT,
  supplier_id INT,
  price DECIMAL(10, 2),
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Inventory Table
CREATE TABLE inventory (
  inventory_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  stock_quantity INT,
  last_updated DATE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Orders Table
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  order_date DATE,
  customer_name VARCHAR(100)
);

-- Order Items Table
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Design schema in 3NF; show how to denormalize into a reporting table

CREATE TABLE product_sales_report (
  product_id INT,
  product_name VARCHAR(150),
  total_quantity_sold INT,
  total_sales DECIMAL(10,2),
  PRIMARY KEY (product_id)
);

INSERT INTO product_sales_report (product_id, product_name, total_quantity_sold, total_sales)
SELECT 
  p.product_id,
  p.product_name,
  SUM(oi.quantity) AS total_quantity,
  SUM(oi.quantity * p.price) AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- Create indexes on product_name, category_id, supplier_id

CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_category_id ON products(category_id);
CREATE INDEX idx_supplier_id ON products(supplier_id);

-- Use EXPLAIN to optimize product search with filters

EXPLAIN SELECT * FROM products WHERE product_name LIKE '%Laptop%' AND category_id = 2;

-- Use a subquery to find products with the highest sales

SELECT 
  product_id, product_name
FROM products
WHERE product_id = (
  SELECT product_id
  FROM order_items
  GROUP BY product_id
  ORDER BY SUM(quantity) DESC
  LIMIT 1
);

-- Compare JOIN performance with and without indexing

-- With JOIN and indexes
EXPLAIN
SELECT 
  p.product_name,
  c.category_name,
  s.supplier_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id;


-- Use LIMIT for "Top 10 most ordered products" display

SELECT 
  p.product_id,
  p.product_name,
  SUM(oi.quantity) AS total_ordered
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_ordered DESC
LIMIT 10;
