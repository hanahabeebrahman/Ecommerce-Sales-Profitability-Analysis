CREATE DATABASE ecommerce_analysis;

USE ecommerce_analysis;

SELECT *
FROM ecommerce_orders
LIMIT 10;

SELECT COUNT(*) AS total_records
FROM ecommerce_orders;

-- What is the overall business performance?
SELECT
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit,
    ROUND(
        SUM(Profit_Amount) / NULLIF(SUM(Order_Amount), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_orders;

-- Which product category generates the highest profit?

SELECT
    Product_Category,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit,
    ROUND(
        SUM(Profit_Amount) / NULLIF(SUM(Order_Amount), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_orders
GROUP BY Product_Category
ORDER BY Total_Profit DESC;

-- Which customer segment generates the highest profit?

SELECT
    Customer_Segment,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY Customer_Segment
ORDER BY Total_Profit DESC;

-- Which products have the lowest profit?

SELECT
    Product_ID,
    Product_Category,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY Product_ID, Product_Category
ORDER BY Total_Profit ASC
LIMIT 10;

-- How does discount level affect profit?

SELECT
    CASE
        WHEN Discount_Percent <= 10 THEN '0-10%'
        WHEN Discount_Percent <= 20 THEN '10-20%'
        WHEN Discount_Percent <= 30 THEN '20-30%'
        ELSE '30-40%'
    END AS Discount_Group,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit,
    ROUND(AVG(Profit_Amount), 2) AS Average_Profit
FROM ecommerce_orders
GROUP BY Discount_Group
ORDER BY MIN(Discount_Percent);


-- What are the monthly revenue and profit trends? 
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Sales_Month;

DESCRIBE ecommerce_orders;


SELECT Order_Date, Day, Month, Year
FROM ecommerce_orders
LIMIT 10;

SELECT
    Order_Date,
    STR_TO_DATE(
        CAST(Order_Date AS CHAR),
        '%Y-%m-%d'
    ) AS Converted_Date
FROM ecommerce_orders
LIMIT 10;


CREATE TABLE ecommerce_orders_backup AS
SELECT * FROM ecommerce_orders;
SET SQL_SAFE_UPDATES = 0;
UPDATE ecommerce_orders
SET Order_Date = STR_TO_DATE(TRIM(Order_Date), '%Y-%m-%d')
WHERE Order_Date IS NOT NULL
  AND TRIM(Order_Date) <> '';


ALTER TABLE ecommerce_orders
MODIFY COLUMN Order_Date DATE;


DESCRIBE ecommerce_orders;

-- Customer Segment Analysis

SELECT
    Customer_Segment,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit,
    ROUND(
        SUM(Profit_Amount) / NULLIF(SUM(Order_Amount), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_orders
GROUP BY Customer_Segment
ORDER BY Total_Profit DESC;

-- Monthly Revenue and Profit

SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Sales_Month;


--  ANNUAL BUSINESS PERFORMANCE

SELECT
    YEAR(Order_Date) AS Sales_Year,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit,
    ROUND(
        SUM(Profit_Amount) /
        NULLIF(SUM(Order_Amount), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_orders
GROUP BY YEAR(Order_Date)
ORDER BY Sales_Year;

-- ORDER STATUS ANALYSIS

SELECT
    Order_Status,
    COUNT(*) AS Record_Count,
    ROUND(
        COUNT(*) /
        (SELECT COUNT(*) FROM ecommerce_orders) * 100,
        2
    ) AS Record_Percentage,
    ROUND(SUM(Order_Amount), 2) AS Recorded_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Recorded_Profit
FROM ecommerce_orders
GROUP BY Order_Status
ORDER BY Record_Count DESC;



-- SHIPPING COST BY PRODUCT CATEGORY

SELECT
    Product_Category,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Shipping_Cost), 2) AS Total_Shipping_Cost,
    ROUND(AVG(Shipping_Cost), 2) AS Average_Shipping_Cost,
    ROUND(
        SUM(Shipping_Cost) /
        NULLIF(SUM(Order_Amount), 0) * 100,
        2
    ) AS Shipping_Cost_Percent_Of_Revenue
FROM ecommerce_orders
GROUP BY Product_Category
ORDER BY Total_Shipping_Cost DESC;


 -- CORRELATION BETWEEN SHIPPING COST AND PROFIT

SELECT
    ROUND(
        (
            AVG(Shipping_Cost * Profit_Amount)
            - AVG(Shipping_Cost) * AVG(Profit_Amount)
        )
        /
        NULLIF(
            STDDEV_POP(Shipping_Cost)
            * STDDEV_POP(Profit_Amount),
            0
        ),
        3
    ) AS Shipping_Profit_Correlation
FROM ecommerce_orders;


-- TEN LOWEST-PROFIT PRODUCT GROUPS

SELECT
    Product_ID,
    Product_Category,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY Product_ID, Product_Category
ORDER BY Total_Profit ASC
LIMIT 10;



-- TEN HIGHEST-PROFIT PRODUCT GROUPS

SELECT
    Product_ID,
    Product_Category,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY Product_ID, Product_Category
ORDER BY Total_Profit DESC
LIMIT 10;


-- CUSTOMER SEGMENT AND PRODUCT CATEGORY ANALYSIS

SELECT
    Customer_Segment,
    Product_Category,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Order_Amount), 2) AS Total_Revenue,
    ROUND(SUM(Profit_Amount), 2) AS Total_Profit
FROM ecommerce_orders
GROUP BY Customer_Segment, Product_Category
ORDER BY Customer_Segment, Total_Profit DESC;


 -- ORDER STATUS, DELIVERY TIME AND CUSTOMER RATINGS

SELECT
    Order_Status,
    COUNT(*) AS Record_Count,
    ROUND(AVG(Delivery_Days), 2) AS Average_Delivery_Days,
    ROUND(AVG(Review_Rating), 2) AS Average_Review_Rating,
    ROUND(
        AVG(Profit_Margin_Percent),
        2
    ) AS Average_Record_Profit_Margin
FROM ecommerce_orders
GROUP BY Order_Status
ORDER BY Record_Count DESC;
