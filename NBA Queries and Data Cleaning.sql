https://www.kaggle.com/datasets/drgilermo/nba-players-stats



SELECT * FROM nba..players
SELECT * FROM nba..player_data
SELECT * FROM nba..season_stats

--changing the column names for the table
EXEC sp_RENAME 'players.F1', 'player_id', 'COLUMN'
EXEC sp_RENAME 'players.born', 'birth_year', 'COLUMN'


--add identity column as primary key in player_data
ALTER TABLE nba..player_data
ADD player_id int PRIMARY KEY IDENTITY(1,1)


--change to primary key
ALTER TABLE nba..players
ALTER COLUMN player_id int NOT NULL;

ALTER TABLE nba..players
ADD CONSTRAINT pk_player_id PRIMARY KEY(player_id)






--adding a player_id and players_id column in season_stats
ALTER TABLE nba..season_stats
ADD player_id int,
ADD players_id int



--fill values in the new column on the season_stats table
UPDATE nba..season_stats
SET nba..season_stats.player_id = nba..player_data.player_id
FROM  nba..season_stats
INNER JOIN nba..player_data ON nba..season_stats.Player = nba..player_data.name


UPDATE nba..season_stats
SET nba..season_stats.players_id = nba..players.player_id
FROM  nba..season_stats
INNER JOIN nba..players ON nba..season_stats.Player = nba..players.Player

--alter to foreign key referencing player_data and players
ALTER TABLE nba..season_stats
ADD CONSTRAINT fk_player_id FOREIGN KEY(player_id) REFERENCES player_data(player_id)


ALTER TABLE nba..season_stats
ADD CONSTRAINT fk_players_id FOREIGN KEY(players_id) REFERENCES players(player_id)


--finding duplicate rows
DELETE FROM nba..player_data
WHERE player_id IN(
SELECT player_id FROM(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY pd.name, pd.year_start,pd.year_end ORDER BY pd.player_id) rn
FROM nba..player_data pd) x
WHERE x.rn > 1); --deleted 1 row

--found out there were two Jim Paxson in the NBA. Confirming here that they have different birthdates and likely to be father/son
SELECT *
FROM nba..player_data
WHERE name = 'Jim Paxson'


--There were many players that had the same name in the NBA
SELECT name, COUNT(name)
FROM nba..player_data
GROUP BY name
HAVING COUNT(name) > 1


--dropping the blank columns in season_stats
ALTER TABLE nba..season_stats
DROP COLUMN blanl, blank2


--Change from datetime to date in player_data
ALTER TABLE nba..player_data
ALTER COLUMN birth_date date;

--getting the players height by changing the data types first
ALTER TABLE player_data
ALTER COLUMN height date

ALTER TABLE player_data
ALTER COLUMN height nvarchar(255)

--getting the last 4 digits for their height
UPDATE player_data
SET height = RIGHT(height,4)

--replacing - with '
UPDATE nba..player_data
SET height = REPLACE(height, '-', ' '' ')

--there are 315 rows that have null values in the height column
SELECT COUNT(*)
FROM nba..player_data
WHERE height IS NULL



--check to see if rows would match between tables
SELECT s.Player, p.Player, pd.name, p.height, p.weight, pd.height, pd.weight,s.Tm, p.birth_city
FROM nba..season_stats AS s
INNER JOIN nba..players AS p ON s.players_id = p.player_id
INNER JOIN nba..player_data AS pd ON s.player_id = pd.player_id


SELECT s.Player, s.AST, p.birth_city
FROM nba..season_stats as s
INNER JOIN nba..players as p ON s.players_id = p.player_id
WHERE Year = 2015
ORDER BY s.AST DESC

--Players with the most assists per season
SELECT source.Player, source.Year, source.AST
FROM (
SELECT *, 
row_number() over (partition by stats.Year ORDER BY stats.AST DESC) AS seqnum
from nba..season_stats stats) source
where seqnum = 1

--Assist Leader in 2017
SELECT Year, AST, Player
FROM nba..season_stats
WHERE Year = 2017
ORDER BY AST DESC

--most points by player not in the hall of fame

SELECT pd.name, SUM(s.PTS) AS 'Total PTS'
FROM nba..season_stats as s
INNER JOIN nba..player_data as pd
ON pd.player_id = s.player_id
WHERE pd.name NOT LIKE '%*%'
GROUP BY pd.name
ORDER BY SUM(s.PTS) DESC

--scoring leader per team
--row_number()




--Scoring Leaders per Team
SELECT *
FROM(
SELECT s.Player, s.Tm, SUM(s.PTS) AS 'TotPts',
RANK() OVER(Partition BY s.Tm ORDER BY SUM(s.PTS) DESC) as rnk
FROM nba..season_stats s
GROUP BY s.Player, s.Tm) source
WHERE source.rnk = 1
AND Player IS NOT NULL;


--best 3pt% team in history
SELECT Tm, ROUND(AVG(CAST("3P%" AS float)), 3) as 'AVG_3PT%'
FROM nba..season_stats
WHERE "3P%" IS NOT NULL 
GROUP BY Tm
ORDER BY ROUND(AVG(CAST("3P%" AS float)), 3) DESC




--Leaders in each category
--Points
SELECT p.Player, SUM(s.PTS) as 'Total Points'
FROM nba..season_stats s
INNER JOIN nba..players p
ON s.players_id = p.player_id
GROUP BY p.Player
ORDER BY SUM(s.PTS) DESC

--Assists
SELECT p.Player, SUM(s.AST) as 'Total Assists'
FROM nba..season_stats s
INNER JOIN nba..players p
ON s.players_id = p.player_id
GROUP BY p.Player
ORDER BY SUM(s.AST) DESC

--Rebounds
SELECT p.Player, SUM(CAST(s.TRB AS int)) as 'Total Rebounds'
FROM nba..season_stats s
INNER JOIN nba..players p
ON s.players_id = p.player_id
GROUP BY p.Player
ORDER BY SUM(CAST(s.TRB AS int)) DESC

--Steals
SELECT p.Player, SUM(CAST(s.STL as int)) as 'Total Steals'
FROM nba..season_stats s
INNER JOIN nba..players p
ON s.players_id = p.player_id
GROUP BY p.Player
ORDER BY SUM(CAST(s.STL as int)) DESC

--Blocks
SELECT p.Player, SUM(CAST(s.Blk as int)) as 'Total Blocks'
FROM nba..season_stats s
INNER JOIN nba..players p
ON s.players_id = p.player_id
GROUP BY p.Player
ORDER BY SUM(CAST(s.Blk as int)) DESC


--highest Player avg 3pt%
SELECT Player, ROUND(AVG(CAST("3P%" AS float)), 3) as 'AVG_3PT%'
FROM nba..season_stats
WHERE "3P%" IS NOT NULL 
AND "3PA" > 100
GROUP BY Player
ORDER BY ROUND(AVG(CAST("3P%" AS float)), 3) DESC



--avg height and weight over the years
SELECT s.Year, AVG(CAST(p.height as int)) as avg_ht, AVG(CAST(p.weight as int)) as avg_wt
FROM nba..season_stats s
INNER JOIN nba..players p
ON p.player_id = s.players_id
GROUP BY Year
ORDER BY Year