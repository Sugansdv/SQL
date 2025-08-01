CREATE DATABASE music_db;

USE music_db;

-- Table: albums: album_id, artist, genre, title, release_year, price
CREATE TABLE albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    artist VARCHAR(100),
    genre VARCHAR(50),
    title VARCHAR(100),
    release_year INT,
    price DECIMAL(8,2)
);

INSERT INTO albums (artist, genre, title, release_year, price) VALUES
('Miles Davis', 'Jazz', 'Kind of Blue', 1959, 699.00),
('Ludovico Einaudi', 'Classical', 'Elements', 2016, 799.00),
('Adele', 'Pop', '25', 2015, 899.00),
('Yo-Yo Ma', 'Classical', 'Bach: The Cello Suites', 2018, 849.00),
('Norah Jones', 'Jazz', 'Come Away with Me', 2002, 599.00),
('John Coltrane', 'Jazz', 'A Love Supreme', 2017, NULL),
('Taylor Swift', 'Pop', 'Lover', 2019, 999.00),
('Ella Fitzgerald', 'Jazz', 'Love Songs', 2020, 649.00);

-- Show albums in the genre 'Jazz' or 'Classical' released after 2015.
SELECT album_id, artist, genre, title, release_year, price
FROM albums
WHERE genre IN ('Jazz', 'Classical')
  AND release_year > 2015;

-- Select title, artist, and price.
SELECT title, artist, price
FROM albums;

-- Use DISTINCT to list all artists.
SELECT DISTINCT artist
FROM albums;

-- Use LIKE for album titles containing “Love”.
SELECT album_id, artist, genre, title, release_year, price
FROM albums
WHERE title LIKE '%Love%';

-- Handle albums with NULL price.
SELECT album_id, artist, genre, title, release_year
FROM albums
WHERE price IS NULL;

-- Sort by release_year DESC, title ASC.
SELECT album_id, artist, genre, title, release_year, price
FROM albums
ORDER BY release_year DESC, title ASC;
