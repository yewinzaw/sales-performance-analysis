--------------------------------------------------------
--                   Objective 1                      --
--------------------------------------------------------

-- #1 First off, check the maximum text length using python.
-- see code at 1_sale_pipeline_analysis.py

-- #2 Create SQL Table Scripts
CREATE SCHEMA IF NOT EXISTS dbo;
CREATE TABLE dbo.sales_pipeline
(
    opportunity_id VARCHAR(10) PRIMARY KEY,
    sales_agent    VARCHAR(50) NOT NULL,
    product        VARCHAR(50) NOT NULL,
    account        VARCHAR(50),
    deal_stage     VARCHAR(50) NOT NULL,
    engage_date    DATE,
    close_date     DATE,
    close_value    NUMERIC(12, 2)
);

-- #3 Import CVS to Sales_Pipeline Table
COPY dbo.sales_pipeline (opportunity_id, sales_agent, product, account, deal_stage, engage_date, close_date,close_value)
FROM 'C:/Playground/Sherlock/Portfolio/Sales Pipeline Analysis/Dataset/sales_pipeline.csv'
DELIMITER ','
CSV HEADER;

-- #4 Calculate the number of sales opportunities created each month using "engage_date",
 -- and identify the month with the most opportunities
SELECT TO_CHAR(engage_date, 'YYYY-MM') AS month, COUNT(*) AS opportunity_count
FROM dbo.sales_pipeline
WHERE engage_date IS NOT NULL
GROUP BY TO_CHAR(engage_date, 'YYYY-MM')
ORDER BY month DESC;

-- #5 Find the average time deals stayed open (from "engage_date" to "close_date"),
-- and compare closed deals versus won deals.
SELECT ROUND(AVG(close_date - engage_date), 0) as average_time_deals_stayed_open,
       deal_stage,
       COUNT(deal_stage) as deal_count
FROM dbo.sales_pipeline
WHERE engage_date IS NOT NULL AND close_date IS NOT NULL
GROUP BY deal_stage;

-- #6.1 Calculate the percentage of deals in each stage, and determine what share were lost
SELECT deal_stage,
       COUNT(deal_stage) AS group_count,
       SUM(COUNT(deal_stage)) OVER () AS total,
       ROUND(COUNT(deal_stage) / SUM(COUNT(deal_stage)) OVER (), 4) percentage
FROM dbo.sales_pipeline
WHERE engage_date IS NOT NULL AND close_date IS NOT NULL
GROUP BY deal_stage;

-- #6.2 Alternative Method
SELECT ROUND(AVG(CASE WHEN deal_stage= 'Lost' THEN 1.0 ELSE 0.0 END),4) loss_rate
FROM dbo.sales_pipeline
WHERE engage_date IS NOT NULL AND close_date IS NOT NULL;

-- #7 Compute the win rate for each product, and identify which one had the highest win rate
SELECT  product, ROUND(AVG(CASE WHEN deal_stage= 'Won' THEN 1 ELSE 0 END),4) win_rate
FROM dbo.sales_pipeline
GROUP BY product
ORDER BY win_rate DESC;
