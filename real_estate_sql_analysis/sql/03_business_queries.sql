-- =====================================================================
-- Project : Real Estate Market & Transaction Analytics (MySQL)
-- File    : 03_business_questions.sql
-- Purpose : Business questions derived from the dataset,(joins, group by, 
--           aggregates, subqueries, window functions where noted).
-- =====================================================================

USE real_estate_db;

-- ---------------------------------------------------------------------
-- SECTION A: DATA QUALITY
-- ---------------------------------------------------------------------

-- Q1. How many property records have missing Listing_Price, Type,
--     or Size_SqFt? (Helps decide if these fields need imputation.)
SELECT
    SUM(Listing_Price IS NULL) AS missing_listing_price,
    SUM(Type IS NULL)          AS missing_type,
    SUM(Size_SqFt IS NULL)     AS missing_size_sqft
FROM properties_transactions;

-- Q2. What share of listings are missing a Listing_Price, by City?
--     (Cities with high missing % may need better data collection.)
SELECT
    City,
    COUNT(*)                                   AS total_listings,
    SUM(Listing_Price IS NULL)                 AS missing_price,
    ROUND(SUM(Listing_Price IS NULL) * 100.0 / COUNT(*), 2) AS missing_price_pct
FROM properties_transactions
GROUP BY City
ORDER BY missing_price_pct DESC;


-- ---------------------------------------------------------------------
-- SECTION B: PRICING & INVENTORY INSIGHTS
-- ---------------------------------------------------------------------

-- Q3. What is the average listing price and average rental price
--     per property Type?
SELECT
    Type,
    ROUND(AVG(Listing_Price), 2) AS avg_listing_price,
    ROUND(AVG(Rental_Price), 2)  AS avg_rental_price,
    COUNT(*)                     AS total_units
FROM properties_transactions
WHERE Type IS NOT NULL
GROUP BY Type
ORDER BY avg_listing_price DESC;

-- Q4. Which city has the highest average listing price for houses only?
SELECT
    City,
    ROUND(AVG(Listing_Price), 2) AS avg_house_price,
    COUNT(*)                     AS total_houses
FROM properties_transactions
WHERE Type = 'House'
GROUP BY City
ORDER BY avg_house_price DESC
LIMIT 5;

-- Q5. What is the current status breakdown (Available / Rented / Sold)
--     of the property inventory, overall and by city?
SELECT
    City,
    Status,
    COUNT(*) AS total
FROM properties_transactions
GROUP BY City, Status
ORDER BY City, total DESC;

-- Q6. Which neighborhoods offer the largest average property size
--     for the lowest average listing price (best "value" areas)?
SELECT
    City,
    Neighborhood,
    ROUND(AVG(Size_SqFt), 0)     AS avg_size_sqft,
    ROUND(AVG(Listing_Price), 2) AS avg_listing_price,
    ROUND(AVG(Listing_Price) / NULLIF(AVG(Size_SqFt), 0), 2) AS price_per_sqft
FROM properties_transactions
WHERE Size_SqFt IS NOT NULL AND Listing_Price IS NOT NULL
GROUP BY City, Neighborhood
ORDER BY price_per_sqft ASC
LIMIT 10;

-- Q7. How does average rental price vary by number of bedrooms?
SELECT
    Bedrooms,
    ROUND(AVG(Rental_Price), 2) AS avg_rental_price,
    COUNT(*)                    AS total_units
FROM properties_transactions
GROUP BY Bedrooms
ORDER BY Bedrooms;


-- ---------------------------------------------------------------------
-- SECTION C: AGENT PERFORMANCE
-- ---------------------------------------------------------------------

-- Q8. Who are the top 10 agents by total deals closed
--     (sales + rentals combined)?
SELECT
    Agent_ID,
    Agent_Name,
    Experience_Years,
    Total_Sales_Closed,
    Total_Rentals_Closed,
    (Total_Sales_Closed + Total_Rentals_Closed) AS total_deals_closed,
    Agent_Rating
FROM agents
ORDER BY total_deals_closed DESC
LIMIT 10;

