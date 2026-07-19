# 📊 India CPI Inflation Analysis (2013–2023)

A category-by-category breakdown of India's Consumer Price Index (CPI) — built to answer the questions a policymaker, economist, or household-budget analyst would actually ask: *what's driving inflation, how did COVID-19 change the picture, and does inflation track global commodity prices like crude oil?*

![Excel](https://img.shields.io/badge/Tool-Excel-217346?logo=microsoftexcel&logoColor=white)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 📌 Overview

This project analyzes 10+ years of official All-India CPI data (2013–May 2023) across 28 consumption categories and 3 sectors (Rural / Urban / Rural+Urban). It's built entirely in Excel — raw data on one sheet, five focused exploratory analyses on the rest — and answers real economic questions: which categories dominate the CPI basket, how inflation trended year over year, what COVID-19 did to the cost of living, and whether food/transport inflation tracks global crude oil prices.

**Why this project:** Anyone can chart a CPI index over time. This project is built to show the analytical skills that actually matter — decomposing a composite index into its drivers, isolating a shock event (COVID-19) with a clean before/after comparison, and testing an external hypothesis (crude oil correlation).

---

## 🗂️ Dataset

**Source:** Official All-India CPI (Combined) data, monthly, January 2013 – May 2023 (124 months × 3 sectors = 372 records).

| Sheet | Rows/Records | Description |
|---|---|---|
| `Main data` | 372 | Raw monthly CPI index values — 28 categories + General Index, by Sector/Year/Month |
| `EDA1` | — | Category-wise contribution to the CPI basket (May 2023 snapshot) |
| `EDA2` | — | Year-over-year CPI growth, 2017–2023, with category-level driver breakdown |
| `EDA 3` | — | Food category deep-dive: month-on-month trend + individual item YoY (Jun 2022–May 2023) |
| `EDA4` | — | Before vs. after COVID-19 inflation comparison, by category |
| `EDA5` | — | Correlation of each category against crude oil price fluctuations (2021–2023) |

**Data Dictionary — `Main data`**

<details>
<summary>Click to expand column-level detail</summary>

| Column | Notes |
|---|---|
| Sector | Rural / Urban / Rural+Urban |
| Year, Month | Jan 2013 – May 2023 |
| 28 category columns | e.g. Cereals and products, Meat and fish, Egg, Milk and products, Oils and fats, Fruits, Vegetables, Pulses and products, Sugar and Confectionery, Spices, Housing, Fuel and light, Health, Transport and communication, Education, Miscellaneous, etc. — each an index value (base year = 100) |
| General index | The composite CPI value for that Sector/Year/Month |

Note: a small number of `Housing` values are marked `NA` for the Rural sector — housing isn't tracked separately for rural India in the official CPI methodology, so this is expected, not missing data.

</details>

---

## 🔍 Analysis Modules

**1. CPI Basket Composition (`EDA1`)**
Breaks the General Index down into 8 broader categories (Food, Pan/Tobacco, Clothing, Housing, Health & Education, Transport & Comm., Recreation, Miscellaneous) as of May 2023, both in absolute index terms and as a % share — showing what's actually driving the composite number.

**2. Year-over-Year Trend, 2017–2023 (`EDA2`)**
Tracks January→December growth in the General Index for six consecutive years, then decomposes the peak growth year into category-level contributors to explain *why* that year spiked.

**3. Food Category Deep-Dive (`EDA 3`)**
Zooms into the single largest basket component. Tracks month-on-month % change over a 12-month window (Jun 2022–May 2023) across sectors, then breaks food into its 13 sub-categories to find which items rose and which fell over the same window.

**4. COVID-19 Before/After Comparison (`EDA4`)**
Splits the data into a clean 12-month "before" window (Mar 2019–Feb 2020) and "after" window (Mar 2020–Feb 2021), ranks categories by YoY inflation in each, and compares the top drivers pre- vs. post-pandemic.

**5. Crude Oil Correlation (`EDA5`)**
Runs a Pearson correlation between each of the 28 categories and month-on-month imported crude oil price changes (2021–2023), to test — rather than assume — which parts of the CPI basket actually move with global oil prices.

---

## 💡 Key Insights & Recommendations

| # | Finding | Recommendation |
|---|---|---|
| 1 | **Food & beverages is by far the largest driver of CPI**, accounting for ~49.6% of the Rural inflation basket and ~50.3% of Urban (May 2023) | Any national inflation-control policy has to target food supply chains first — everything else is a secondary lever |
| 2 | CPI growth peaked in **2019 at +7.18%** (Jan→Dec), the highest of the 2017–2023 window, driven by a **10.99% jump in the Food category** alone that year | Food-category volatility should be treated as the leading indicator for headline inflation risk, not a lagging one |
| 3 | Within food (Jun 2022–May 2023): **Spices rose 16.52% YoY** — the single largest food-item increase — while **Oils and fats fell -15.38%**, the largest decline | These offsetting swings show why "food inflation" as one number can be misleading — spice/import-driven categories and oil/edible-fat categories are moving in opposite directions and need separate policy attention |
| 4 | **Pre-COVID (Mar'19–Feb'20)**, Food & Beverages inflation was already elevated at ~41%, led by Vegetables (+28.7%) and Pulses (+15.8%) | Food price pressure predates the pandemic — COVID accelerated an existing trend rather than creating a new one |
| 5 | **Post-COVID (Mar'20–Feb'21)**, the driver shifted: **Oils and fats jumped to +21.0%** (from a much smaller pre-COVID contribution) and **Essential Services (Transport/Fuel) inflation rose to ~20%**, while Food & Beverages growth *eased slightly* to ~40.5% | The pandemic didn't just raise inflation — it **changed which categories** were driving it, from perishables toward supply-chain-sensitive goods (edible oils) and mobility costs. Recovery policy needs to track category rotation, not just the headline number |
| 6 | Healthcare CPI rose consistently through the pandemic period | Confirms sustained pandemic-era pressure on medical costs — relevant for healthcare subsidy/insurance policy design |
| 7 | Crude oil correlation is **weak across almost the entire CPI basket** — only **Oils and fats (r ≈ 0.44)** and **Meat and fish (r ≈ 0.40)** show even a moderate relationship; everything else, including the General Index itself (r ≈ 0.08), is weak-to-none | The common assumption that "oil prices drive inflation" doesn't hold in this data at the category level — fuel/transport policy shouldn't be the default lever assumed to control broad CPI; the transmission is much narrower than expected |

**Headline numbers:** General Index rose from **108.4 (Jan 2013)** to **179.1 (May 2023)** for Rural+Urban India — a **~65% increase in the overall cost of living over 10 years**. Food & Beverages consistently makes up **~half of the entire CPI basket**, more than all other categories combined.

> **Caveat:** the crude-oil correlation analysis (module 5) only covers 2021–2023 — a period that includes both the post-COVID demand rebound and the 2022 oil price shock, so the weak correlations found should be read as specific to that window, not a permanent structural fact about the Indian economy. Longer-run data would be needed to confirm it holds across other oil price cycles.

---

## 🛠️ Tech Stack

- **Excel** — pivot-style aggregation, month-on-month and year-over-year % change formulas, `CORREL()` for the crude oil analysis, and conditional formatting for highlighting peak/trough months
- Raw data verified against the official General Index series before drawing conclusions (spot-checked in this write-up)

---

## 🎯 Conclusion

Ten years of CPI data compress into a small number of decisions worth acting on: **food is the structural driver of Indian inflation, COVID-19 rotated *which* categories drove costs rather than just raising the total, and the "oil prices cause inflation" assumption doesn't hold up category-by-category.** Each module in this workbook pairs a specific analytical technique — basket decomposition, before/after event comparison, correlation testing — with a plain-English takeaway, because an index number on its own isn't an insight until it changes what someone would do next.

---

## 📬 Contact

**Rajnath Vishwakarma**
[Linkedin](https://www.linkedin.com/in/rajnath-vishwakarma-b412b62a5/) · [Email](mailto:rajnath2410@gmail.com)
