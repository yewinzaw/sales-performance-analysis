--------------------------------------------------------
--                   Objective 2                      --
--------------------------------------------------------

-- #1 Create Table Script
CREATE TABLE dbo.sales_team (
    sales_agent VARCHAR(50) NOT NULL,
    manager VARCHAR(50) NOT NULL,
    regional_office VARCHAR(50) NOT NULL
);

-- #2 Import CSV
COPY dbo.sales_team (sales_agent, manager, regional_office)
FROM 'C:/Playground/Sherlock/Portfolio/Sales Pipeline Analysis/Dataset/sales_teams.csv'
DELIMITER ','
CSV HEADER;

-- #3 Calculate the win rate for each sales agent, and find the top performer
WITH agent_stats AS(
	SELECT 	sales_agent,
  			SUM((LOWER(deal_stage) = 'won')::int) AS win_count,
		 	COUNT(*)  AS total_count,
		 	SUM(close_value) as total_revenue
	FROM dbo.sales_pipeline
	GROUP BY sales_agent
)
SELECT sales_agent,win_count,total_count,total_revenue, ROUND( win_count * 100.0/total_count, 2) win_rate
FROM agent_stats
ORDER BY win_rate DESC;

-- #4 Calculate the total revenue by agent, and see who generated the most
SELECT sales_agent, SUM(close_value) total_revenue
FROM dbo.sales_pipeline
WHERE LOWER(deal_stage) = 'won'
GROUP BY sales_agent
ORDER BY total_revenue DESC;

-- #5 Calculate win rates by manager to determine which manager’s team performed best
WITH agent_stats AS(
	SELECT 	sales_agent,
  			SUM((LOWER(deal_stage) = 'won')::int) AS win_count,
		 	COUNT(*)  AS total_count,
			SUM(close_value) as total_revenue
	FROM dbo.sales_pipeline
	GROUP BY sales_agent
),
manager_stats AS(
	SELECT manager,
	       COUNT(DISTINCT t.sales_agent) AS member_count,
	       SUM(win_count) AS total_wins,SUM(total_count) AS total_deals,
	       ROUND(SUM(total_revenue),2) AS total_revenue,
	       ROUND(SUM(win_count) * 100.0/ SUM(total_count),2) AS win_rate
	FROM agent_stats a
	INNER JOIN dbo.sales_team t
	ON a.sales_agent = t.sales_agent
	GROUP BY manager
)
SELECT manager,member_count,total_wins,total_deals,total_revenue,win_rate
FROM manager_stats
ORDER BY win_rate DESC;

-- #6 For the product GTX Plus Pro, find which regional office sold the most units
SELECT  regional_office, SUM(close_value) AS total_sold_value, COUNT(p.sales_agent) AS total_units_sold
FROM dbo.sales_pipeline p
INNER JOIN dbo.sales_team t
ON p.sales_agent = t.sales_agent
WHERE LOWER(product) = 'gtx plus pro' AND LOWER(deal_stage) = 'won'
GROUP BY regional_office
ORDER BY total_units_sold DESC

