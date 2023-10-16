-- Rolling Stones UK discography -- Based on information taken from Wikipedia
CREATE DATABASE rolling_stones;
USE rolling_stones;
CREATE TABLE rs_discography
	(album_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50) NOT NULL,
	release_date DATE,
    number_of_tracks TINYINT UNSIGNED,
    ALLMUSIC_rating DECIMAL (2,1),
    US_sales INT)
;
INSERT INTO rs_discography (title, release_date, number_of_tracks, ALLMUSIC_rating, US_sales) 
VALUES
('The Rolling Stones','1964-04-16',12, 4.5, 500000),
('The Rolling Stones No. 2','1965-01-15',12, 4.5, NULL),
('Out of Our Heads','1965-07-30',12, 4.5, 1000000),
('Aftermath','1966-04-15',14, 5.0, 1000000),
('Between the Buttons','1967-01-20',12, 5.0, 500000),
('Their Satanic Majesties Request','1967-12-08',10, 4.0, 500000),
('Beggars Banquet','1968-12-06',10, 5.0, 1000000),
('Let It Bleed','1969-11-28',9, 5.0, 2000000),
('Sticky Fingers','1971-04-23',10, 5.0, 3000000),
('Exile on Main St.','1972-05-12',18, 5.0, 1000000),
('Goats Head Soup','1973-08-31',10, 3.5, 3000000),
('It\'s Only Rock \'n Roll','1974-10-18',10, 3.5, 1000000),
('Black and Blue','1976-04-23',8, 3.0, 1000000),
('Some Girls','1978-06-09',10, 5.0, 6000000),
('Emotional Rescue','1980-06-20',10, 3.0, 2000000),
('Tattoo You','1981-08-24',11, 4.5, 4000000),
('Undercover','1983-11-07',10, 3.5, 1000000),
('Dirty Work','1986-03-24',11, 3.0, 1000000),
('Steel Wheels','1989-08-25',12, 3.0, 2000000),
('Voodoo Lounge','1994-07-11',15, 3.5, 2000000),
('Bridges to Babylon','1997-09-29',13, 3.0, 1160000),
('A Bigger Bang','2005-09-06',16, 4.0, 1000000),
('Blue & Lonesome','2016-12-02',12, 4.5, NULL)
;
-- display table
SELECT * FROM rs_discography;
-- display total sales
SELECT FORMAT(SUM(US_sales),0) AS total_sales_USA FROM rs_discography;
-- display releases per year
SELECT YEAR(release_date) AS year, COUNT(*) AS releases_count FROM rs_discography GROUP BY year;
-- display only summer releases
SELECT title, release_date FROM rs_discography
	WHERE MONTH(release_date) IN (06,07,08)
;
-- display average albums rating per period
SELECT
	CASE
	WHEN YEAR(release_date) BETWEEN 1964 AND 1969 then '60\'s'
	WHEN YEAR(release_date) BETWEEN 1970 AND 1979 then '70\'s'
	WHEN YEAR(release_date) BETWEEN 1980 AND 1989 then '80\'s'
	WHEN YEAR(release_date) BETWEEN 1990 AND 1999 then '90\'s'
	ELSE '2000\'s'
END AS period,
	AVG(ALLMUSIC_rating) AS avg_rating,
    COUNT(*) AS album_per_period
	FROM rs_discography
	GROUP BY period
;
-- use ROLLUP to display total ratings average and total releases count
SELECT YEAR(release_date) AS release_year, AVG(ALLMUSIC_rating) AS annual_rating, COUNT(*) AS releases_per_year
	FROM rs_discography
    GROUP BY YEAR(release_date)
    WITH ROLLUP
;
-- average annual albums rating per year in the 1960's and a total average rating for albums in that decade
SELECT release_year, AVG(ALLMUSIC_rating) AS annual_rating, COUNT(*) AS albums_per_year
FROM (
    SELECT YEAR(release_date) AS release_year, ALLMUSIC_rating
    FROM rs_discography
    WHERE YEAR(release_date) BETWEEN 1964 AND 1969
) AS sixties
GROUP BY release_year WITH ROLLUP;