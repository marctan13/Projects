Data is grabbed from Kaggle https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings


--Creating Dimension tables

--create dimension table year
CREATE TABLE year(YearID int PRIMARY KEY IDENTITY(1,1),Year int)

SELECT * FROM vgsalesratings..source

INSERT INTO vgsalesratings..year(Year)
SELECT DISTINCT Year_of_Release FROM vgsalesratings..source




--create dimension table platform
CREATE TABLE platform(
PlatformID int PRIMARY KEY IDENTITY(1,1),
Platform nvarchar(255))

INSERT INTO vgsalesratings..platform(Platform)
SELECT DISTINCT Platform FROM vgsalesratings..source


--create genre table
CREATE TABLE genre(
GenreID int PRIMARY KEY IDENTITY(1,1),
Genre nvarchar(255))

INSERT INTO vgsalesratings..genre(Genre)
SELECT DISTINCT Genre FROM vgsalesratings..source

--create ratings table

CREATE TABLE ratings(
RatingsID int PRIMARY KEY IDENTITY(1,1),
Rating nvarchar(255))

INSERT INTO vgsalesratings..ratings(Rating)
SELECT  DISTINCT Rating FROM vgsalesratings..source

SELECT * FROM vgsalesratings..ratings

--creat publishers table
CREATE TABLE publishers(
PublisherID int PRIMARY KEY IDENTITY(1,1),
Publisher nvarchar(255))

INSERT INTO vgsalesratings..publishers(Publisher, Developer)
SELECT DISTINCT Publisher FROM vgsalesratings..source


--create developers table
CREATE TABLE developers(
DeveloperID int PRIMARY KEY IDENTITY(1,1),
Developer nvarchar(255))


INSERT INTO vgsalesratings..developers(Developer)
SELECT DISTINCT Developer FROM vgsalesratings..source

--END making dimension tables



--adding id columns to source table
ALTER TABLE vgsalesratings..source
ADD YearID int,
GenreID int,
PublisherID int,
RatingsID int,
PlatformID int,
DeveloperID int


--fill values on the source table from the dimension tables
UPDATE vgsalesratings..source
SET vgsalesratings..source.YearID = vgsalesratings..year.YearID
FROM vgsalesratings..source
INNER JOIN vgsalesratings..year ON vgsalesratings..source.Year_of_Release = vgsalesratings..year.year


UPDATE vgsalesratings..source
SET vgsalesratings..source.GenreID = vgsalesratings..genre.GenreID
FROM vgsalesratings..source
INNER JOIN vgsalesratings..genre ON vgsalesratings..source.Genre = vgsalesratings..genre.Genre


UPDATE vgsalesratings..source
SET vgsalesratings..source.PlatformID = vgsalesratings..platform.PlatformID
FROM vgsalesratings..source
INNER JOIN vgsalesratings..platform ON vgsalesratings..source.Platform = vgsalesratings..platform.Platform


UPDATE vgsalesratings..source
SET vgsalesratings..source.RatingsID = vgsalesratings..ratings.RatingsID
FROM vgsalesratings..source
INNER JOIN vgsalesratings..ratings ON vgsalesratings..source.Rating = vgsalesratings..ratings.Rating


UPDATE vgsalesratings..source
SET vgsalesratings..source.PublisherID = vgsalesratings..publishers.PublisherID
FROM vgsalesratings..source
INNER JOIN vgsalesratings..publishers ON vgsalesratings..source.Publisher = vgsalesratings..publishers.Publisher

UPDATE vgsalesratings..source
SET vgsalesratings..source.DeveloperID = vgsalesratings..developers.DeveloperID
FROM vgsalesratings..source
INNER JOIN vgsalesratings..developers ON vgsalesratings..source.Developer = vgsalesratings..developers.Developer



--create fact table
CREATE TABLE games(
GameID int PRIMARY KEY IDENTITY(1,1),
Name nvarchar(255),
NA_Sales float,
EU_Sales float,
JP_Sales float,
Other_Sales float,
Global_Sales float,
Critic_Score float,
Critic_Count int,
User_Score float,
User_Count int,
YearID int FOREIGN KEY REFERENCES vgsalesratings..year(YearID),
GenreID int FOREIGN KEY REFERENCES vgsalesratings..genre(GenreID),
PublisherID int FOREIGN KEY REFERENCES vgsalesratings..publishers(PublisherID),
RatingsID int FOREIGN KEY REFERENCES vgsalesratings..ratings(RatingsID),
PlatformID int FOREIGN KEY REFERENCES vgsalesratings..platform(PlatformID),
DeveloperID int FOREIGN KEY REFERENCES vgsalesratings..developers(DeveloperID)
)


--fill values into fact table
INSERT INTO vgsalesratings..games(Name, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales, Critic_Score, Critic_Count,User_Score,User_Count,YearID, GenreID, PublisherID, RatingsID, PlatformID, DeveloperID)
SELECT Name, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales, Critic_Score, Critic_Count,User_Score,User_Count,YearID, GenreID, PublisherID, RatingsID, PlatformID, DeveloperID
FROM vgsalesratings..source

--end creating fact and dimenstion tables

