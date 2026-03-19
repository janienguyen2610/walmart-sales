# 🛒 Walmart Store Sales Performance Dashboard
### End-to-End Retail Analytics | SQL · Excel · Power BI · DAX

**Dashboard Preview**
| Executive Overview | Store Performance | Sales Outlook |
|---|---|---|
| ![](Walmart_dashboard_page0.jpg) | ![](Walmart_dashboard_page1.jpg) | ![](Walmart_dashboard_page2.jpg) |
---
`.pbix` file available for download · **Data:** [Kaggle Walmart Sales](https://www.kaggle.com/datasets/mikhail1681/walmart-sales)

45 stores · 6,435 weekly records · 2010–2012

---


## 📌 Project Overview

An end-to-end retail analytics project analyzing **45 Walmart stores across 3 years (2010–2012)** with **6,435 weekly sales records**. The project covers the full data pipeline — from raw SQL cleaning and aggregation, through Excel-based estimation and forecasting, to a 3-page interactive Power BI executive dashboard.

The dashboard was designed for a **board-level audience**: clean layout, dynamic KPI cards, interactive slicers, store performance overlap matrix, and forward-looking sales outlook — with business implications embedded directly into the analysis.

> 📁 The .pbix file is available for download!

---
## Pipeline

```
Raw CSV → MySQL (cleaning & aggregation) → Excel (estimation & forecasting) → Power BI (dashboard)
```

---

## Step 1 — SQL

- Converted `Date` from string to `DATE` via `STR_TO_DATE()`
- Classified rows as `Holiday` / `Normal` and tagged holiday events by date range
- Built a **Sales Lift Multiplier** via self-join on a week-type aggregation view

```sql
SELECT n.Store,
    ROUND(h.Average_weekly_sales / n.Average_weekly_sales, 2) AS Sales_lift_multiplier
FROM Sales_by_Week_Type n
JOIN Sales_by_Week_Type h ON n.Store = h.Store
WHERE n.Week_Type = 'Normal' AND h.Week_Type = 'Holiday'
ORDER BY Sales_lift_multiplier DESC;
```

---

## Step 2 — Excel

**Problem:** Dataset starts Feb 2010 and ends Oct 2012 — raw annual totals distort YoY growth.

**Solution:** Used 2011 (only complete year) as base to estimate Jan 2010 and Nov–Dec 2012 via seasonal decomposition:

```
Estimated Month = Monthly seasonal weight × 2011 annual total × Scale Factor
```

Stores classified into Overall Tier (quartile rank) and Holiday Tier (lift ratio from SQL). Forecast extended to 2015 using +2.6% CAGR — the 2011→2012 recovery rate, not the flat 2010→2011 rate which reflected post-recession paralysis.

```
Forecast Month (Year Y) = 2011 Monthly Sales × (1.026)^(Y − 2011)
```

> ⚠️ Directional only. Do not present as audited projections.

---

## Step 3 — Power BI

**Tables:** `Cleaned Data` (6,435 rows) · `Sales by Month` (72 rows) · `Sales Tiers by Store` · `Holiday Lift Ratio` · `Date Bridge`

**Why a Date Bridge?** Weekly and monthly tables can't join directly on Date. A DAX-created YearMonth key (`201001`, `201002`...) lets a single Year slicer filter all visuals simultaneously.

```dax
-- Peak Month
Peak Month = 
VAR BestMonth = CALCULATE(
    SELECTEDVALUE('Cleaned Data'[Month]),
    TOPN(1, ALL('Cleaned Data'[Month]),
         CALCULATE(AVERAGE('Cleaned Data'[Weekly Sales])), DESC))
RETURN SWITCH(BestMonth,
    1,"January", 2,"February", 3,"March", 4,"April",
    5,"May", 6,"June", 7,"July", 8,"August",
    9,"September", 10,"October", 11,"November", 12,"December")

-- Matrix conditional formatting
Cell Color = 
VAR OverallTier = SELECTEDVALUE('Sales Tiers by Store'[Overall Tier])
VAR HolidayTier = SELECTEDVALUE('Sales Tiers by Store'[Holiday Tier])
RETURN
    IF(OverallTier = "High Performer"  && HolidayTier = "Holiday Driven",   "#70C48A",
    IF(OverallTier = "Underperformer"  && HolidayTier = "Holiday Resistant","#E87A75",
    IF(OverallTier = "High Performer"  && HolidayTier = "Holiday Resistant","#F7C96E",
    IF(OverallTier = "Underperformer"  && HolidayTier = "Holiday Driven",   "#F7C96E",
    "#E8E8E8"))))
```

---

## File Structure

```
walmart-sales/
├── data/
│   ├── Walmart_Sales_raw.csv
│   └── Janie Nguyen_Walmart Sales Cleaned.xlsx
├── sql/
│   └── Janie Nguyen_Walmart_SQL.sql
├── powerbi/
│   └── Janie Nguyen_Walmart Project.pbix
└── screenshots/
```

---
## 🔧 Tools & Technologies

| Tool | Usage |
|---|---|
| **MySQL** | Data cleaning, type conversion, aggregation, self-joins |
| **Microsoft Excel** | Seasonal decomposition, estimation, classification, forecasting |
| **Power BI Desktop** | Data modeling, DAX measures, 3-page interactive dashboard |
| **DAX** | KPI measures, conditional formatting, dynamic filtering |

---
## ⚠️ Data Notes

- **Estimated values**: Jan 2010 and Nov–Dec 2012 are seasonally estimated using 2011 as the base year. Clearly flagged throughout — do not present as audited figures.
- **Forecast values** (2013–2015): Based on +2.6% annual growth assumption derived from the 2011→2012 recovery trend. Directional only.
- **Raw data source**: Public Walmart sales dataset widely used in data science education.
- **Holiday classification**: Based on date ranges — some edge cases may differ from Walmart's actual promotional calendar.

---

## 👤 Author

**Janie Nguyen**  
Financial Analyst | SQL · Excel · Power BI · DAX

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/janieanhnguyen/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-black)](https://github.com/janienguyen2610)
