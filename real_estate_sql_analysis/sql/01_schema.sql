-- =====================================================================
-- Project   : Real Estate Market & Transaction Analytics (MySQL)
-- File      : 01_schema.sql
-- =====================================================================

DROP DATABASE IF EXISTS real_estate_db;
CREATE DATABASE real_estate_db;
USE real_estate_db;

-- ---------------------------------------------------------------------
-- Table 1: properties_transactions
-- Grain   : one row per property listing/transaction
-- Source  : Final_Real_Estate_Properties_Transactions.csv
-- ---------------------------------------------------------------------
CREATE TABLE properties_transactions (
    Property_ID     INT PRIMARY KEY,
    Type            VARCHAR(50)     NULL,   
    City            VARCHAR(100)    NOT NULL,
    Neighborhood    VARCHAR(100)    NULL,
    Size_SqFt       DECIMAL(10,2)   NULL,  
    Bedrooms        INT             NULL,
    Bathrooms       INT             NULL,
    Year_Built      INT             NULL,
    Status          VARCHAR(20)     NOT NULL,  -- Available / Rented / Sold
    Listing_Price   DECIMAL(14,2)   NULL,   -- missing in some rows
    Rental_Price    DECIMAL(12,2)   NULL
);

-- ---------------------------------------------------------------------
-- Table 2: agents
-- Grain   : one row per agent
-- Source  : Final_Real_Estate_Agents_Clients.csv
-- ---------------------------------------------------------------------
CREATE TABLE agents (
    Agent_ID             INT PRIMARY KEY,
    Agent_Name           VARCHAR(100) NOT NULL,
    Experience_Years     INT          NULL,
    Total_Sales_Closed   INT          NULL,
    Total_Rentals_Closed INT          NULL,
    Agent_Rating         DECIMAL(3,2) NULL
);

-- ---------------------------------------------------------------------
-- Table 3: market_trends
-- Grain   : one row per City + Year + Income_Bracket
-- Source  : Final_Real_Estate_Market_Trends.csv
-- ---------------------------------------------------------------------
CREATE TABLE market_trends (
    Trend_ID                                INT AUTO_INCREMENT PRIMARY KEY,
    City                                    VARCHAR(100)   NOT NULL,
    Year                                    INT            NOT NULL,
    Avg_Home_Price                          DECIMAL(14,2)  NULL,
    Avg_Rent_Price                          DECIMAL(12,2)  NULL,
    Housing_Demand_Index                    DECIMAL(6,2)   NULL,
    Unemployment_Rate                       DECIMAL(5,2)   NULL,
    Interest_Rate                           DECIMAL(5,2)   NULL,
    New_Construction_Count                  INT            NULL,
    Investor_Activity_Score                 DECIMAL(6,2)   NULL,
    Income_Bracket                          VARCHAR(20)    NOT NULL, 
    Affordability_Avg_Home_Price            DECIMAL(14,2)  NULL,
    Affordability_Median_Household_Income   DECIMAL(12,2)  NULL,
    Affordability_Price_to_Income_Ratio     DECIMAL(6,2)   NULL,
    Affordability_Change_YoY                DECIMAL(6,4)   NULL,
    UNIQUE KEY uq_city_year_bracket (City, Year, Income_Bracket)
);

