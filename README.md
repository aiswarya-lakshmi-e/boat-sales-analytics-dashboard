# boAt Sales Analytics Dashboard

An end-to-end data analytics project covering the full pipeline from raw data to an interactive business dashboard — **SQL → Python → Power BI**.

Built on a simulated 2-year (2023–2024) sales dataset for boAt, an Indian audio and wearables brand, covering 975,000 transactions across 106 products, 7 sales channels, and 150,000 customers.

---

## 📊 Dashboard Preview

[![Executive Overview](images/dashboard_screenshots/01_executive_overview.png)](https://github.com/aiswarya-lakshmi-e/boat-sales-analytics-dashboard/blob/main/Executive%20Overview.png)

*See `images/dashboard_screenshots/` for all 5 dashboard pages.*

---

## 🧱 Project Structure

```
boat-sales-analytics-dashboard/
├── sql/
│   ├── 01_create_tables.sql        # Schema design, data types, keys
│   ├── 02_load_and_clean_data.sql  # CSV loading, date cleanup, validation
│   ├── 03_business_queries.sql     # 24 business analysis queries
│   └── 04_views.sql                # 8 views powering the Power BI dashboard
├── python/
│   └── boat_sales_analysis.py      # Pandas analysis + matplotlib/seaborn charts
├── powerbi/
│   └── boAT_Analysis.pbix          # 5-page interactive Power BI dashboard
├── images/
│   ├── monthly_revenue_profit.png
│   ├── channel_performance.png
│   ├── customer_segment_revenue.png
│   ├── top_products.png
│   ├── festival_margin_comparison.png
│   └── dashboard_screenshots/      # Power BI page-by-page screenshots
└── README.md
```

---

## 🛠️ Tools & Skills Used

| Stage | Tools | What was done |
|---|---|---|
| **Data Modeling & SQL** | MySQL, MySQL Workbench | Schema design, primary/foreign keys, data cleaning, 24 business queries, window functions (`RANK()`, `LAG()`), 8 reusable views |
| **Analysis & Visualization** | Python (Pandas, Matplotlib, Seaborn) | Exploratory analysis, static chart generation for reporting |
| **Dashboard** | Power BI, DAX | 5-page interactive dashboard, custom DAX measures, conditional formatting, slicers, custom dark theme |

---

## 🔍 Key Findings

1. **A single hero product drives ~21% of total revenue.** boAt Airdopes 141 outsold its nearest competitor by more than 3x.

2. **Every festival sale period ran at a net loss.** All 9 festival events (Big Festive Sale, Republic Day Sale, etc.) averaged a ~50% discount and a **negative** profit margin (−2% to −2.4%), while non-festival periods held a healthy 22.76% margin — a discounting policy issue, not a one-off.

3. **Online marketplaces drive the most revenue but the least profit.** Amazon and Flipkart together generate ~53% of revenue but operate at only ~4% profit margin, versus ~27% margin for offline retail channels.

4. **Retention is strong.** Repeat customers account for ~99% of total revenue.

5. **Product-quality issues outweigh "changed my mind" returns.** Combined sound/charging/connectivity defects account for more returns than simple buyer's remorse — a fixable QC signal.

6. **Cancellations are operational, not product-related.** Address issues and payment/COD failures dominate cancellation reasons — a logistics fix, not a product one.

7. **Two categories (Soundbars, Projectors) run at a loss** despite below-average discounting, pointing to a cost-structure issue rather than a pricing one.

8. **Revenue growth is highly seasonal and predictable**, peaking every March and October–November across both years.

---

## 🗄️ Dataset

Five source tables: `Sales_Data` (fact, 975K rows), `Customer_Details`, `Product_Details`, `Sales_Channel`, `Delivery_Partner_Data` (dimensions) — structured as a star schema.

---

## 📈 Dashboard Pages

1. **Executive Overview** — headline KPIs, monthly revenue/profit trend, channel mix, top products
2. **Sales & Seasonality** — festival vs. non-festival margin comparison, month-over-month growth
3. **Product Performance** — top products, category revenue share, hero vs. non-hero products, category margins
4. **Channel & Customer Insights** — channel revenue vs. margin, actual vs. expected channel share, customer segment analysis
5. **Order Health & Delivery** — order status breakdown, return/cancellation reason analysis

---

## 🚀 How to Explore This Project

- **SQL:** Run the scripts in `sql/` in numbered order against a MySQL instance to rebuild the schema and views from scratch.
- **Python:** Open `python/boat_sales_analysis.py` — requires `pandas`, `matplotlib`, `seaborn`.
- **Power BI:** Open `powerbi/boAT_Analysis.pbix` in Power BI Desktop (free). Note: live data refresh requires a local MySQL connection matching the schema above; static exploration is possible without it.

---

*This project was built as a self-directed learning exercise in SQL, Python, and Power BI, working end-to-end from raw CSVs to a finished business dashboard.*
