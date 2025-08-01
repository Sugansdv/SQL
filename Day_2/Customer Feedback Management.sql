CREATE DATABASE customer_feedback;

USE customer_feedback;

-- Table: feedback: feedback_id, customer_name, rating, comment, product, submitted_date
CREATE TABLE feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    rating INT,
    comment TEXT,
    product VARCHAR(100),
    submitted_date DATE
);

INSERT INTO feedback (customer_name, rating, comment, product, submitted_date) VALUES
('Alice', 5, 'Excellent performance!', 'Smartphone', CURDATE() - INTERVAL 5 DAY),
('Bob', 4, 'Camera is slow to focus.', 'Smartphone', CURDATE() - INTERVAL 10 DAY),
('Charlie', 3, 'Not satisfied', 'Laptop', CURDATE() - INTERVAL 20 DAY),
('Diana', 5, NULL, 'Smartwatch', CURDATE() - INTERVAL 15 DAY),
('Ethan', 2, 'Very slow and laggy', 'Smartphone', CURDATE() - INTERVAL 40 DAY),
('Fiona', 4, 'Great battery life!', 'Smartphone', CURDATE() - INTERVAL 3 DAY),
('George', 5, 'Slow software updates', 'Smartphone', CURDATE() - INTERVAL 25 DAY);

-- 1. Retrieve feedback with rating >= 4 for product "Smartphone"
SELECT customer_name, rating, comment
FROM feedback
WHERE rating >= 4 AND product = 'Smartphone';

-- 2. Use LIKE to find comments with the word "slow"
SELECT feedback_id, customer_name, comment
FROM feedback
WHERE comment LIKE '%slow%';

-- 3. Use BETWEEN for dates within the last 30 days
SELECT customer_name, product, submitted_date
FROM feedback
WHERE submitted_date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE();

-- 4. Identify NULL comments
SELECT feedback_id, customer_name, product
FROM feedback
WHERE comment IS NULL;

-- 5. Use DISTINCT to list reviewed products
SELECT DISTINCT product
FROM feedback;

-- 6. Sort by rating DESC, then submitted_date DESC
SELECT customer_name, rating, comment, product, submitted_date
FROM feedback
ORDER BY rating DESC, submitted_date DESC;
