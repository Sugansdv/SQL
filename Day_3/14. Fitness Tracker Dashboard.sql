CREATE DATABASE music_streaming;
USE music_streaming;

CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    duration INT, -- duration in seconds
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE listeners (
    listener_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE plays (
    play_id INT PRIMARY KEY,
    song_id INT,
    listener_id INT,
    play_time DATETIME,
    duration_played INT,
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
(1, 'Love Story', 'Pop', 240, 1),
(2, 'Perfect', 'Pop', 210, 2),
(3, 'Someone Like You', 'Soul', 300, 3),
(4, 'Blank Space', 'Pop', 250, 1),
(5, 'Photograph', 'Pop', 230, 2);

-- Listeners
INSERT INTO listeners VALUES
(1, 'Alice', 'alice@mail.com'),
(2, 'Bob', 'bob@mail.com'),
(3, 'Charlie', 'charlie@mail.com');

-- Plays
INSERT INTO plays VALUES
(1, 1, 1, '2025-07-01 10:00:00', 240),
(2, 2, 1, '2025-07-01 10:05:00', 210),
(3, 1, 2, '2025-07-01 10:10:00', 240),
(4, 3, 2, '2025-07-01 10:15:00', 300),
(5, 4, 3, '2025-07-01 10:20:00', 250),
(6, 1, 3, '2025-07-01 10:25:00', 240),
(7, 2, 2, '2025-07-01 10:30:00', 210),
(8, 2, 3, '2025-07-01 10:35:00', 210),
(9, 5, 1, '2025-07-01 10:40:00', 230),
(10, 5, 2, '2025-07-01 10:45:00', 230),
(11, 1, 1, '2025-07-01 10:50:00', 240),
(12, 1, 1, '2025-07-01 11:00:00', 240),
(13, 1, 2, '2025-07-01 11:10:00', 240),
(14, 1, 2, '2025-07-01 11:20:00', 240),
(15, 1, 3, '2025-07-01 11:30:00', 240);

-- 1. Total plays per song
SELECT s.title, COUNT(p.play_id) AS total_plays
FROM songs s
LEFT JOIN plays p ON s.song_id = p.song_id
GROUP BY s.title;

-- 2. Average play duration per genre
SELECT s.genre, AVG(p.duration_played) AS avg_play_duration
FROM songs s
JOIN plays p ON s.song_id = p.song_id
GROUP BY s.genre;

-- 3. Artists with songs played > 1,000 times (HAVING)
SELECT a.name AS artist_name, COUNT(p.play_id) AS total_song_plays
FROM artists a
JOIN songs s ON a.artist_id = s.artist_id
JOIN plays p ON s.song_id = p.song_id
GROUP BY a.artist_id, a.name
HAVING COUNT(p.play_id) > 1000;

-- 4. INNER JOIN: songs ↔ plays
SELECT p.play_id, s.title, p.play_time, p.duration_played
FROM plays p
INNER JOIN songs s ON p.song_id = s.song_id;

-- 5. RIGHT JOIN: listeners ↔ plays
SELECT l.name AS listener_name, p.song_id, p.play_time
FROM plays p
RIGHT JOIN listeners l ON p.listener_id = l.listener_id;

-- 6. SELF JOIN: listeners who play similar genres
SELECT DISTINCT l1.name AS listener1, l2.name AS listener2, s1.genre
FROM plays p1
JOIN songs s1 ON p1.song_id = s1.song_id
JOIN plays p2 ON s1.genre = (SELECT genre FROM songs WHERE song_id = p2.song_id)
JOIN songs s2 ON p2.song_id = s2.song_id
JOIN listeners l1 ON p1.listener_id = l1.listener_id
JOIN listeners l2 ON p2.listener_id = l2.listener_id
WHERE l1.listener_id < l2.listener_id
  AND s1.genre = s2.genre;

