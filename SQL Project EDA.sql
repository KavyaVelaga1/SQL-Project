
select *
from vgsales;

-- MAX and MIN Functions
SELECT Name, MAX(Global_Sales) AS Max_Sales FROM vgsales;
SELECT Name, MIN(Global_Sales) AS Min_Sales FROM vgsales;

-- GROUP BY and ORDER BY Clauses
SELECT Genre, SUM(Global_Sales) AS Total_Sales 
FROM vgsales 
GROUP BY Genre;

SELECT Name, Year, Global_Sales 
FROM vgsales 
ORDER BY Year DESC;

-- WHERE Clause
SELECT * FROM vgsales 
WHERE Global_Sales > 20;

SELECT * FROM vgsales 
WHERE Year > 2000;

-- HAVING Clause
SELECT Platform, SUM(Global_Sales) AS Total_Sales 
FROM vgsales 
GROUP BY Platform 
HAVING SUM(Global_Sales) > 50;

-- Window Functions
SELECT Name, Platform, Global_Sales, 
       RANK() OVER (PARTITION BY Platform ORDER BY Global_Sales DESC) AS Rank
FROM vgsales;

SELECT Name, Global_Sales, 
       SUM(Global_Sales) OVER (ORDER BY Global_Sales DESC) AS Cumulative_Sales
FROM vgsales;

-- CTE (Common Table Expressions)
WITH Top_Games AS (
    SELECT Name, Genre, Global_Sales, 
           RANK() OVER (PARTITION BY Genre ORDER BY Global_Sales DESC) AS Genre_Rank
    FROM vgsales
)
SELECT * FROM Top_Games WHERE Genre_Rank <= 3;

-- Subqueries
SELECT Name, NA_Sales 
FROM vgsales 
WHERE NA_Sales = (SELECT MAX(NA_Sales) FROM vgsales);

SELECT Name, Platform, Global_Sales 
FROM vgsales AS vg
WHERE Global_Sales > (SELECT AVG(Global_Sales) 
                      FROM vgsales 
                      WHERE Platform = vg.Platform);

-- Advanced Query Combining Concepts
WITH Genre_Avg AS (
    SELECT Genre, AVG(Global_Sales) AS Avg_Sales 
    FROM vgsales 
    GROUP BY Genre
),
Top_Games AS (
    SELECT Name, Genre, Global_Sales,
           RANK() OVER (PARTITION BY Genre ORDER BY Global_Sales DESC) AS Genre_Rank
    FROM vgsales
)
SELECT tg.Name, tg.Genre, tg.Global_Sales, ga.Avg_Sales
FROM Top_Games tg
JOIN Genre_Avg ga ON tg.Genre = ga.Genre
WHERE tg.Genre_Rank = 1;

