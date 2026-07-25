# 📱 PhonePe — Digital Payments Data Analysis

**An end-to-end EDA project analyzing 4 years (2018–2021) of PhonePe transaction, user, and device data across all Indian states and districts — uncovering growth trends, regional payment behavior, and business opportunities.**

![Python](https://img.shields.io/badge/Python-3.10-3776AB?style=flat-square&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Wrangling-150458?style=flat-square&logo=pandas&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-Visualization-11557C?style=flat-square)
![Seaborn](https://img.shields.io/badge/Seaborn-Visualization-4C72B0?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

---

## 📌 Project Overview

PhonePe is one of India's largest digital payment platforms. This project analyzes **PhonePe Pulse** style data — transactions, registered users, app opens, and device usage — at both **state** and **district** level, across **2018–2021**.

The goal: turn raw transaction logs into **clear, decision-ready business insights** — which states are growing fastest, where digital payments still have room to expand, what device types dominate the user base, and how transaction behavior differs by region.


---

## 🗂️ Datasets Used

| Sheet | Description |
|---|---|
| `State_Txn and Users` | Quarterly transactions, amount, ATV, users, app opens — by state |
| `State_TxnSplit` | Transactions broken down by type (P2P, Merchant, Recharge, etc.) |
| `State_DeviceData` | Registered users by mobile device brand — by state |
| `District_Txn and Users` | Same transaction metrics at district level |
| `District Demographics` | Population, area, density per district |

---

## 🔍 What This Project Covers

- ✅ Data loading, structure checks & missing value analysis
- ✅ Exploratory Data Analysis (trends, top/bottom states, ATV, app usage)
- ✅ Data quality checks (state-vs-district consistency validation)
- ✅ Data merging across 5 datasets for deeper analysis
- ✅ Correlation analysis (population, density, users, transactions)
- ✅ 17+ visualizations — bar charts, line trends, pie charts, heatmaps, scatter plots
- ✅ Business insights & recommendations

---

## 📊 Key Visual Insights



**Transaction Growth (2018–2021)**


**Users vs Transactions Correlation**



**Transaction Type Split (Rajasthan, 2019 Q2)**


**Device Brand Usage Ratio (Uttar Pradesh)**

**Registered Users vs Population by State**


**Correlation Matrix — Key Metrics**


📁 See the images folder for all  charts, and the full notebook for the complete analysis with code.

---

## 💡 Business Insights

1. **Karnataka, Maharashtra, Telangana, Andhra Pradesh, and Rajasthan** drive the highest transaction volumes — these are PhonePe's mature markets. Focus here should shift from acquisition to **retention and fraud prevention**.

2. **High-volume, low-ATV states** (Karnataka, Maharashtra, West Bengal) show frequent small transactions — a sign of strong daily-use habits (recharges, small transfers). Great for engagement, lower per-transaction revenue.

3. **Low-volume, high-ATV states** (Ladakh, Andaman & Nicobar, Mizoram, Manipur, Nagaland) show fewer but larger transactions — a signal that **merchant payment infrastructure is under-developed** there. Strong opportunity for local merchant onboarding.

4. **Peer-to-peer payments dominate (~50%)** of all transactions nationwide, with merchant payments second. Pushing merchant QR adoption can build stickier, higher-value daily usage.

5. **User penetration vs population** is highest in Delhi, Karnataka, Telangana, and Dadra & Nagar Haveli (urban, high smartphone density) — while Assam, Bihar, and Jammu & Kashmir lag behind, marking them as **priority markets for rural expansion**.

6. **Xiaomi is the most common device brand** among PhonePe users in nearly every state — showing the core user base runs on budget/mid-range Android phones. Product decisions (app size, offline mode, low-end optimization) should reflect this.

7. **Transactions and app opens grew sharply from 2019 onward**, aligning with India's UPI adoption wave and the COVID-19 push toward cashless payments.

8. A **data quality gap was found** between state-level and district-level totals for Andhra Pradesh (~₹670 Bn mismatch) — flagged for data engineering review before using state totals for financial reporting.

---

## 🛠️ Tech Stack

- **Python** — Pandas, NumPy
- **Visualization** — Matplotlib, Seaborn
- **Environment** — Jupyter Notebook

---

## 📂 Repository Structure

```
├── README.md
├── data/
│   └── phonepe.xlsx  
├── notebook/
│   └── Phone_pe.html   
│   └── Phone_pe.ipynb   
└── images/
    ├── 01_top_district_by_population.png
    ├── 02_app_opens_trend_mp.png
    ├── ...
    └── 17_correlation_demographics_transactions.png
```

---

## 🚀 How to View

- **Quick look:** Browse the charts in the [`images/`](images) folder or scroll up in this README.
- **Full analysis:** Open [`notebook/Phone_pe.ipynb`](notebook/Phone_pe.ipynb) in any browser — no setup needed.

---

## 🙋 About

This project was built as a case study to practice real-world data analysis: cleaning messy multi-sheet data, validating consistency across granularities (state vs district), merging datasets, and translating numbers into business recommendations.

**Feel free to connect if you'd like to discuss the analysis or collaborate!**

**Rajnath Vishwakarma**
[Linkedin](https://www.linkedin.com/in/rajnath-vishwakarma-b412b62a5/) ·  [Email](mailto:rajnath2410@gmail.com) ·   [ Github ](https://github.com/RajnathVishwakarma) 
