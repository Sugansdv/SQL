CREATE DATABASE IF NOT EXISTS MovieStreamingDB;

USE MovieStreamingDB;

CREATE TABLE genres (
  genre_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE movies (
  movie_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  genre_id INT,
  release_year INT,
  FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  signup_date DATE
);

CREATE TABLE subscriptions (
  subscription_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  plan VARCHAR(50),
  start_date DATE,
  end_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE watch_history (
  watch_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  movie_id INT,
  watch_date DATETIME,
  duration_watched INT, -- in minutes
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

INSERT INTO genres (name) VALUES ('Action'), ('Drama'), ('Comedy');

INSERT INTO movies (title, genre_id, release_year) VALUES
('Action Movie 1', 1, 2020),
('Drama Movie 1', 2, 2021),
('Comedy Movie 1', 3, 2022);

INSERT INTO users (name, email, signup_date) VALUES
('Alice', 'alice@example.com', '2022-01-01'),
('Bob', 'bob@example.com', '2022-02-01'),
('Charlie', 'charlie@example.com', '2022-03-01');

INSERT INTO subscriptions (user_id, plan, start_date, end_date) VALUES
(1, 'Premium', '2023-01-01', '2024-01-01'),
(2, 'Basic', '2023-06-01', '2024-06-01'),
(3, 'Premium', '2023-03-01', '2024-03-01');

INSERT INTO watch_history (user_id, movie_id, watch_date, duration_watched) VALUES
(1, 1, '2023-08-01 10:00:00', 120),
(1, 2, '2023-08-03 14:30:00', 90),
(2, 3, '2023-08-02 16:00:00', 80),
(3, 1, '2023-08-04 18:00:00', 110),
(1, 3, '2023-08-06 20:00:00', 100);

-- Create indexes for performance
CREATE INDEX idx_movie_id ON watch_history(movie_id);
CREATE INDEX idx_user_id ON watch_history(user_id);
CREATE INDEX idx_watch_date ON watch_history(watch_date);

-- Use EXPLAIN to optimize a query: total watch time by user
EXPLAIN
SELECT user_id, SUM(duration_watched) AS total_minutes
FROM watch_history
GROUP BY user_id;

-- Subquery for users watching the most movies in a week
SELECT user_id, COUNT(*) AS movies_watched
FROM watch_history
WHERE watch_date BETWEEN '2023-08-01' AND '2023-08-07'
GROUP BY user_id
HAVING movies_watched = (
  SELECT MAX(movie_count) FROM (
    SELECT user_id, COUNT(*) AS movie_count
    FROM watch_history
    WHERE watch_date BETWEEN '2023-08-01' AND '2023-08-07'
    GROUP BY user_id
  ) AS weekly_counts
);

-- Denormalize into a monthly user engagement report table

CREATE TABLE monthly_engagement (
  user_id INT,
  month_year VARCHAR(7), -- Format: YYYY-MM
  total_minutes INT,
  movies_watched INT
);

-- Populate the denormalized table (example for August 2023)
INSERT INTO monthly_engagement (user_id, month_year, total_minutes, movies_watched)
SELECT
  user_id,
  '2023-08' AS month_year,
  SUM(duration_watched) AS total_minutes,
  COUNT(*) AS movies_watched
FROM watch_history
WHERE watch_date BETWEEN '2023-08-01' AND '2023-08-31'
GROUP BY user_id;

-- Use LIMIT to show top 10 most-watched movies (by total watch count)

SELECT m.title, COUNT(w.watch_id) AS watch_count
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
GROUP BY w.movie_id
ORDER BY watch_count DESC
LIMIT 10;
