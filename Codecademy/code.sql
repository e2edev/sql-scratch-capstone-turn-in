--Learn SQL from Scratch:First- and Last-Touch Attribution by Jerry Bohun | Jun 5, 2018 - Jul 31, 2018

-- Task 1a
SELECT COUNT(DISTINCT(utm_campaign)) AS 'Total number of campaigns'
FROM page_visits;
SELECT DISTINCT(utm_campaign) AS 'Campaigns'
FROM page_visits;

-- Task 1b
SELECT COUNT(DISTINCT(utm_source)) AS 'Total number of sources'
FROM page_visits;
SELECT DISTINCT(utm_source) AS 'Sources'
FROM page_visits;

--Task 1c
SELECT DISTINCT utm_campaign, utm_source
FROM page_visits;

-- Task 2
SELECT DISTINCT(page_name)
FROM page_visits;

-- Task 3
WITH ft AS (
-- List all IDs with its lowest timestamp aka first touch
SELECT user_id,
        MIN(timestamp),
				utm_campaign
    FROM page_visits
-- Without GROUP BY user_id we would get only one record with lowest/earliest timestamp
    GROUP BY user_id
						)
-- NO need for a JOIN as data is available in the original table
SELECT 	ft.utm_campaign AS 'Campaign',
        COUNT(*) AS 'Count'
FROM ft
GROUP BY 1
ORDER BY 2 DESC;

-- Task 4
WITH lt AS (
-- List all IDs with its highest timestamp aka last touch
SELECT user_id,
        MAX(timestamp),
				utm_campaign
    FROM page_visits
-- Without GROUP BY user_id we would get only one record with highest/latest timestamp
    GROUP BY user_id
						)
-- NO need for a JOIN as data is available in the original table
SELECT 	lt.utm_campaign AS 'Campaign',
        COUNT(*) AS 'Count'
FROM lt
GROUP BY 1
ORDER BY 2 DESC;

-- Task 5
SELECT COUNT(DISTINCT(user_id)) AS 'Number of customers that finalised a deal'
FROM page_visits
WHERE page_name = '4 - purchase';

-- Task 6
WITH lt AS (
-- List all IDs with its highest timestamp aka last touch
SELECT user_id,
        MAX(timestamp),
				utm_campaign
    FROM page_visits
-- Combining Task 4 and 5 we can see figures for campaigns that led to final purchase page 
  	WHERE page_name = '4 - purchase'
    GROUP BY user_id
						)
-- NO need for a JOIN as data is available in the original table
SELECT 	lt.utm_campaign AS 'Campaign that led to purchase page',
        COUNT(*) AS 'Count'
FROM lt
GROUP BY 1
ORDER BY 2 DESC;





-- First touch per page
WITH ft AS (
-- List all IDs with its lowest timestamp aka first touch
SELECT user_id,
        MIN(timestamp),
				utm_campaign,
 				utm_source,
  			page_name
    FROM page_visits
    GROUP BY user_id
						)
-- Count first touch on each page per campaign
SELECT 	ft.utm_campaign,
				ft.utm_source,
        COUNT(
        CASE
        WHEN ft.page_name = '1 - landing_page' THEN 1
          ELSE NULL
        END) AS '1 - landing_page',
        COUNT(
        CASE
        WHEN ft.page_name = '2 - shopping_cart' THEN 1
          ELSE NULL
        END) AS '2 - shopping_cart',
        COUNT(
        CASE
        WHEN ft.page_name = '3 - checkout' THEN 1
          ELSE NULL
        END) AS '3 - checkout',
        COUNT(
        CASE
        WHEN ft.page_name = '4 - purchase' THEN 1
          ELSE NULL
        END) AS '4 - purchase'
FROM ft
 GROUP BY 1
 ORDER BY 3 DESC, 6 ASC
 ;

-- Last touch per page
WITH lt AS (
-- List all IDs with its highest timestamp aka last touch
SELECT user_id,
        MAX(timestamp),
				utm_campaign,
 				utm_source,
  			page_name
    FROM page_visits
    GROUP BY user_id
						)
-- Count last touch on each page per campaign
SELECT 	lt.utm_campaign,
				lt.utm_source,
        COUNT(
        CASE
        WHEN lt.page_name = '1 - landing_page' THEN 1
          ELSE NULL
        END) AS '1 - landing_page',
        COUNT(
        CASE
        WHEN lt.page_name = '2 - shopping_cart' THEN 1
          ELSE NULL
        END) AS '2 - shopping_cart',
        COUNT(
        CASE
        WHEN lt.page_name = '3 - checkout' THEN 1
          ELSE NULL
        END) AS '3 - checkout',
        COUNT(
        CASE
        WHEN lt.page_name = '4 - purchase' THEN 1
          ELSE NULL
        END) AS '4 - purchase'
FROM lt
 GROUP BY 1
 ORDER BY 3 DESC, 6 ASC
 ;


-- What is the TYPICAL user journey by page? Count hits on each page for every campaign
SELECT 	utm_campaign,
				utm_source,
        COUNT(
        CASE
        WHEN page_name = '1 - landing_page' THEN 1
          ELSE NULL
        END) AS '1 - landing_page',
        COUNT(
        CASE
        WHEN page_name = '2 - shopping_cart' THEN 1
          ELSE NULL
        END) AS '2 - shopping_cart',
        COUNT(
        CASE
        WHEN page_name = '3 - checkout' THEN 1
          ELSE NULL
        END) AS '3 - checkout',
        COUNT(
        CASE
        WHEN page_name = '4 - purchase' THEN 1
          ELSE NULL
        END) AS '4 - purchase'
    FROM page_visits
    GROUP BY 1
    ORDER BY 3 DESC, 6 ASC
;

-- What is the TYPICAL user journey by campaign?

-- Start to End
WITH 
S2E AS (
-- Create temp table with flags for start and end of the journey
SELECT 	user_id,
				CASE
        WHEN page_name = '1 - landing_page' THEN utm_campaign
          ELSE NULL
        END AS 'StartCampaign',
        CASE
        WHEN page_name = '4 - purchase' THEN utm_campaign
          ELSE NULL
        END AS 'EndCampaign'
FROM page_visits
		),
S AS (
-- Pick up all with where it started
SELECT 	S2E.user_id,
				S2E.StartCampaign        
FROM S2E
WHERE S2E.StartCampaign IS NOT NULL
		),
E AS (
-- Pick up all with where it ended      
SELECT 	S2E.user_id,
				S2E.EndCampaign        
FROM S2E
WHERE S2E.EndCampaign IS NOT NULL
  		)
-- Join tables to create links between start and end of the journey
SELECT (S.StartCampaign || '|'|| E.EndCampaign) AS Start2End,
 				S.StartCampaign AS 'StartCampaign',
        E.EndCampaign AS 'EndCampaign',
 				Count(*) AS 'Count'
FROM S
JOIN E
 ON S.user_id = E.user_id
GROUP BY 1
ORDER BY 2, 4 DESC
;
