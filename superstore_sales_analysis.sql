-- SUPERSTORE SALES ANALYSIS PROJECT

-- Tool Used: MySQL Workbench
-- Database: sales_project
-- Dataset: Superstore CSV Dataset
-- Project Objectives:
-- 1. Import and clean sales data
-- 2. Validate data quality
-- 3. Perform sales and profit analysis
-- 4. Generate business insights
-----------------------------------------------------
-- Creating Database
CREATE DATABASE IF NOT EXISTS sales_project;
USE sales_project;

-- STEP 1: CREATING ORDERS TABLE
CREATE TABLE orders (
    `Row ID` INT,
    `Order ID` TEXT,
    `Order Date` TEXT,
    `Ship Date` TEXT,
    `Ship Mode` TEXT,
    `Customer ID` TEXT,
    `Customer Name` TEXT,
    Segment TEXT,
    Country TEXT,
    City TEXT,
    State TEXT,
    `Postal Code` INT,
    Region TEXT,
    `Product ID` TEXT,
    Category TEXT,
    `Sub-Category` TEXT,
    `Product Name` TEXT,
    Sales DOUBLE,
    Quantity INT,
    Discount DOUBLE,
    Profit DOUBLE
);

-- STEP 2: IMPORTING DATA
-- Importing dataset into MySQL
-- Data imported using MySQL Workbench Table Data Import Wizard


-- STEP 3: CLEAN DATE COLUMNS
-- Adding clean date columns
ALTER TABLE orders
ADD COLUMN order_date_clean DATE,
ADD COLUMN ship_date_clean DATE;

-- Converting text dates into proper DATE format
UPDATE orders
SET 
    order_date_clean = STR_TO_DATE(`Order Date`, '%m/%d/%Y'),
    ship_date_clean = STR_TO_DATE(`Ship Date`, '%m/%d/%Y');
    
  -- Verifying date conversion
SELECT 
    `Order Date`,
    order_date_clean,
    `Ship Date`,
    ship_date_clean
FROM orders
LIMIT 10;


 -- STEP 4: CHECKING DUPLICATES & MISSING VALUES
-- Checking duplicates
SELECT 
    `Row ID`,
    `Order ID`,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY `Row ID`, `Order ID`
HAVING COUNT(*) > 1;
-- Result:
-- No exact duplicate rows were detected based on Row ID and Order ID combinations.

-- Checking For Missing Values (All Columns)
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN `Row ID` IS NULL THEN 1 ELSE 0 END) AS missing_row_id,
    SUM(CASE WHEN `Order ID` IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN `Ship Date` IS NULL THEN 1 ELSE 0 END) AS missing_ship_date,
    SUM(CASE WHEN `Ship Mode` IS NULL THEN 1 ELSE 0 END) AS missing_ship_mode,
    SUM(CASE WHEN `Customer ID` IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN `Customer Name` IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN `Segment` IS NULL THEN 1 ELSE 0 END) AS missing_segment,
    SUM(CASE WHEN `Country` IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN `City` IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN `State` IS NULL THEN 1 ELSE 0 END) AS missing_state,
    SUM(CASE WHEN `Postal Code` IS NULL THEN 1 ELSE 0 END) AS missing_postal_code,
    SUM(CASE WHEN `Region` IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN `Product ID` IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN `Category` IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN `Sub-Category` IS NULL THEN 1 ELSE 0 END) AS missing_sub_category,
    SUM(CASE WHEN `Product Name` IS NULL THEN 1 ELSE 0 END) AS missing_product_name,
    SUM(CASE WHEN `Sales` IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN `Quantity` IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN `Discount` IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN `Profit` IS NULL THEN 1 ELSE 0 END) AS missing_profit
FROM orders;
-- Result:
-- No missing values were detected across the dataset.

-- Column Names Standardization 
SHOW COLUMNS FROM orders;

-- Renaming all columns to snake_case (no spaces, lowercase)
ALTER TABLE orders
    RENAME COLUMN `Row ID` TO row_id,
    RENAME COLUMN `Order ID` TO order_id,
    RENAME COLUMN `Order Date` TO order_date,
    RENAME COLUMN `Ship Date` TO ship_date,
    RENAME COLUMN `Ship Mode` TO ship_mode,
    RENAME COLUMN `Customer ID` TO customer_id,
    RENAME COLUMN `Customer Name` TO customer_name,
    RENAME COLUMN `Segment` TO segment,
    RENAME COLUMN `Country` TO country,
    RENAME COLUMN `City` TO city,
    RENAME COLUMN `State` TO state,
    RENAME COLUMN `Postal Code` TO postal_code,
    RENAME COLUMN `Region` TO region,
    RENAME COLUMN `Product ID` TO product_id,
    RENAME COLUMN `Category` TO category,
    RENAME COLUMN `Sub-Category` TO sub_category,
    RENAME COLUMN `Product Name` TO product_name,
    RENAME COLUMN `Sales` TO sales,
    RENAME COLUMN `Quantity` TO quantity,
    RENAME COLUMN `Discount` TO discount,
    RENAME COLUMN `Profit` TO profit;

