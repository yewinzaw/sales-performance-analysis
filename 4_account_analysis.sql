  -- #1 Create Table script
CREATE TABLE dbo.account_master
(
    account          VARCHAR(50) PRIMARY KEY,
    sector           VARCHAR(50),
    year_established INT,
    revenue          NUMERIC(12, 2),
    employees        INT,
    office_location  VARCHAR(50),
    subsidiary_of    VARCHAR(50)
);

-- #2 Import CSV
COPY dbo.account_master (account, sector, year_established, revenue, employees, office_location, subsidiary_of)
    FROM 'C:/Playground/Sherlock/Portfolio/Sales Pipeline Analysis/Dataset/accounts.csv'
    DELIMITER ','
    CSV HEADER;

--#3 Calculate revenue by office location, and identify the lowest performer
SELECT office_location,
       ROUND(SUM(revenue), 2)              AS total_revenue,
       RANK() OVER (ORDER BY SUM(revenue)) AS least_revenue_rank
FROM dbo.account_master
GROUP BY office_location
ORDER BY least_revenue_rank;

-- #4 Find the gap in years between the oldest and newest customer, and name those companies
SELECT account,
       year_established
FROM dbo.account_master
WHERE year_established = (SELECT MIN(year_established) FROM dbo.account_master)
   OR year_established = (SELECT MAX(year_established) FROM dbo.account_master)
ORDER BY year_established;

-- #5 Which accounts that were subsidiaries had the most lost sales opportunities?
SELECT ac.account,
       COUNT(sp.opportunity_id) AS lost_deals
FROM dbo.sales_pipeline sp
         INNER JOIN dbo.account_master ac
                    ON sp.account = ac.account
WHERE LOWER(sp.deal_stage) = 'lost'
  AND ac.subsidiary_of IS NOT NULL
GROUP BY ac.account
ORDER BY lost_deals DESC;

-- #6 Join the companies to their subsidiaries. Which one had the highest total revenue?
SELECT
    COALESCE(a.subsidiary_of, a.account) AS company,
    ROUND(SUM(p.close_value), 2) AS total_revenue
FROM dbo.account_master a
INNER JOIN dbo.sales_pipeline p
    ON a.account = p.account
WHERE LOWER(p.deal_stage) = 'won'
GROUP BY COALESCE(a.subsidiary_of, a.account)
ORDER BY total_revenue DESC;