# Company Layoffs Data Cleaning Project

## Project Overview

This project involves cleaning and analyzing a dataset of company layoffs from 2022, sourced from [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022). The main goals of this project are to clean the data to ensure it is consistent and accurate, and then perform exploratory data analysis (EDA) to uncover trends, patterns, and insights.

## Data Cleaning Steps

1. **Loading Data**
   - Loaded the initial data from the `layoffs` table.

2. **Creating a Staging Table**
   - Created a staging table `layoffs_staging` and copied data from the original table.

3. **Identifying and Handling Duplicates**
   - Identified potential duplicate entries by generating row numbers for each group of rows with the same values in relevant columns.
   - Removed duplicate entries by adding a `row_num` column and deleting rows with row numbers greater than 1.

4. **Standardizing Data**
   - Standardized missing industry entries by setting empty strings to `NULL` and populating `NULL` values where possible.
   - Standardized industry names to ensure consistency (e.g., updating variations of 'Crypto' to 'Crypto').
   - Standardized country names by removing trailing periods.
   - Fixed the date format by converting date strings to proper date format and modifying the data type to `DATE`.

5. **Handling Null Values**
   - Identified rows with null values in `total_laid_off` and `percentage_laid_off` and deleted rows where both values were `NULL`.

## Exploratory Data Analysis (EDA)

1. **Initial Data Exploration**
   - Loaded the cleaned data from the `layoffs_staging2` table.
   - Found the maximum number of total layoffs.
   - Found the maximum and minimum percentages of layoffs.
   - Identified companies that laid off 100% of their employees.
   - Ordered companies that laid off 100% of their employees by the amount of funds raised.

2. **Group By Analysis**
   - Identified the companies with the biggest single layoff.
   - Identified the companies with the most total layoffs.
   - Identified the locations and countries with the most total layoffs.
   - Analyzed total layoffs per year.
   - Identified the industries and stages with the most total layoffs.

3. **Advanced Analysis**
   - Identified the top companies with the most layoffs per year using common table expressions (CTEs) and ranking.
   - Calculated the rolling total of layoffs per month.

## SQL Queries

The SQL queries used for data cleaning and EDA are detailed in the provided script file. Each query includes comments explaining its purpose and actions.

## Conclusion

This project involved a comprehensive process of data cleaning and exploratory data analysis to ensure the dataset was accurate and consistent, and to uncover meaningful insights about company layoffs in 2022. The cleaned dataset and insights obtained can be used for further analysis and decision-making.

## Acknowledgements

- Data Source: [Kaggle - Company Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- Special thanks to Alex, the data analyst on YouTube, for providing valuable insights and inspiration for this project.

## Author

- Tugume William Mutara
- Northeastern University
