# Superstore Sales Analysis

## Overview
SQL-based data cleaning and sales analysis project using the Superstore dataset.
Performed in MySQL Workbench to uncover business insights around revenue, profit, and discounting behaviour.

## Tools Used
- MySQL Workbench
- Excel (visualization)

## Dataset
- Source: Superstore Sales Dataset
- 9,694 rows | 21 columns | 2014-2017

## Project Workflow
1. Created and imported data into MySQL
2. Cleaned date columns and standardized column names
3. Checked for duplicates, missing values, and data type issues
4. Validated key fields and investigated outliers
5. Created a clean analysis-ready view
6. Performed 7 business analysis queries

## Key Findings
- Overall profit margin is 12.45% -- below healthy retail benchmark
- Discounts above 20% result in negative profits
- Very high discounts (61-80%) produce -123% profit margin
- Furniture category critically underperforms at 2.32% margin
- West region leads in both sales and profit
- Sales grew 50% from 2014 to 2017
- Canon imageCLASS 2200 is the single most profitable product

## Files
- 'superstore_sales_analysis.sql` — fulL cleaning and analysis script