-- Verifying new column names
SHOW COLUMNS FROM orders;
-- Result:
-- All column names were standardized using snake_case naming convention
-- to improve readability and SQL query consistency.

-- STEP 5: CHECKING AND FIXING DATA TYPES
-- Checking current data types
SHOW COLUMNS FROM orders;
-- order_date and ship_date stored as TEXT (original)
-- order_date_clean and ship_date_clean stored as DATE (cleaned)
-- All numeric columns confirmed correct types


-- STEP 6: VALIDATING KEY FIELDS
-- Checking for negative or zero sales
SELECT COUNT(*) AS negative_or_zero_sales
FROM orders
WHERE sales <= 0;

-- Checking for negative or zero quantity
SELECT COUNT(*) AS negative_or_zero_quantity
FROM orders
WHERE quantity <= 0;

-- Checking for discounts greater than 1 (over 100%)
SELECT COUNT(*) AS invalid_discounts
FROM orders
WHERE discount > 1;

-- Checking for extreme negative profits (possible data errors)
SELECT COUNT(*) AS extreme_negative_profit
FROM orders
WHERE profit < -1000;

-- Investigating extreme negative profits
SELECT 
    order_id,
    product_name,
    category,
    sales,
    quantity,
    discount,
    profit
FROM orders
WHERE profit < -1000
ORDER BY profit ASC;
-- Validation Results:
-- No negative sales, quantities, or invalid discounts found
-- 22 rows with profit < -1000 identified -- caused by high discounts (40-80%)
-- Rows retained for analysis


-- STEP 7: HANDLING OUTLIERS AND ANOMALIES
-- Checking sales outliers (unusually high sales)
SELECT 
    MAX(sales) AS max_sales,
    MIN(sales) AS min_sales,
    AVG(sales) AS avg_sales
FROM orders;

-- Checking profit outliers
SELECT 
    MAX(profit) AS max_profit,
    MIN(profit) AS min_profit,
    AVG(profit) AS avg_profit
FROM orders;

-- Checking discount distribution
SELECT 
    discount,
    COUNT(*) AS count
FROM orders
GROUP BY discount
ORDER BY discount ASC;
-- Outlier Results:
-- Sales: $0.44 - $22,638 | Profit: -$6,599 - $8,399 | Discounts: 0 - 0.8
-- No outliers require removal


-- STEP 8: CREATING CLEAN ANALYSIS-READY VIEW
CREATE VIEW clean_orders AS
SELECT
    row_id,
    order_id,
    order_date_clean AS order_date,
    ship_date_clean AS ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
FROM orders;

-- Verifying view
SELECT * FROM clean_orders LIMIT 10;
-- View 'clean_orders' created successfully
-- Uses proper DATE columns for order_date and ship_date
-- All future analysis queries will use clean_orders


-- ANALYSIS PHASE
-- Query 1: Overall Business Summary
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_rows,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(sales), 2) AS avg_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM clean_orders;
-- Total Orders: 4,931 | Revenue: $2,272,449 | Profit: $282,857 | Margin: 12.45%
-- Low profit margin suggests heavy discounting is impacting profitability

-- Query 2: Sales and Profit by Region
SELECT
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM clean_orders
GROUP BY region
ORDER BY total_profit DESC;
-- West leads in sales and profit (14.86% margin)
-- Central underperforms despite high sales volume (8.06% margin)

-- Query 3: Sales and Profit by Category
SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM clean_orders
GROUP BY category
ORDER BY total_profit DESC;
-- Technology and Office Supplies healthy at ~17% margin
-- Furniture critically underperforms at 2.32% margin despite high sales volume

-- Query 4: Impact of Discount on Profit
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low 1-20%'
        WHEN discount <= 0.4 THEN 'Medium 21-40%'
        WHEN discount <= 0.6 THEN 'High 41-60%'
        ELSE 'Very High 61-80%'
    END AS discount_band,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM clean_orders
GROUP BY discount_band
ORDER BY discount_band ASC;

-- No discount yields 29.57% margin -- most profitable segment
-- Discounts above 20% result in negative profits
-- Very high discounts (61-80%) produce -123% margin -- severe loss

-- Query 5: Top 10 Best Performing Products
SELECT
    product_name,
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM clean_orders
GROUP BY product_name, category
ORDER BY total_profit DESC
LIMIT 10;
-- Top 10 products dominated by Technology (8/10)
-- Canon imageCLASS 2200 is the single most profitable product at $25,199

-- Query 6: Top 10 Worst Performing Products
SELECT
    product_name,
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM clean_orders
GROUP BY product_name, category
ORDER BY total_profit ASC
LIMIT 10;
-- Worst products dominated by Furniture (4/10) and over-discounted Technology
-- Cubify 3D Printer worst performer at -80% margin
-- Recommendation: review discount strategy on these products


-- Query 7: Monthly Sales Trend
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month_num,
    MONTHNAME(order_date) AS month_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM clean_orders
GROUP BY year, month_num, month_name
ORDER BY year, month_num ASC;
-- Sales grew from $481K (2014) to $725K (2017) -- 50% growth over 4 years
-- Q4 (Sep-Dec) consistently strongest quarter every year
-- January and February consistently weakest months

