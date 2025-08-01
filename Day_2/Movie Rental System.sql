CREATE DATABASE movie_rental;

USE movie_rental;

-- Table: movies: movie_id, title, genre, price, rating, available
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    price DECIMAL(5,2),
    rating DECIMAL(2,1),
    available BOOLEAN
);

INSERT INTO movies (title, genre, price, rating, available) VALUES
('Star Wars: A New Hope', 'Action', 150.00, 8.6, TRUE),
('Star Trek Beyond', 'Sci-Fi', 120.00, 7.0, TRUE),
('Mission Impossible', 'Thriller', 140.00, 7.9, TRUE),
('Romantic Sunset', 'Romance', 100.00, 6.5, TRUE),
('Star of the Night', 'Thriller', 130.00, NULL, FALSE),
('The Spy Who Loved Me', 'Action', 110.00, 7.3, TRUE),
('Star Warriors', 'Action', 160.00, NULL, TRUE);

-- List all available action or thriller movies.
SELECT title, genre, rating
FROM movies
WHERE available = TRUE AND genre IN ('Action', 'Thriller');

-- Show title, genre, and rating.

-- Use LIKE to find movies that contain “Star”.
SELECT title, genre, rating
FROM movies
WHERE title LIKE '%Star%';

-- Use IN for genre filtering

-- Identify movies with NULL ratings.
SELECT movie_id, title, genre, price
FROM movies
WHERE rating IS NULL;

-- Use DISTINCT to list genres.
SELECT DISTINCT genre
FROM movies;

-- Sort by rating DESC, then price ASC.
SELECT title, genre, rating, price
FROM movies
ORDER BY rating DESC, price ASC;
