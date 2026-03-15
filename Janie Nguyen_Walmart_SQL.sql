CREATE DATABASE IF NOT EXISTS walmart_db;
USE walmart_db;

CREATE TABLE IF NOT EXISTS walmart_sales (
    Store        INT,
    Date         VARCHAR(10),
    Weekly_Sales DECIMAL(12,2),
    Holiday_Flag TINYINT(1),
    Temperature  FLOAT,
    Fuel_Price   FLOAT,
    CPI          FLOAT,
    Unemployment FLOAT
);
SELECT * FROM walmart_sales;

USE walmart_db;

SELECT * FROM walmart_sales;
SELECT COUNT(*) FROM walmart_sales;
SELECT month(Date) FROM walmart_sales
where Store=1;

-- Change date from STR to DATE
ALTER TABLE walmart_sales ADD COLUMN Proper_Date DATE;
UPDATE walmart_sales
SET Proper_Date = STR_TO_DATE(Date, '%d-%m-%Y');
ALTER TABLE walmart_sales 
MODIFY COLUMN Proper_Date DATE AFTER Store;
SELECT * FROM walmart_sales 
WHERE Holiday_Flag=1;

ALTER TABLE walmart_sales DROP COLUMN Date;
ALTER TABLE walmart_sales RENAME COLUMN Proper_Date TO Date;

-- 1. Holiday sales and risk of over/under-stocking

-- 1.1. Determine holiday/normal
 
 UPDATE walmart_sales
 SET Week_Type= CASE WHEN Holiday_Flag = 1 THEN 'Holiday'
    WHEN Holiday_Flag=0 THEN 'Normal'
    END;

-- SELECT * FROM walmart_sales LIMIT 20;
-- 1.2. Average weekly sales by store
CREATE VIEW Sales_by_Week_Type AS
	SELECT Store, AVG (Weekly_Sales) as Average_weekly_sales
FROM walmart_sales
GROUP BY Store, Week_Type;

	-- update view
CREATE OR REPLACE VIEW Sales_by_Week_Type AS
	SELECT Store,Week_Type, AVG (Weekly_Sales) as Average_weekly_sales
	FROM walmart_sales
	GROUP BY Store, Week_Type;

SELECT * FROM Sales_by_Week_Type;

-- 1.3. Sales uplift calculation: self join
SELECT n.Store,
	ROUND(h.Average_weekly_sales/n.Average_weekly_sales, 2) Sales_lift_multiplier
FROM Sales_by_Week_Type n
JOIN Sales_by_Week_Type h
	ON n.Store = h.Store
WHERE n.Week_Type='Normal'
AND h.Week_Type='Holiday'
ORDER BY Sales_lift_multiplier DESC;


-- 2. Top_Performers
CREATE OR REPLACE VIEW top_stores AS
SELECT Store, 
       SUM(Weekly_Sales) AS Total_Sales,
       AVG(Weekly_Sales) AS Avg_Weekly_Sales
FROM walmart_sales
GROUP BY Store
ORDER BY Total_Sales DESC;

SELECT * FROM top_stores
ORDER BY Total_Sales DESC
LIMIT 5;

-- holiday type
UPDATE walmart_sales
SET Holiday_Type = CASE 
    WHEN MONTH(Date) = 2 AND DAY(Date) BETWEEN 7 AND 14 
        THEN 'Super Bowl / Valentines'
    WHEN MONTH(Date) = 9 AND DAY(Date) BETWEEN 1 AND 10
        THEN 'Labor Day'
    WHEN MONTH(Date) = 11 AND DAY(Date) BETWEEN 22 AND 28 
        THEN 'Thanksgiving'
    WHEN MONTH(Date) = 12 AND DAY(Date) >= 25 
        THEN 'New Years Eve'
    ELSE 'Need inspection'
END
WHERE Holiday_Flag = 1;

SELECT * FROM walmart_sales 
where Holiday_Type='Thanksgiving';
-- missing data points from store 36-45
-- TRUNCATE TABLE walmart_sales;

