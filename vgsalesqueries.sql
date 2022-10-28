
--Check the data for integrity
SELECT * FROM vgsalesratings..games
ORDER BY Global_Sales DESC


--Dividing the Critic_Score by 10 to make it consistent with the User_Score
UPDATE vgsalesratings..games
SET Critic_Score = Critic_Score / 10
WHERE Critic_Score IS NOT NULL
or Critic_Score <> ' '


--Change platform name from 2600 to Atari
UPDATE vgsalesratings..platform
SET platform = 'Atari 2600'
WHERE platform = '2600'


--What are the verdicts for the games by Critics and Users
SELECT Name, 
CASE 
WHEN Critic_Score = 10 THEN 'Perfect'
WHEN Critic_Score > 9 AND Critic_Score < 9.9 THEN 'Amazing'
WHEN Critic_Score > 8 AND Critic_Score < 8.9 THEN 'Great'
WHEN Critic_Score > 7 AND Critic_Score < 7.9 THEN 'Good'
WHEN Critic_Score > 6 AND Critic_Score < 6.9 THEN 'Decent'
WHEN Critic_Score > 5 AND Critic_Score < 5.9 THEN 'Fair'
WHEN Critic_Score < 5 THEN 'Bad'
ELSE 'No Score'
END AS ' Critics Verdict',
CASE 
WHEN User_Score = 10 THEN 'Perfect'
WHEN User_Score > 9 AND User_Score < 9.9 THEN 'Amazing'
WHEN User_Score > 8 AND User_Score < 8.9 THEN 'Great'
WHEN User_Score > 7 AND User_Score < 7.9 THEN 'Good'
WHEN User_Score > 6 AND User_Score < 6.9 THEN 'Decent'
WHEN User_Score > 5 AND User_Score < 5.9 THEN 'Fair'
WHEN Critic_Score < 5 THEN 'Bad'
ELSE 'No Score'
END AS 'User Verdict'
FROM vgsalesratings..games
ORDER BY Global_Sales DESC


--Developers with the highest among Critics
SELECT p.Publisher, 
ROUND(AVG(g.Critic_Score), 2) AS AVG_Critic_Score
FROM vgsalesratings..games g
INNER JOIN vgsalesratings..publishers p
ON p.PublisherID = g.PublisherID
WHERE
g.Critic_Count > 10 AND
g.Critic_Score IS NOT NULL AND
g.User_Score IS NOT NULL
GROUP BY p.Publisher
ORDER BY AVG_Critic_Score DESC


--Developers with the highest rating among Users
SELECT p.Publisher, 
ROUND(AVG(g.User_Score), 2) as AVG_User_Score
FROM vgsalesratings..games g
INNER JOIN vgsalesratings..publishers p
ON p.PublisherID = g.PublisherID
WHERE
g.User_Count > 10 AND
g.Critic_Score IS NOT NULL AND
g.User_Score IS NOT NULL
GROUP BY p.Publisher
ORDER BY AVG_User_Score DESC


--which age rating makes more sales
SELECT r.Rating, 
ROUND(SUM(g.Global_Sales), 2) as Global_Sales_Sum
FROM vgsalesratings..games g
INNER JOIN vgsalesratings..ratings r
ON g.RatingsID = r.RatingsID
GROUP BY r.Rating
ORDER BY Global_Sales_Sum


--best selling games in japan
SELECT g.Name, p.Platform, g.JP_Sales 
FROM vgsalesratings..games g
JOIN vgsalesratings..platform p
ON g.PlatformID = p.PlatformID
ORDER BY g.JP_Sales DESC

--best selling games in NA
SELECT g.Name, p.Platform, g.NA_Sales 
FROM vgsalesratings..games g
JOIN vgsalesratings..platform p
ON g.PlatformID = p.PlatformID
ORDER BY g.NA_Sales DESC


--grabbing top 10 games by global sales
SELECT TOP(10) g.Name, g.Global_Sales, g.Critic_Score, g.User_Score
FROM vgsalesratings..games g
ORDER BY Global_Sales DESC



--CTE Query on Action Games
WITH actioncte 
AS(
SELECT g.Name, ge.Genre, g.Global_Sales,g.Critic_Score,g.PublisherID
FROM vgsalesratings..games g
INNER JOIN vgsalesratings..genre ge
ON g.GenreID = ge.GenreID
WHERE Genre = 'Action' AND Global_Sales IS NOT NULL)

SELECT a.Name, p.Publisher, a.Genre, a.Global_Sales
FROM actioncte a
JOIN vgsalesratings..publishers p
ON a.PublisherID = p.PublisherID
ORDER BY Global_Sales DESC



--trial rownumber
WITH topcte 
AS(
SELECT y.Year, g.Name, g.Global_Sales, 
ROW_NUMBER() OVER(
PARTITION BY y.Year 
ORDER BY g.Global_Sales DESC) AS rank
FROM vgsalesratings..games g
JOIN vgsalesratings..year y
ON g.YearID = y.YearID)
SELECT TOP 3 *
FROM topcte
WHERE topcte.rank between 3 and 5