# 🏘️ Real Estate Market & Transaction Analysis — SQL Project

Business-focused SQL analysis of a multi-city real estate company's property listings, agent performance, and market trend data — built to answer real questions a brokerage or investment team would actually ask: *where is inventory priced right, which agents are performing, and where is the market headed?*

![SQL](https://img.shields.io/badge/SQL-MySQL%208.0-4479A1?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 📌 Overview

This project models a real estate dataset from raw source data (`properties_transactions`, `agents`, `market_trends`), loads it into a MySQL schema, and answers 15 business questions using pure SQL — covering data quality checks, pricing & inventory analysis, agent performance, and city-level market trends & affordability.

**Why this project:** Anyone can write a `SELECT * FROM table`. This project is built to show the SQL skills that actually matter — window functions for ranking and year-over-year trends, correct JOIN/GROUP BY.

---

## 🗂️ Dataset

Source data: 20,000 property listings, 5,000 agents, and 120 city/year/income-bracket market-trend records spanning **2019 – 2023** across 6 U.S. cities.

| Table | Rows | Description |
|---|---|---|
| `properties_transactions` | 20,000 | One row per property listing — type, city, size, price, status |
| `agents` | 5,000 | One row per agent — experience, deals closed, rating |
| `market_trends` | 120 | One row per City + Year + Income Bracket — home prices, demand, affordability |


**properties_transactions**
| Column | Type | Notes |
|---|---|---|
| Property_ID | INT, PK | Unique listing identifier |
| Type | VARCHAR | Apartment / House / Condo / Townhouse (3% missing) |
| City | VARCHAR | 6 distinct cities |
| Neighborhood | VARCHAR | Sub-area within the city |
| Size_SqFt | DECIMAL | Total area (1.8% missing) |
| Bedrooms / Bathrooms | INT | Room counts |
| Year_Built | INT | Construction year |
| Status | VARCHAR | Available / Rented / Sold |
| Listing_Price | DECIMAL | Asking price (2% missing) |
| Rental_Price | DECIMAL | Monthly rental amount |

**agents**
| Column | Type | Notes |
|---|---|---|
| Agent_ID | INT, PK | Unique agent identifier |
| Agent_Name | VARCHAR | Agent full name |
| Experience_Years | INT | Years in real estate |
| Total_Sales_Closed | INT | Properties sold |
| Total_Rentals_Closed | INT | Properties rented |
| Agent_Rating | DECIMAL | Average client rating out of 5 |

**market_trends**
| Column | Type | Notes |
|---|---|---|
| Trend_ID | INT, PK | Surrogate key (see note below) |
| City / Year | VARCHAR / INT | Reporting period |
| Income_Bracket | VARCHAR | $50k–$75k / $75k–$100k / $100k–$150k / $150k+ |
| Avg_Home_Price / Avg_Rent_Price | DECIMAL | City-level averages |
| Housing_Demand_Index / Investor_Activity_Score | DECIMAL | Composite indices |
| Unemployment_Rate / Interest_Rate | DECIMAL | Economic indicators |
| New_Construction_Count | INT | New builds that year |
| Affordability_Avg_Home_Price / Affordability_Median_Household_Income / Affordability_Price_to_Income_Ratio / Affordability_Change_YoY | DECIMAL | Affordability sub-metrics, broken out by income bracket |

</details>

## 📁 Project Structure

```
real-estate-sql-analysis/
│
├── README.md                    ← you are here
├── data/                        ← place the 3 source CSVs here (not included in repo)
│   ├── Final_Real_Estate_Properties_Transactions.csv
│   ├── Final_Real_Estate_Agents_Clients.csv
│   └── Final_Real_Estate_Market_Trends.csv
├── sql/
│   ├── 01_schema.sql               ← table definitions, keys, indexes
│   ├── 02_seed_data.sql            ← INSERT statements to load data/
│   └── 03_business_queries.sql     ← all analysis queries + inline insights

```

---

## ▶️ How to Run

1. Drop the 3 CSV files into `data/`.
1. Create the database and tables:
   ```bash
   mysql -u root -p < real_estate_sql_analysis < sql/01_schema.sql
   ```
2. Load the seed data:
   ```bash
   mysql -u root -p < real_estate_sql_analysis < sql/02_seeder_real_estate.sql
   ```
3. Run the analysis:
   ```bash
   mysql -u root -p  < real_estate_sql_analysis<  sql/03_business_queries.sql
   ```

Written and tested for **MySQL 8.0+** (uses `LAG()` window functions and CTEs). Adjust `DATE_FORMAT`/`DATEDIFF` calls if porting to PostgreSQL or SQLite.
Written and tested for **MySQL 8.0+** (uses `RANK()` and `LAG()` window functions).

---

## ❓ Business Questions Answered

All queries live in [`sql/03_business_queries.sql`](sql/03_business_queries.sql). Full list:

 **Data Quality**
    1. How many records are missing Listing_Price, Type, or Size_SqFt?
    2. What share of listings are missing a price, by city?
    
  **Pricing & Inventory**
    3. Average listing/rental price by property type?
    4. Which city has the priciest houses on average?
    5. Status breakdown (Available/Rented/Sold) by city?
    6. Best "value" neighborhoods (large size, low price/sqft)?
    7. How does rental price vary with bedroom count?
    
  **Agent Performance**
    8. Top 10 agents by total deals closed?
    9. Does experience correlate with client rating?
    10. Rank agents within rating tiers by deals closed (window function)?
    
   **Market Trends & Affordability**
    11. Year-over-year home price change by city (`LAG()`)?
    12. Which income bracket has the worst affordability ratio?
    13. Which cities show strong investor activity alongside rising prices?
    14. Does a higher interest rate line up with less new construction?
    
   **Cross-table**
    15. How does the actual average listing price compare to the reported market-trend average home price, per city?

---

## 💡 Key Insights & Recommendations

| # | Finding | Recommendation |
|---|---|---|
| 1 | Inventory is spread almost evenly across 6 cities (3,247–3,404 listings each — Miami highest) | No single city dominates supply; pricing and staffing strategy can be close to uniform across markets |
| 2 | Avg. listing price is close across property types (**Townhouse $1.057M** vs **House $1.034M** — only a 2% spread) | Property type alone isn't a strong price driver here — investigate size, neighborhood, and city as the real levers |
| 3 | Best price-per-sqft "value" areas cluster in **Hyde Park (Chicago)**, **Mission District (SF)**, and **Manhattan (NY)** — all under $514/sqft vs a ~$534/sqft city average | Flag these neighborhoods to value-focused buyers; worth a closer look at why they're underpriced relative to their city |
| 4 | Rental price is essentially flat across bedroom counts (**$4,186–$4,284/mo** for 1–5 bedrooms) | Rental pricing doesn't currently reward larger units — a segmentation or repricing review looks worthwhile |
| 5 | Inventory status skews toward closed deals: **49.5% Sold, 40.1% Rented, only 10.3% still Available** | Active inventory is thin — supports prioritizing new listing acquisition over demand generation right now |
| 6 | Agent experience shows **no meaningful correlation** with either client rating (r ≈ 0.01) or deals closed (r ≈ -0.01) | Tenure alone isn't a reliable proxy for agent quality in this data — performance reviews should weigh rating and deal volume directly, not years on the job |
| 7 | Home prices swing sharply year-over-year in every city (e.g. Los Angeles: -67% in 2020, then +430% in 2022) | Volatility this extreme signals thin/synthetic-style sampling in the trend data — treat single-year moves as noisy and prefer multi-year averages for forecasting |
| 8 | **Interest rate and new construction counts move inversely** (r ≈ -0.52) — the clearest real relationship in the market data | Use interest rate trajectory as an early signal for new-construction supply planning |
| 9 | Affordability is worst for the **$100k–$150k income bracket** (price-to-income ratio 6.48, the highest of all 4 brackets) — not the lowest earners | Counterintuitive finding worth validating: mid-upper earners may be priced out of the exact homes marketed to them; worth a targeted pricing/product review |

**Headline numbers:** 20,000 listings across 6 cities · $1.05M average listing price · $4,228 average monthly rental · 5,000 agents averaging 4.0★ and ~399 lifetime deals closed.


## 🛠️ Tech Stack

- **SQL** — MySQL 8.0 (joins, subqueries, conditional aggregation, window functions: `RANK()`, `LAG()`)
- **Python / pandas** — used only for source-data profiling and validation before writing the schema (not part of the analysis itself)

---

## 🎯 Conclusion

This project turns three raw real estate exports into decisions a brokerage could act on: **which neighborhoods offer genuine value, how agent performance should actually be measured, and which market signals (interest rates, affordability by income bracket) are real versus noise.** Every query pairs a SQL technique — window functions, grouped aggregation, cross-table joins — "so what," and the analysis is honest about where the data shows a real pattern versus where it doesn't.

---

## 📬 Contact

**Rajnath Vishwakarma**
[Linkedin](https://www.linkedin.com/in/rajnath-vishwakarma-b412b62a5/) · [Email](mailto:rajnath2410@gmail.com)

