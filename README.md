# 🛒 Walmart Store Sales Performance Dashboard
### End-to-End Retail Analytics | SQL · Excel · Power BI · DAX

![Dashboard Preview](https://github.com/janienguyen2610/walmart-sales/blob/237aae36aee071aad03cde97827c989bcf66fbe6/Walmart_Dashboard_Preview.png)

---

## 📌 Project Overview

An end-to-end retail analytics project analyzing **45 Walmart stores across 3 years (2010–2012)** with **6,435 weekly sales records**. The project covers the full data pipeline — from raw SQL cleaning and aggregation, through Excel-based estimation and forecasting, to an interactive Power BI executive dashboard.

The dashboard was designed for a **board-level audience**: clean layout, dynamic KPI cards, interactive slicers, and a store performance overlap matrix that identifies which stores are truly driving results vs. which ones need attention.

---

## 🖥️ Dashboard Preview

> *Built in Power BI Desktop · Walmart brand theme (#004C97 · #FFC220)*

**Page 1 — Main Dashboard:**
- 📊 Quarterly sales trend line (2010–2012)
- 📅 Average monthly sales by week type (Holiday vs Normal)
- 🍩 Sales distribution by holiday event type
- 📉 Unemployment trend with macro context annotation
- 🗂️ Store performance overlap matrix (Overall Tier × Holiday Sensitivity)
- 🔢 6 dynamic KPI cards — Total Sales, Avg Weekly Sales, Holiday Lift, Peak Month, Store Count, Top Store
- 🔽 Interactive Year slicer filtering all visuals simultaneously

**Page 2 — Sales Outlook (Forecast):**
- 📈 Annual bar chart 2010–2015 showing actuals + projected growth
- Forecast years clearly distinguished from actuals
- Assumption disclaimer embedded on page

---

## 💡 Key Insights

| Insight | Finding |
|---|---|
| Holiday lift | Holiday weeks average **1.08×** normal weeks chain-wide |
| Peak month | **December** consistently highest — avg $1.4M/week |
| Star stores | Only **2 of 45** stores are both High Performers overall AND Holiday Driven |
| Problem stores | **4 stores** are Underperformers AND Holiday Resistant — need strategic review |
| Macro trend | Unemployment declined from **~9% → ~7%** (2010–2012), correlating with sales recovery (r = −0.11) |
| Top performer | **Store #20** — highest total revenue across all 3 years |
| Forecast | At +2.6% growth, projected to reach **.71B by 2015** (+10.7% vs 2011 baseline) |

---

## 🗂️ Data Pipeline

```
Raw CSV
   │
   ▼
MySQL (SQL cleaning & aggregation)
   │
   ▼
Excel (estimation, forecasting, classification)
   │
   ▼
Power BI (data model, DAX measures, dashboard)
```

---

## 🛠️ Step 1 — SQL Cleaning & Aggregation

**Tool:** MySQL  
**File:** `aggregate.sql`

### What was done:
- Converted `Date` column from string to proper `DATE` format using `STR_TO_DATE()`
- Created `Week_Type` column classifying each row as `Holiday` or `Normal` based on `Holiday_Flag`
- Classified holiday events by date range — Super Bowl, Labor Day, Thanksgiving, New Year's Eve
- Built a **Sales Lift Multiplier** using a self-join on a view, calculating Holiday/Normal average ratio per store
- Created `top_stores` view ranking stores by total and average weekly sales

### Key SQL techniques used:
- `ALTER TABLE` / `UPDATE` for schema changes and data transformation
- `CREATE OR REPLACE VIEW` for reusable aggregations
- **Self-join** on the same view to calculate Holiday vs Normal lift per store
- `CASE WHEN` for conditional classification
- `STR_TO_DATE()` for data type conversion

```sql
-- Sales Lift Multiplier via self-join
SELECT n.Store,
    ROUND(h.Average_weekly_sales / n.Average_weekly_sales, 2) AS Sales_lift_multiplier
FROM Sales_by_Week_Type n
JOIN Sales_by_Week_Type h ON n.Store = h.Store
WHERE n.Week_Type = 'Normal'
AND h.Week_Type = 'Holiday'
ORDER BY Sales_lift_multiplier DESC;
```

---

## 📊 Step 2 — Excel Analysis & Estimation

**Tool:** Microsoft Excel  
**Files:** `Cleaned_Data.xlsx` · `Sales_Growth_Final.xlsx` · `Store_Tiers.xlsx`

### Challenge: Partial Year Data
The dataset had **missing months**:
- **Jan 2010** — dataset starts February 2010
- **Nov–Dec 2012** — dataset ends October 2012

Comparing raw annual totals would make 2010 and 2012 look artificially low, distorting YoY growth.

### Solution: Seasonal Decomposition
Used **2011 as the base year** (only complete year) to estimate missing months:

```
Scale Factor (2010) = 2010 actual Feb–Dec ÷ 2011 actual Feb–Dec
Estimated Jan 2010  = Jan 2011 seasonal weight × 2011 annual total × Scale Factor
```

| Estimated Period | Point Estimate | ±5% Band |
|---|---|---|
| Jan 2010 | $164,018,554 | $155.8M – $172.2M |
| Nov 2012 | $215,569,924 | $204.8M – $226.3M |
| Dec 2012 | $295,490,477 | $280.7M – $310.3M |

### Adjusted Annual Totals

| Year | Total Sales | Notes |
|---|---|---|
| 2010 | $2.45B | Jan estimated |
| 2011 | $2.45B | Full actuals |
| 2012 | $2.51B | Nov–Dec estimated |

### Store Classification
Stores classified into three tiers based on total sales across all 3 years:

| Tier | Condition | Count |
|---|---|---|
| High Performer | Top quartile by total sales | 12 stores |
| Normal | Mid range | 29 stores |
| Underperformer | Bottom quartile | 4 stores |

Holiday sensitivity classified from SQL-derived lift multiplier:

| Tier | Lift Ratio | Count |
|---|---|---|
| Holiday Driven | ≥ 1.10 | 12 stores |
| Holiday Neutral | 1.0 – 1.09 | 29 stores |
| Holiday Resistant | < 1.0 | 4 stores |

### 3-Year Forecast (2013–2015)

Extended actuals to 2015 using **seasonal decomposition + growth rate** methodology:

**Step 1 — Determine growth rate**
Analyzed macro context to justify the rate assumption:
- 2010→2011 YoY: **−0.19%** (post-recession paralysis, high unemployment ~9%)
- 2011→2012 YoY: **+2.57%** (economic recovery, unemployment declining to ~7%)
- Selected **+2.6%** as the base rate — reflects recovery momentum, not the anomalous flat 2011

**Step 2 — Apply seasonal weights**
Each forecast month inherits the seasonal pattern from 2011 (base year), scaled up by the cumulative growth factor:

```
Forecast Month (Year Y) = 2011 Monthly Sales × (1.026)^(Y - 2011)
```

**Step 3 — Projected annual totals**

| Year | Projected Total | Growth |
|---|---|---|
| 2013 | $2.58B | +2.6% |
| 2014 | $2.64B | +2.6% |
| 2015 | $2.71B | +2.6% |

**Forecast presented on a dedicated Excel sheet** (`Sales_Growth_Final.xlsx`) and a **separate Power BI page** (`Sales Outlook`) — clearly separated from actuals to avoid misrepresentation.

> ⚠️ Forecast is directional only. Based on a single growth assumption. Do not present as audited projections.

---

## 📐 Step 3 — Power BI Data Model

**Tool:** Power BI Desktop  
**File:** `Walmart_Dashboard.pbix`

### Tables imported:
| Table | Rows | Purpose |
|---|---|---|
| `Cleaned Data` | 6,435 | Main fact table — weekly sales, macro factors |
| `Sales by Month` | 72 | Monthly aggregated with estimates + forecast |
| `Sales Tiers by Store` | 45 | Store dimension — Overall Tier, Holiday Tier |
| `Holiday Lift Ratio` | 45 | Per-store holiday sensitivity classification |
| `Date Bridge` | 36 | Bridge table enabling cross-table slicer filtering |

### Data Model Architecture:
```
Date Bridge (1)
    ├──→ Cleaned Data (*)      via YearMonth key
    └──→ Sales by Month (*)    via YearMonth key

Sales Tiers by Store (1)
    └──→ Holiday Lift Ratio    via Store #
```

### Why a Date Bridge?
`Cleaned Data` has weekly rows (multiple per month per store) and `Sales by Month` has monthly rows — they can't join directly on Date. The **Date Bridge** creates a unique YearMonth key (`201001`, `201002`...) that both tables relate to, enabling a single slicer to filter all visuals simultaneously.

---

## 🧮 DAX Measures

### KPI Measures

```dax
-- Holiday Sales Lift
Holiday Sales Lift = 
VAR AvgHoliday = CALCULATE(AVERAGE('Cleaned Data'[Weekly Sales]), 
                 'Cleaned Data'[Week Type] = "Holiday")
VAR AvgNormal  = CALCULATE(AVERAGE('Cleaned Data'[Weekly Sales]), 
                 'Cleaned Data'[Week Type] = "Normal")
RETURN FORMAT(DIVIDE(AvgHoliday, AvgNormal), "0.00") & "x"

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

-- Top Store
Top Store = 
"Store #" & " " & CALCULATE(
    SELECTEDVALUE('Cleaned Data'[Store]),
    TOPN(1, ALL('Cleaned Data'[Store]),
    CALCULATE(SUM('Cleaned Data'[Weekly Sales])), DESC))
```

### Matrix Conditional Formatting

```dax
-- Cell background color for Store Performance Overlap matrix
Cell Color = 
VAR OverallTier  = SELECTEDVALUE('Sales Tiers by Store'[Overall Tier])
VAR HolidayTier  = SELECTEDVALUE('Sales Tiers by Store'[Holiday Tier])
RETURN
    IF(OverallTier = "High Performer"  && HolidayTier = "Holiday Driven",   "#70C48A",
    IF(OverallTier = "Underperformer"  && HolidayTier = "Holiday Resistant","#E87A75",
    IF(OverallTier = "High Performer"  && HolidayTier = "Holiday Resistant","#F7C96E",
    IF(OverallTier = "Underperformer"  && HolidayTier = "Holiday Driven",   "#F7C96E",
    "#E8E8E8"))))
```

---

## 📁 File Structure

```
walmart-sales-dashboard/
│
├── README.md
│
├── data/
│   ├── Walmart_Sales_raw.csv          # Original raw dataset
│   ├── Cleaned_Data.xlsx              # Cleaned actuals (6,435 rows)
│   ├── Sales_Growth_Final.xlsx        # Monthly sales + estimates + forecast
│   └── Store_Tiers.xlsx               # Store classifications
│
├── sql/
│   └── aggregate.sql                  # Full SQL cleaning & aggregation script
│
├── powerbi/
│   └── Walmart_Dashboard.pbix         # Power BI dashboard file
│
└── screenshots/
    ├── dashboard_page1.png            # Main dashboard screenshot
    ├── dashboard_page2_forecast.png   # Sales Outlook page screenshot
    └── data_model.png                 # Power BI model view
```

---

## 🔧 Tools & Technologies

| Tool | Usage |
|---|---|
| **MySQL** | Data cleaning, type conversion, aggregation, self-joins |
| **Microsoft Excel** | Seasonal decomposition, estimation, classification, forecasting |
| **Power BI Desktop** | Data modeling, DAX measures, interactive dashboard |
| **DAX** | KPI measures, conditional formatting, dynamic filtering |

---

## ⚠️ Data Notes

- **Estimated values**: Jan 2010 and Nov–Dec 2012 are seasonally estimated using 2011 as the base year. These are clearly flagged throughout and should not be presented as audited figures.
- **Forecast values** (2013–2015): Based on +2.6% annual growth assumption derived from the 2011→2012 recovery trend. Treated as directional only.
- **Raw data source**: Public Walmart sales dataset widely used in data science education.
- **Holiday classification**: Based on date ranges — some edge cases may differ from Walmart's actual promotional calendar.

---

## 👤 Author

Built as a portfolio project demonstrating end-to-end data analytics skills across SQL, Excel, and Power BI.

*Connect on LinkedIn · View more projects on GitHub*
