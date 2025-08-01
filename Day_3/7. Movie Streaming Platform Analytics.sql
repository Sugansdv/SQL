CREATE DATABASE movie_analytics_db;
USE movie_analytics_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100),
    subscription_id INT
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    price DECIMAL(8,2),
    duration_months INT
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    duration INT  -- in minutes
);

CREATE TABLE views (
    view_id INT PRIMARY KEY,
    user_id INT,
    movie_id INT,
    watch_time INT,  -- in minutes
    view_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

INSERT INTO subscriptions VALUES
(1, 'Basic', 199.00, 1),
(2, 'Premium', 399.00, 1),
(3, 'Family', 599.00, 1);

INSERT INTO users VALUES
(1, 'Alice', 'alice@example.com', 2),
(2, 'Bob', 'bob@example.com', 1),
(3, 'Charlie', 'charlie@example.com', 2),
(4, 'David', 'david@example.com', NULL),
(5, 'Eva', 'eva@example.com', 3);

INSERT INTO movies VALUES
(101, 'Star Journey', 'Sci-Fi', 120),
(102, 'Love Forever', 'Romance', 95),
(103, 'Dark Hunt', 'Thriller', 110),
(104, 'Ocean’s End', 'Adventure', 130),
(105, 'Star Clash', 'Sci-Fi', 140);

INSERT INTO views VALUES
(1, 1, 101, 120, '2025-07-01'),
(2, 1, 103, 110, '2025-07-05'),
(3, 2, 102, 95, '2025-07-03'),
(4, 3, 101, 115, '2025-07-10'),
(5, 5, 105, 140, '2025-07-12'),
(6, 5, 105, 135, '2025-07-15'),
(7, 5, 105, 130, '2025-07-18'),
(8, 5, 105, 120, '2025-07-20'),
(9, 5, 105, 125, '2025-07-22'),
(10, 5, 105, 130, '2025-07-24');


-- 1. Total views per movie
SELECT m.title, COUNT(v.view_id) AS total_views
FROM movies m
JOIN views v ON m.movie_id = v.movie_id
GROUP BY m.title;

-- 2. Average watch time per genre (AVG)
SELECT genre, AVG(watch_time) AS avg_watch_time
FROM movies m
JOIN views v ON m.movie_id = v.movie_id
GROUP BY genre;

-- 3. Movies with more than 500 views (HAVING)
SELECT m.title, COUNT(v.view_id) AS total_views
FROM movies m
JOIN views v ON m.movie_id = v.movie_id
GROUP BY m.title
HAVING COUNT(v.view_id) > 500;

-- 4. INNER JOIN views and movies
SELECT v.view_id, u.name, m.title, v.watch_time
FROM views v
JOIN users u ON v.user_id = u.user_id
JOIN movies m ON v.movie_id = m.movie_id;

-- 5. LEFT JOIN: users and subscriptions
SELECT u.user_id, u.name, s.plan_name
FROM users u
LEFT JOIN subscriptions s ON u.subscription_id = s.subscription_id;

-- 6. SELF JOIN on users to find friends with the same subscription plan
SELECT u1.name AS user1, u2.name AS user2, s.plan_name
FROM users u1
JOIN users u2 ON u1.subscription_id = u2.subscription_id AND u1.user_id < u2.user_id
JOIN subscriptions s ON u1.subscription_id = s.subscription_id;
