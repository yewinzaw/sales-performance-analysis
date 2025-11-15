--------------------------------------------------------
--                   Objective 3                      --
--------------------------------------------------------

-- #1 Create Table script
CREATE TABLE dbo.product_master
(
    product        VARCHAR(50) PRIMARY KEY,
    series         VARCHAR(50) NOT NULL,
    sales_price    NUMERIC(12, 2) NOT NULL
);

-- #2 Import CSV
COPY dbo.product_master (product, series, sales_price)
FROM 'C:/Playground/Sherlock/Portfolio/Sales Pipeline Analysis/Dataset/products.csv'
DELIMITER ','
CSV HEADER;

-- #3 For March deals, identify the top product by revenue and compare it to the top by units sold
WITH march_deals AS (
    SELECT
        product,
        SUM(close_value) AS total_revenue,
        COUNT(*) AS total_units_sold,
        RANK() OVER (ORDER BY SUM(close_value) DESC) AS revenue_rank,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS units_rank
    FROM dbo.sales_pipeline
    WHERE EXTRACT(MONTH FROM engage_date) = 3
      AND LOWER(deal_stage) = 'won'
    GROUP BY product
)
SELECT
    product,
    total_revenue,
    total_units_sold,
    revenue_rank,
    units_rank
FROM march_deals md
WHERE revenue_rank = 1 OR units_rank = 1;

-- #4 Calculate the average difference between "sales_price" and "close_value" for each product.
-- note: if the results suggest a data issue (check for anomalies)
WITH price_stats AS (
    SELECT
        p.product,
        p.close_value,
        m.sales_price,
        CASE
            WHEN p.close_value < m.sales_price THEN 'Discounted'
            ELSE 'Normal'
        END AS price_category
    FROM dbo.sales_pipeline p
    JOIN dbo.product_master m
        ON p.product = m.product
    WHERE LOWER(p.deal_stage) = 'won'
      AND p.close_value IS NOT NULL
      AND p.close_value > 0
)
SELECT
    product,
    ROUND(AVG(CASE WHEN price_category = 'Discounted' THEN close_value - sales_price END), 2) AS avg_discounted_price_diff,
	ROUND(AVG(CASE WHEN price_category = 'Discounted' THEN (close_value - sales_price)/sales_price*100 END), 2) AS avg_discounted_diff_percent,
    ROUND(AVG(CASE WHEN price_category = 'Normal' THEN close_value - sales_price END), 2) AS avg_normal_price_diff,
	ROUND(AVG(CASE WHEN price_category = 'Normal' THEN (close_value - sales_price)/sales_price*100 END), 2) AS avg_normal_diff_percent,
    COUNT(CASE WHEN price_category = 'Discounted' THEN 1 END) AS discounted_deals,
	COUNT(CASE WHEN price_category = 'Normal' THEN 1 END) AS normal_deals,
    COUNT(*) AS total_deals
FROM price_stats
GROUP BY product
ORDER BY product;

-- #5 Calculate total revenue by product series and compare their performance
SELECT
    m.series,
    ROUND(SUM(p.close_value), 2) AS total_revenue,
    COUNT(*) AS total_deals,
    ROUND(AVG(p.close_value), 2) AS avg_deal_value
FROM dbo.sales_pipeline p
JOIN dbo.product_master m
    ON p.product = m.product
WHERE LOWER(p.deal_stage) = 'won'
  AND p.close_value IS NOT NULL
  AND p.close_value > 0
GROUP BY m.series
ORDER BY total_revenue DESC;



