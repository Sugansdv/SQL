CREATE DATABASE gym_db;

USE gym_db;

CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    duration_months INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE NOT NULL
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    trainer_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);

SHOW TABLES;

INSERT INTO plans (name, duration_months, price) VALUES
('Basic', 1, 49.99),
('Standard', 3, 129.99),
('Premium', 6, 239.99),
('Yearly', 12, 449.99),
('Weekend Only', 3, 89.99);

INSERT INTO trainers (name, specialization) VALUES
('Alex Turner', 'Strength'),
('Bella Stone', 'Cardio'),
('Chris Vega', 'Flexibility');

INSERT INTO members (name, email, join_date) VALUES
('Alice Johnson', 'alice@gym.com', '2025-07-01'),
('Bob Smith', 'bob@gym.com', '2025-06-15'),
('Charlie Lee', 'charlie@gym.com', '2025-06-20'),
('Daisy Green', 'daisy@gym.com', '2025-07-10'),
('Ethan Ford', 'ethan@gym.com', '2025-07-15'),
('Fiona Adams', 'fiona@gym.com', '2025-06-25'),
('George Miles', 'george@gym.com', '2025-07-05'),
('Hannah Cole', 'hannah@gym.com', '2025-06-30'),
('Ian Hill', 'ian@gym.com', '2025-07-12'),
('Julia Ray', 'julia@gym.com', '2025-07-18');

INSERT INTO subscriptions (member_id, plan_id, trainer_id, start_date, end_date) VALUES
(1, 1, 1, '2025-07-01', '2025-07-31'),
(2, 2, 2, '2025-06-15', '2025-09-15'),
(3, 3, 3, '2025-06-20', '2025-12-20'),
(4, 2, 1, '2025-07-10', '2025-10-10'),
(5, 1, 2, '2025-07-15', '2025-08-15'),
(6, 4, 3, '2025-06-25', '2026-06-25'),
(7, 5, 1, '2025-07-05', '2025-10-05'),
(8, 1, 3, '2025-06-30', '2025-07-30'),
(9, 2, 2, '2025-07-12', '2025-10-12'),
(10, 3, 2, '2025-07-18', '2026-01-18');

UPDATE subscriptions
SET plan_id = 3
WHERE member_id = 1;


DELETE FROM subscriptions
WHERE subscription_id IN (
    SELECT s.subscription_id
    FROM (
        SELECT subscription_id
        FROM subscriptions
        WHERE end_date < CURDATE()
    ) AS s
);

