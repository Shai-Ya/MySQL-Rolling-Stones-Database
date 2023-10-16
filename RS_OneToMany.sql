-- examples of one to many, CTE, views, window functions
USE rolling_stones;
-- ensure tracks with same name can not exist on one album
-- when an album is deleted, implement deletion of it's associated songs
CREATE TABLE rs_songs
	(song_id INT PRIMARY KEY AUTO_INCREMENT,
	track_title VARCHAR(50) NOT NULL, CONSTRAINT unique_t_per_a UNIQUE(track_title,alb_id),
	length_sec INT NOT NULL,
    writer VARCHAR(50),
	alb_id INT, FOREIGN KEY(alb_id) REFERENCES rs_discography(album_id) ON DELETE CASCADE)
;
-- describe table
DESC rs_songs;
INSERT INTO rs_songs (track_title, length_sec, alb_id) VALUES 
('Yesterday\'s Papers',140,5),
('My Obsession',200,5),
('Back Street Girl',202,5),
('Connection',133,5),
('She Smiled Sweetly',162,5),
('Cool, Calm & Collected',255,5),
('All Sold Out',135,5),
('Please Go Home',194,5),
('Who\'s Been Sleeping Here?',231,5),
('Complicated',198,5),
('Miss Amanda Jones',168,5),
('Something Happened to Me Yesterday',298,5),
('Sympathy for the Devil',378,7),
('No Expectations',236,7),
('Dear Doctor',208,7),
('Parachute Woman',140,7),
('Jigsaw Puzzle',366,7),
('Street Fighting Man',196,7),
('Prodigal Son',171,7),
('Stray Cat Blues',278,7),
('Factory Girl',129,7),
('Salt of the Earth',288,7),
('Gimme Shelter',271,8),
('Love in Vain',259,8),
('Country Honk',189,8),
('Live with Me',213,8),
('Let It Bleed',326,8),
('Midnight Rambler',412,8),
('You Got the Silver',171,8),
('Monkey Man',252,8),
('You Can\'t Always Get What You Want',448,8)
;
INSERT INTO rs_songs (track_title, length_sec, alb_id) VALUES 
('Sad Sad Sad',215,19),
('Mixed Emotions',278,19),
('Terrifying',293,19),
('Hold On to Your Hat',212,19),
('Hearts for Sale',280,19),
('Blinded by Love',277,19),
('Rock and a Hard Place',325,19),
('Can\'t Be Seen',249,19),
('Almost Hear You Sigh',277,19),
('Continental Drift',314,19),
('Break the Spell',186,19),
('Slipping Away',269,19),
('Flip the Switch',208,21),
('Anybody Seen My Baby?',271,21),
('Low Down',266,21),
('Already Over Me',324,21),
('Gunface',302,21),
('You Don\'t Have to Mean It',224,21),
('Out of Control',283,21),
('Saint of Me',315,21),
('Might as Well Get Juiced',323,21),
('Always Suffering',283,21),
('Too Tight',213,21),
('Thief in the Night',315,21),
('How Can I Stop',413,21)
;
-- non-album single
INSERT INTO rs_songs (track_title, length_sec, alb_id) VALUES 
('Jumpin\' Jack Flash', 222, NULL);
-- set same value in the 'writer' column exept certain cases
UPDATE rs_songs SET writer = 
	CASE
    WHEN track_title='Prodigal Son' THEN 'Wilkins'
    WHEN track_title='Love in Vain' THEN 'Johnson'
    WHEN track_title='Almost Hear You Sigh' THEN 'Jagger/Richards/Jordan'
    WHEN track_title='Anybody Seen My Baby?' THEN 'Jagger/Richards/Lang/Mink'
    WHEN track_title='Thief in the Night' THEN 'Jagger/Richards/Beauport'
    ELSE 'Jagger/Richards'
    END
