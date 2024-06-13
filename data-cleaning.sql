/*
 * SQL Project - Company Layoffs Data Cleaning Project
 *
 * Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
 */

/* Step 1: Load the initial data from the 'layoffs' table */
SELECT *
FROM layoffs;

/* Step 2: Create a staging table 'layoffs_staging' to work with */
CREATE TABLE layoffs_staging
    LIKE layoffs;

/* Copy all data from the 'layoffs' table to 'layoffs_staging' */
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

/* Verify that the data has been copied correctly */
SELECT *
FROM layoffs_staging;

/* Step 3: Identify potential duplicate entries by generating row numbers
   for each group of rows that have the same company, industry, total laid off, and date */
SELECT company,
       industry,
       total_laid_off,
       `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
           ) AS row_num
FROM layoffs_staging;

/* Select rows that have duplicates by looking for row numbers greater than 1
   within the same partition */
SELECT *
FROM (SELECT company,
             industry,
             total_laid_off,
             `date`,
             ROW_NUMBER() OVER (
                 PARTITION BY company, industry, total_laid_off, `date`
                 ) AS row_num
      FROM layoffs_staging) duplicates
WHERE row_num > 1;

/*
 * Examine entries for a specific company ('Oda') to understand if they are legitimate
 * or if they should be considered duplicates.
 */
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

/*
 * Identify real duplicates considering all relevant columns by generating row numbers
 * for each group of rows that have the same values in all relevant columns */
SELECT *
FROM (SELECT company,
             location,
             industry,
             total_laid_off,
             percentage_laid_off,
             `date`,
             stage,
             country,
             funds_raised_millions,
             ROW_NUMBER() OVER (
                 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
                 ) AS row_num
      FROM layoffs_staging) duplicates
WHERE row_num > 1;

/* Step 4: Remove duplicate entries by first adding a row number column to the staging table */
ALTER TABLE layoffs_staging
    ADD row_num INT;

/* Verify the structure of the staging table after adding the new column */
SELECT *
FROM layoffs_staging;

/* Create a new staging table 'layoffs_staging2' with the same structure as 'layoffs_staging' plus the row number column */
CREATE TABLE layoffs_staging2
(
    `company`               TEXT,
    `location`              TEXT,
    `industry`              TEXT,
    `total_laid_off`        INT,
    `percentage_laid_off`   TEXT,
    `date`                  TEXT,
    `stage`                 TEXT,
    `country`               TEXT,
    `funds_raised_millions` INT,
    row_num                 INT
);

/* Insert data into the new staging table and generate row numbers for each group of duplicates */
INSERT INTO layoffs_staging2
(`company`,
 `location`,
 `industry`,
 `total_laid_off`,
 `percentage_laid_off`,
 `date`,
 `stage`,
 `country`,
 `funds_raised_millions`,
 `row_num`)
SELECT `company`,
       `location`,
       `industry`,
       `total_laid_off`,
       `percentage_laid_off`,
       `date`,
       `stage`,
       `country`,
       `funds_raised_millions`,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
FROM layoffs_staging;

/* Delete rows from 'layoffs_staging2' where the row number is greater than or equal to 2,
   effectively removing duplicates */
DELETE
FROM layoffs_staging2
WHERE row_num >= 2;

/* Step 5: Standardize data by first verifying the structure of the cleaned staging table */
SELECT *
FROM layoffs_staging2;

/* Check for unique industry values to identify any inconsistencies or null values */
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

/* Select rows where the industry is null or an empty string to understand the extent of missing values */
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = ''
ORDER BY industry;

/* Update empty industry fields to null to make them easier to work with */
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

/* Populate null industry values where possible by copying the industry value from another row
   with the same company name */
UPDATE layoffs_staging2 t1
    JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

/* Check for remaining null industry values after the update */
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = ''
ORDER BY industry;

/* Standardize industry names by updating variations of 'Crypto' to a single standard value */
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

/* Verify the standardized industry names */
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

/* Standardize country names by removing any trailing periods */
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

/* Verify the standardized country names */
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

/*
 * Step 6: Fix the date format by converting the date strings to proper date format
 * Only update the 'date' column where it is not NULL
 */
 /* Update the 'date' column to NULL where it is not a valid date string */
UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'NULL';

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` <> 'NULL';

/* Modify the data type of the date column to DATE */
ALTER TABLE layoffs_staging2
    MODIFY COLUMN `date` DATE;

/* Verify the final structure and data of the cleaned staging table */
SELECT *
FROM layoffs_staging2;

/* Step 7: Handle null values appropriately.
   For 'total_laid_off', 'percentage_laid_off', and 'funds_raised_millions',
   we will keep them as null for better calculations during the EDA phase. */

/* Identify rows with null 'total_laid_off' values */
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

/* Identify rows with both 'total_laid_off' and 'percentage_laid_off' null values */
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

/* Delete rows where both 'total_laid_off' and 'percentage_laid_off' are null as they are not useful */
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

/* Verify the final cleaned data by removing the 'row_num' column */
ALTER TABLE layoffs_staging2
    DROP COLUMN row_num;

/* Final check of the cleaned staging table */
SELECT *
FROM layoffs_staging2;
