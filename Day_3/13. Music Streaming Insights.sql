CREATE DATABASE music_streaming_db;
USE music_streaming_db;

-- Table: artists
CREATE TABLE artists (
  artist_id INT PRIMARY KEY,
  name VARCHAR(100)
);

-- Table: songs
CREATE TABLE songs (
  song_id INT PRIMARY KEY,
  title VARCHAR(100),
  genre VARCHAR(50),
  duration INT, -- duration in seconds
  artist_id INT,
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- Table: listeners
CREATE TABLE listeners (
  listener_id INT PRIMARY KEY,
  name VARCHAR(100)
);

-- Artists
INSERT INTO artists VALUES
(1, 'Taylor Swift'),
(2, 'Ed Sheeran'),
(3, 'Adele');

-- Songs
INSERT INTO songs VALUES
(101, 'Love Story', 'Pop', 210, 1),
(102, 'Shape of You', 'Pop', 240, 2),
(103, 'Hello', 'Soul', 300, 3);

-- Listeners
INSERT INTO listeners VALUES
(1, 'Alice'), (2, 'Bob'), (3, 'Charlie'), (4, 'Diana');

-- Plays
INSERT INTO plays VALUES
(1, 101, 1, '2025-07-01 10:00:00', 200),
(2, 101, 2, '2025-07-01 10:30:00', 210),
(3, 102, 1, '2025-07-02 09:00:00', 240),
(4, 103, 3, '2025-07-02 12:00:00', 290),
(5, 102, 2, '2025-07-02 15:00:00', 240),
(6, 101, 4, '2025-07-03 08:00:00', 210),
(7, 102, 3, '2025-07-03 08:30:00', 230),
(8, 102, 4, '2025-07-04 08:30:00', 240),
(9, 102, 1, '2025-07-05 10:00:00', 240);

-- Total plays per song
SELECT s.title, COUNT(p.play_id) AS total_plays
FROM songs s
JOIN plays p ON s.song_id = p.song_id
GROUP BY s.title;

-- Average play duration per genre
SELECT s.genre, AVG(p.duration_played) AS avg_play_duration
FROM songs s
JOIN plays p ON s.song_id = p.song_id
GROUP BY s.genre;

-- Artists with songs played > 1,000 times
SELECT a.name AS artist_name, COUNT(p.play_id) AS total_plays
FROM artists a
JOIN songs s ON a.artist_id = s.artist_id
JOIN plays p ON s.song_id = p.song_id
GROUP BY a.name
HAVING COUNT(p.play_id) > 1000;

-- INNER JOIN: songs ↔ plays
SELECT s.title, p.play_time, p.duration_played
FROM songs s
INNER JOIN plays p ON s.song_id = p.song_id;

-- RIGHT JOIN: listeners ↔ plays (to include listeners even if no play record)
SELECT l.name AS listener_name, p.song_id, p.play_time
FROM listeners l
RIGHT JOIN plays p ON l.listener_id = p.listener_id;

-- SELF JOIN: listeners who play similar genres
SELECT DISTINCT l1.name AS listener1, l2.name AS listener2, s1.genre
FROM plays p1
JOIN songs s1 ON p1.song_id = s1.song_id
JOIN plays p2 ON s1.genre = (SELECT genre FROM songs WHERE song_id = p2.song_id)
  AND p1.listener_id < p2.listener_id
JOIN listeners l1 ON p1.listener_id = l1.listener_id
JOIN listeners l2 ON p2.listener_id = l2.listener_id;


-- Table: plays
CREATE TABLE plays (
  play_id INT PRIMARY KEY,
  song_id INT,
  listener_id INT,
  play_time DATETIME,
  duration_played INT, -- how long user played the song (in seconds)
  FOREIGN KEY (song_id) REFERENCES songs(song_id),
  FOREIGN KEY (listener_id) REFERENCES listeners(listener_id)
);

-- Artists
INSERT INTO artists VALUES
(1, 'Taylor Swift'),
(2, 'Ed Sheeran'),
(3, 'Adele');

-- Songs
INSERT INTO songs VALUES
(101, 'Love Story', 'Pop', 210, 1),
(102, 'Shape of You', 'Pop', 240, 2),
(103, 'Hello', 'Soul', 300, 3);

-- Listeners
INSERT INTO listeners VALUES
(1, 'Alice'), (2, 'Bob'), (3, 'Charlie'), (4, 'Diana');

-- Plays
INSERT INTO plays VALUES
(1, 101, 1, '2025-07-01 10:00:00', 200),
(2, 101, 2, '2025-07-01 10:30:00', 210),
(3, 102, 1, '2025-07-02 09:00:00', 240),
(4, 103, 3, '2025-07-02 12:00:00', 290),
(5, 102, 2, '2025-07-02 15:00:00', 240),
(6, 101, 4, '2025-07-03 08:00:00', 210),
(7, 102, 3, '2025-07-03 08:30:00', 230),
(8, 102, 4, '2025-07-04 08:30:00', 240),
(9, 102, 1, '2025-07-05 10:00:00', 240);

-- Total plays per song
SELECT s.title, COUNT(p.play_id) AS total_plays
FROM songs s
JOIN plays p ON s.song_id = p.song_id
GROUP BY s.title;

-- Average play duration per genre
SELECT s.genre, AVG(p.duration_played) AS avg_play_duration
FROM songs s
JOIN plays p ON s.song_id = p.song_id
GROUP BY s.genre;

-- Artists with songs played > 1,000 times
SELECT a.name AS artist_name, COUNT(p.play_id) AS total_plays
FROM artists a
JOIN songs s ON a.artist_id = s.artist_id
JOIN plays p ON s.song_id = p.song_id
GROUP BY a.name
HAVING COUNT(p.play_id) > 1000;

-- INNER JOIN: songs ↔ plays
SELECT s.title, p.play_time, p.duration_played
FROM songs s
INNER JOIN plays p ON s.song_id = p.song_id;

--  RIGHT JOIN: listeners ↔ plays (to include listeners even if no play record)
SELECT l.name AS listener_name, p.song_id, p.play_time
FROM listeners l
RIGHT JOIN plays p ON l.listener_id = p.listener_id;

--  SELF JOIN: listeners who play similar genres
SELECT DISTINCT l1.name AS listener1, l2.name AS listener2, s1.genre
FROM plays p1
JOIN songs s1 ON p1.song_id = s1.song_id
JOIN plays p2 ON s1.genre = (SELECT genre FROM songs WHERE song_id = p2.song_id)
  AND p1.listener_id < p2.listener_id
JOIN listeners l1 ON p1.listener_id = l1.listener_id
JOIN listeners l2 ON p2.listener_id = l2.listener_id;