-- Q9. Is there a relationship between an agent's experience and their
--     average client rating? (Bucket experience into ranges.)
SELECT
    CASE
        WHEN Experience_Years < 5  THEN '0-4 yrs'
        WHEN Experience_Years < 10 THEN '5-9 yrs'
        WHEN Experience_Years < 20 THEN '10-19 yrs'
        ELSE '20+ yrs'
    END AS experience_bucket,
    ROUND(AVG(Agent_Rating), 2) AS avg_rating,
    ROUND(AVG(Total_Sales_Closed + Total_Rentals_Closed), 1) AS avg_deals_closed,
    COUNT(*) AS num_agents
FROM agents
GROUP BY experience_bucket
ORDER BY MIN(Experience_Years);

-- Q10. Rank agents within each rating tier (4.5+, 4.0-4.49, below 4.0)
--      by total deals closed, using a window function.
SELECT
    Agent_Name,
    Agent_Rating,
    Total_Sales_Closed + Total_Rentals_Closed AS total_deals,
    RANK() OVER (
        PARTITION BY CASE
            WHEN Agent_Rating >= 4.5 THEN 'Top (4.5+)'
            WHEN Agent_Rating >= 4.0 THEN 'Mid (4.0-4.49)'
            ELSE 'Below 4.0'
        END
        ORDER BY (Total_Sales_Closed + Total_Rentals_Closed) DESC
    ) AS rank_in_tier
FROM agents
ORDER BY Agent_Rating DESC, rank_in_tier;


-- ---------------------------------------------------------------------
-- SECTION D: MARKET TRENDS & AFFORDABILITY
-- ---------------------------------------------------------------------

-- Q11. How has the average home price changed year-over-year, per city?
SELECT DISTINCT
    City,
    Year,
    Avg_Home_Price,
    Avg_Home_Price - LAG(Avg_Home_Price) OVER (PARTITION BY City ORDER BY Year) AS yoy_price_change
FROM market_trends
ORDER BY City, Year;

-- Q12. Which income bracket faces the least affordable housing
--      (highest price-to-income ratio), on average, across all cities?
SELECT
    Income_Bracket,
    ROUND(AVG(Affordability_Price_to_Income_Ratio), 2) AS avg_price_to_income_ratio,
    ROUND(AVG(Affordability_Change_YoY), 4)             AS avg_yoy_affordability_change
FROM market_trends
GROUP BY Income_Bracket
ORDER BY avg_price_to_income_ratio DESC;

-- Q13. Which cities have the strongest investor activity alongside
--      rising home prices — a signal of investor-driven demand?
SELECT
    City,
    ROUND(AVG(Investor_Activity_Score), 2) AS avg_investor_score,
    ROUND(AVG(Housing_Demand_Index), 2)    AS avg_demand_index,
    ROUND(AVG(Avg_Home_Price), 2)          AS avg_home_price
FROM market_trends
GROUP BY City
ORDER BY avg_investor_score DESC
LIMIT 10;

-- Q14. Does a higher interest rate correlate with fewer new
--      construction projects? (Simple year-level comparison.)
SELECT
    Year,
    ROUND(AVG(Interest_Rate), 2)          AS avg_interest_rate,
    ROUND(AVG(New_Construction_Count), 0) AS avg_new_construction
FROM market_trends
GROUP BY Year
ORDER BY Year;


-- ---------------------------------------------------------------------
-- SECTION E: CROSS-TABLE (PROPERTIES + MARKET TRENDS, JOINED ON CITY)
-- ---------------------------------------------------------------------

-- Q15. For each city, compare the actual average listing price in the
--      transactions data against the reported Avg_Home_Price from the
--      market trends data (most recent year available), to spot gaps.
SELECT
    p.City,
    ROUND(AVG(p.Listing_Price), 2) AS actual_avg_listing_price,
    mt.latest_avg_home_price
FROM properties_transactions p
JOIN (
    SELECT City, Avg_Home_Price AS latest_avg_home_price
    FROM market_trends
    WHERE (City, Year) IN (
        SELECT City, MAX(Year) FROM market_trends GROUP BY City
    )
    GROUP BY City, Avg_Home_Price
) mt ON mt.City = p.City
WHERE p.Listing_Price IS NOT NULL
GROUP BY p.City, mt.latest_avg_home_price
ORDER BY p.City;