;
-- display table
SELECT * FROM rs_songs;
-- display song with "you" in title
SELECT * FROM rs_songs
WHERE track_title LIKE '%you%';
-- display song with "love" OR "yesterday" in title
SELECT * FROM rs_songs
WHERE track_title REGEXP '\\b(love|yesterday)\\b';
-- display only cover songs
SELECT track_title, writer FROM rs_songs
WHERE writer NOT LIKE 'Jagger/Richards%';
-- format song duration as MM:SS, using FLOOR for minutes and MODULO for seconds. left pad both with '0' and concatenate
SELECT 
	track_title,
	CONCAT(LPAD(FLOOR(length_sec/60),2,0),':',LPAD((length_sec%60),2,0)) AS length
FROM rs_songs;
-- display songs along with their associated albums
SELECT
    track_title,
    writer,
    title AS album_title,
    CONCAT(LPAD(FLOOR(length_sec/60),2,0),':',LPAD((length_sec%60),2,0)) AS length,
    release_date
FROM rs_songs
	JOIN rs_discography
	ON rs_songs.alb_id=rs_discography.album_id
;
-- display all songs in database, including songs not associated with any album
SELECT
	track_title,
	IFNULL((title),'non-album-single') AS album_title,
	length_sec,
	release_date 
FROM rs_songs
	LEFT JOIN rs_discography
	ON rs_songs.alb_id=rs_discography.album_id
;
-- display an album duration in MM:SS format
SELECT
	title AS album,
	CONCAT(FLOOR(SUM(length_sec)/60),':',LPAD((SUM(length_sec)%60),2,0)) AS total_length
FROM rs_discography
	JOIN rs_songs
	ON rs_discography.album_id=rs_songs.alb_id
		WHERE album_id=21
        GROUP BY album_id
;
-- create VIEW for joined table
CREATE VIEW joined_albums AS 
	SELECT title AS album,
    release_date,
    SUM(length_sec) AS length
    FROM rs_discography
	JOIN rs_songs
		ON rs_discography.album_id=rs_songs.alb_id
    GROUP BY album_id
;
-- use joined_albums view to show albums total length
SELECT album,
    release_date,
    CONCAT(FLOOR(SUM(length)/60),':',LPAD((SUM(length)%60),2,0)) AS total_length
FROM joined_albums
GROUP BY album, release_date;
-- display duration differences compared to first album through the years
SELECT album, release_date,
	CONCAT(
		FLOOR(length/60),':',LPAD((length%60),2,0)
        ) AS album_duration,
	CONCAT(
		FLOOR((length - FIRST_VALUE(length) OVER(ORDER BY release_date))/60),':',
		LPAD((length - FIRST_VALUE(length) OVER(ORDER BY release_date))%60,2,0)
        ) AS dur_diff   
FROM joined_albums;
-- display album rating ranks by periods, partitioned by decades using a CTE.
WITH cte AS (
SELECT
	title, release_date, ALLMUSIC_rating,
	DENSE_RANK() OVER(PARTITION BY
    CASE
		WHEN YEAR(release_date) BETWEEN 1964 AND 1969 then '1960\'s'
		WHEN YEAR(release_date) BETWEEN 1970 AND 1979 then '1970\'s'
		WHEN YEAR(release_date) BETWEEN 1980 AND 1989 then '1980\'s'
		WHEN YEAR(release_date) BETWEEN 1990 AND 1999 then '1990\'s'
		ELSE '2000\'s'
        END
        ORDER BY ALLMUSIC_rating DESC)
    AS al_rank
	FROM rs_discography)
SELECT
	title,
    release_date,
    ALLMUSIC_rating,
    al_rank,
    CASE
		WHEN YEAR(release_date) BETWEEN 1964 AND 1969 then '1960\'s'
		WHEN YEAR(release_date) BETWEEN 1970 AND 1979 then '1970\'s'
		WHEN YEAR(release_date) BETWEEN 1980 AND 1989 then '1980\'s'
		WHEN YEAR(release_date) BETWEEN 1990 AND 1999 then '1990\'s'
		ELSE '2000\'s'
	END AS period
FROM cte;
