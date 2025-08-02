CREATE DATABASE MusicStreaming;
USE MusicStreaming;

CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(100),
    artist_id INT,
    genre VARCHAR(50),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(100)
);

CREATE TABLE play_history (
    play_id INT PRIMARY KEY,
    user_id INT,
    song_id INT,
    play_time DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id)
);

INSERT INTO artists VALUES
(1, 'Taylor Swift'),
(2, 'Ed Sheeran'),
(3, 'Adele');

INSERT INTO songs VALUES
(1, 'Love Story', 1, 'Pop'),
(2, 'Shape of You', 2, 'Pop'),
(3, 'Someone Like You', 3, 'Ballad'),
(4, 'Crazy in Love', 1, 'R&B');

INSERT INTO users VALUES
(1, 'alice'),
(2, 'bob'),
(3, 'charlie');

INSERT INTO play_history VALUES
(1, 1, 1, NOW()),
(2, 1, 2, NOW()),
(3, 1, 4, NOW()),
(4, 2, 2, NOW()),
(5, 2, 2, NOW()),
(6, 2, 2, NOW()),
(7, 3, 1, NOW()),
(8, 3, 4, NOW()),
(9, 3, 4, NOW()),
(10, 3, 1, NOW());

-- Use JOIN to show who listened to which song.
SELECT 
    u.username,
    s.title AS song_title,
    a.name AS artist_name,
    ph.play_time
FROM play_history ph
JOIN users u ON ph.user_id = u.user_id
JOIN songs s ON ph.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id;

-- Use GROUP BY + COUNT() to get top songs.
SELECT 
    s.title,
    COUNT(*) AS play_count
FROM play_history ph
JOIN songs s ON ph.song_id = s.song_id
GROUP BY s.title
ORDER BY play_count DESC;

-- Use ORDER BY for most played artists.
SELECT 
    a.name AS artist_name,
    COUNT(*) AS total_plays
FROM play_history ph
JOIN songs s ON ph.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
GROUP BY a.name
ORDER BY total_plays DESC;

-- Use subquery to get users who listened to the same artist >10 times.
SELECT user_id, artist_id
FROM (
    SELECT 
        ph.user_id,
        s.artist_id,
        COUNT(*) AS plays
    FROM play_history ph
    JOIN songs s ON ph.song_id = s.song_id
    GROUP BY ph.user_id, s.artist_id
) AS sub
WHERE plays > 10;

-- Use CASE to label users as “Light”, “Moderate”, “Heavy” listeners.
SELECT 
    u.username,
    COUNT(*) AS total_plays,
    CASE
        WHEN COUNT(*) <= 3 THEN 'Light'
        WHEN COUNT(*) <= 6 THEN 'Moderate'
        ELSE 'Heavy'
    END AS listener_type
FROM play_history ph
JOIN users u ON ph.user_id = u.user_id
GROUP BY u.user_id, u.username;

-- Filter by LIKE '%Love%' for romantic songs.
SELECT title
FROM songs
WHERE title LIKE '%Love%';

