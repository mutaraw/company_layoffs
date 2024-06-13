/*
 * EDA - Exploratory Data Analysis
 *
 * This section explores the data to find trends, patterns, or interesting insights like outliers.
 * Normally, EDA starts with some hypotheses or questions in mind.
 * In this case, we will explore the data without predefined hypotheses and see what we discover.
 */

/* Step 1: Load the data for analysis */
SELECT *
FROM layoffs_staging2;

/* Step 2: Easier Queries */

/* Find the maximum number of total layoffs */
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

/* Find the maximum and minimum percentage of layoffs */
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

/* Identify companies that laid off 100% of their employees (percentage_laid_off = 1) */
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

/* Order companies that laid off 100% of their employees by the amount of funds raised */
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

/* Step 3: Somewhat Tougher Queries (Using GROUP BY) */

/* Identify the companies with the biggest single layoff */
SELECT company, total_laid_off
FROM layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

/* Identify the companies with the most total layoffs */
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

/* Identify the locations with the most total layoffs */
SELECT location, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

/* Identify the countries with the most total layoffs */
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

/* Identify the total layoffs per year */
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`);

/* Identify the industries with the most total layoffs */
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

/* Identify the stages with the most total layoffs */
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;

/* Step 4: Tougher Queries */

/* Identify the top companies with the most layoffs per year */
WITH Company_Year AS
         (SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
          FROM layoffs_staging2
          GROUP BY company, YEAR(`date`)),
     Company_Year_Rank AS (SELECT company,
                                  year,
                                  total_laid_off,
                                  DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
                           FROM Company_Year)
SELECT company, year, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
ORDER BY year, total_laid_off DESC;

/* Calculate the rolling total of layoffs per month */
SELECT SUBSTRING(`date`, 1, 7) AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
ORDER BY month;

/* Use a CTE to query the rolling total of layoffs per month */
WITH Date_CTE AS
         (SELECT SUBSTRING(`date`, 1, 7) AS month, SUM(total_laid_off) AS total_laid_off
          FROM layoffs_staging2
          GROUP BY month
          ORDER BY month)
SELECT month, SUM(total_laid_off) OVER (ORDER BY month) AS rolling_total_layoffs
FROM Date_CTE
ORDER BY month;
