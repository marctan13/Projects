--Data grabbed from https://data.cityofnewyork.us/Health/DOHMH-Dog-Bite-Data/rsgh-akpg/data then split age column into two with the indicators separated on excel.

--Change type of DateOfBite to date from datetime
ALTER TABLE Dogbites
ALTER COLUMN DateOfBite date;


SELECT *
FROM portfolio_projects..Dogbites


-- Number of cases per Borough
SELECT
Borough,
COUNT(UniqueID) AS NumberOfBites
FROM portfolio_projects.dbo.Dogbites
GROUP BY Borough
ORDER BY COUNT(UniqueID) DESC;

--Queens has the most cases of dog bites followed by Manhattan and Brooklyn

--cases by gender
SELECT 
Gender,
COUNT(UniqueID) AS NumberOfCases
FROM portfolio_projects.dbo.Dogbites
GROUP BY Gender;

--Most of the recorded cases were not able to identify the gender of the dog

--cases by year
SELECT DATEPART(Year, DateOfBite) AS YearOfBite,
COUNT(UniqueID) as NumberofCases
FROM portfolio_projects.dbo.Dogbites
GROUP BY DATEPART(Year, DateOfBite)
ORDER BY DATEPART(Year, DateOfBite);

--cases by month
SELECT DATENAME(Month, DateOfBite) AS Month,
COUNT(UniqueID) AS NumberOfCases
FROM portfolio_projects.dbo.Dogbites
GROUP BY DATENAME(Month, DateOfBite)
Order BY DATENAME(Month, DateOfBite);

--cases by date
SELECT DateOfBite,
COUNT(UniqueID) AS NumberOfCases
FROM portfolio_projects.dbo.Dogbites
GROUP BY DateOfBite
ORDER BY DateOfBite;


--cases by breed
SELECT TOP(30)
COUNT(UniqueID) AS NumberOfBreed, Breed
FROM portfolio_projects.dbo.Dogbites
GROUP BY Breed
ORDER BY COUNT(UniqueID) DESC;

--A lot of the value in the column are either unknown or null

SELECT *
FROM portfolio_projects.dbo.Dogbites
WHERE Breed =  ' ';

SELECT TOP(30)
COUNT(UniqueID) AS NumberOfBreed, Breed
FROM portfolio_projects.dbo.Dogbites
WHERE BREED != ' '
GROUP BY Breed
ORDER BY COUNT(UniqueID) DESC;

--Pitbulls are the most common breed that has been reported for dog bites. While most of the cases are unidentified

--cases by SpayNeuter

SELECT COUNT(UniqueID) AS NumberofCases,
SpayNeuter
FROM portfolio_projects.dbo.Dogbites
GROUP BY SpayNeuter;