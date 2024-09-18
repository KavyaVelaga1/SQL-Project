SELECT * 
FROM layoffs;

--Creating a stagging table to work with 

CREATE TABLE layoffs_stagging(
	"company"	TEXT,
	"location"	TEXT,
	"industry"	TEXT,
	"total_laid_off"	TEXT,
	"percentage_laid_off"	TEXT,
	"date"	TEXT,
	"stage"	TEXT,
	"country"	TEXT,
	"funds_raised_millions"	TEXT
);
INSERT into layoffs_stagging 
SELECT * FROM layoffs;

-- Data Cleaning
--Checking for duplicates
--Standardize data and fix errors
--Look at null VALUES
--Remove unnecessary rows and columns

--1. Removing duplicates

SELECT * FROM layoffs_stagging;

WITH cte_duplicate AS (
    SELECT 
        company, 
        industry, 
        total_laid_off, 
        `date`, 
        stage, 
        country, 
        funds_raised_millions,
        ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, `date`, stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
    FROM 
        layoffs_stagging
)
SELECT * 
FROM cte_duplicate
WHERE row_num > 1;

--- now we need to delete these duplicate rows
---lets create a new duplicate table layoffs_stagging2 and populate data from layoffs_stagging, add row_num column to it and delete duplicates

SELECT * FROM layoffs_stagging;

CREATE TABLE layoffs_stagging2(
	"company"	TEXT,
	"location"	TEXT,
	"industry"	TEXT,
	"total_laid_off"	TEXT,
	"percentage_laid_off"	TEXT,
	"date"	TEXT,
	"stage"	TEXT,
	"country"	TEXT,
	"funds_raised_millions"	TEXT,
	"row_num" INT
);

INSERT INTO layoffs_stagging2 (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions,
    row_num
)
SELECT 
    company, 
    location, -- Added location here as it's in the table definition
    industry, 
    total_laid_off, 
    percentage_laid_off, 
    date, 
    stage, 
    country, 
    funds_raised_millions,
    ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, date, stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM 
    layoffs_stagging;
	
select * from layoffs_stagging2;

DELETE FROM layoffs_stagging2
where row_num >= 2;

-- 2. Standardizing Data
select * 
from layoffs_stagging2;

-- lets look for numm and empty rows in industry column

select DISTINCT industry
from layoffs_stagging2
order by industry;

select * 
from layoffs_stagging2
where industry is NULL 
or industry = ' '
order by industry;

SELECT *
FROM layoffs_stagging2
WHERE company LIKE 'airbnb%';

-- Airbnb industry type is travel and is not populated in one the columns
--write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

---- we should set the blanks to nulls because those are easier to work with

UPDATE layoffs_stagging2
SET industry = NULL
WHERE industry = ' ';

--Now lets check if all balnks are null
select * 
from layoffs_stagging2
where industry is NULL 
or industry = ' ';

-- now we need to populate those nulls if possible
-- As I am doing this in SQL lite and since it wont supports joins, I am writing as below
UPDATE layoffs_stagging2
SET industry = (
    SELECT t2.industry
    FROM layoffs_stagging2 t2
    WHERE layoffs_stagging2.company = t2.company
      AND t2.industry IS NOT NULL
    LIMIT 1 -- Ensure only one value is selected, assuming there's a meaningful industry value
)
WHERE industry IS NULL;

select * 
from layoffs_stagging2
where industry is NULL 
or industry = ' ';

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto
SELECT DISTINCT industry
FROM layoffs_stagging2
ORDER BY industry;

UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- now that's taken care of:
SELECT DISTINCT industry
FROM layoffs_stagging2
ORDER BY industry;

-- we also need to look at 

SELECT *
FROM layoffs_stagging2;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
SELECT DISTINCT country
FROM layoffs_stagging2
ORDER BY country;

-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values

-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_stagging2;


