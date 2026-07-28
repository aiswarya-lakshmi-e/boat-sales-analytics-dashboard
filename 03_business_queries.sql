-- ============================================================
-- boAt Sales Analytics Project
-- 03_business_queries.sql
-- Purpose: The full set of business analysis queries used to
-- derive every finding referenced in the Python analysis and
-- Power BI dashboard.
-- ============================================================

USE boat_sales_project;

-- ============================================================
-- SECTION 1: Revenue & Profit
-- ============================================================

-- Total Revenue and Total Profit (overall)
SELECT
    SUM(NetSales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit
FROM Sales_Data;

-- Revenue by Year
SELECT
    YEAR(OrderDate) AS Sales_Year,
    SUM(NetSales) AS Yearly_Revenue,
    SUM(Profit) AS Yearly_Profit
FROM Sales_Data
GROUP BY YEAR(OrderDate)
ORDER BY Sales_Year;

-- Revenue by Month (spotting seasonal patterns)
SELECT
    YEAR(OrderDate) AS Sales_Year,
    MONTH(OrderDate) AS Sales_Month,
    SUM(NetSales) AS Monthly_Revenue,
    SUM(Profit) AS Monthly_Profit
FROM Sales_Data
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Sales_Year, Sales_Month;

-- Investigate October's negative profit — is it the festival discounts?
SELECT
    YEAR(OrderDate) AS Sales_Year,
    IsFestivalPeriod,
    FestivalName,
    COUNT(*) AS Orders,
    AVG(DiscountPct) * 100 AS Avg_Discount_Pct,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit
FROM Sales_Data
WHERE MONTH(OrderDate) = 10
GROUP BY YEAR(OrderDate), IsFestivalPeriod, FestivalName
ORDER BY Sales_Year;

-- Compare against a normal (non-festival) month, e.g. June
SELECT
    YEAR(OrderDate) AS Sales_Year,
    AVG(DiscountPct) * 100 AS Avg_Discount_Pct,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit
FROM Sales_Data
WHERE MONTH(OrderDate) = 6
GROUP BY YEAR(OrderDate);

-- Average Order Value (AOV)
SELECT
    COUNT(*) AS Total_Orders,
    SUM(NetSales) AS Total_Revenue,
    AVG(NetSales) AS Avg_Order_Value,
    SUM(NetSales) / COUNT(*) AS Avg_Order_Value_Check
FROM Sales_Data;

-- ============================================================
-- SECTION 2: Top N Analysis
-- ============================================================

-- Top 10 Products by Revenue
SELECT
    p.ProductName,
    p.Category,
    SUM(s.NetSales) AS Total_Revenue,
    SUM(s.Quantity) AS Total_Units_Sold
FROM Sales_Data s
JOIN Product_Details p ON s.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Confirm Airdopes 141 is tagged as a Hero product
SELECT ProductName, Category, HeroFlag, DemandCluster, MRP
FROM Product_Details
WHERE ProductName = 'boAt Airdopes 141';

-- Top 10 Cities by Revenue
SELECT
    c.City,
    c.Region,
    SUM(s.NetSales) AS Total_Revenue,
    COUNT(*) AS Total_Orders
FROM Sales_Data s
JOIN Customer_Details c ON s.CustomerID = c.CustomerID
GROUP BY c.City, c.Region
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Top Categories by Revenue
SELECT
    p.Category,
    SUM(s.NetSales) AS Total_Revenue,
    SUM(s.Quantity) AS Total_Units_Sold,
    COUNT(*) AS Total_Orders
FROM Sales_Data s
JOIN Product_Details p ON s.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY Total_Revenue DESC;

-- ============================================================
-- SECTION 3: Channel Performance
-- ============================================================

-- Revenue and Orders by Channel
SELECT
    ch.ChannelName,
    ch.ChannelType,
    ch.BaseShare,
    SUM(s.NetSales) AS Total_Revenue,
    COUNT(*) AS Total_Orders
FROM Sales_Data s
JOIN Sales_Channel ch ON s.ChannelID = ch.ChannelID
GROUP BY ch.ChannelName, ch.ChannelType, ch.BaseShare
ORDER BY Total_Revenue DESC;

-- Average Order Value and Margin by Channel
SELECT
    ch.ChannelName,
    ch.ChannelType,
    COUNT(*) AS Total_Orders,
    SUM(s.NetSales) AS Total_Revenue,
    AVG(s.NetSales) AS Avg_Order_Value,
    SUM(s.Profit) AS Total_Profit,
    ROUND(SUM(s.Profit) / SUM(s.NetSales) * 100, 2) AS Profit_Margin_Pct
FROM Sales_Data s
JOIN Sales_Channel ch ON s.ChannelID = ch.ChannelID
GROUP BY ch.ChannelName, ch.ChannelType
ORDER BY Avg_Order_Value DESC;

-- ============================================================
-- SECTION 4: Customer Analysis
-- ============================================================

-- Revenue by Customer Segment
SELECT
    c.Segment,
    COUNT(DISTINCT s.CustomerID) AS Unique_Customers,
    COUNT(*) AS Total_Orders,
    SUM(s.NetSales) AS Total_Revenue,
    ROUND(AVG(s.NetSales), 2) AS Avg_Order_Value
FROM Sales_Data s
JOIN Customer_Details c ON s.CustomerID = c.CustomerID
GROUP BY c.Segment
ORDER BY Total_Revenue DESC;

-- Revenue by Age Band
SELECT
    c.AgeBand,
    COUNT(DISTINCT s.CustomerID) AS Unique_Customers,
    COUNT(*) AS Total_Orders,
    SUM(s.NetSales) AS Total_Revenue,
    ROUND(AVG(s.NetSales), 2) AS Avg_Order_Value
FROM Sales_Data s
JOIN Customer_Details c ON s.CustomerID = c.CustomerID
GROUP BY c.AgeBand
ORDER BY Total_Revenue DESC;

-- Revenue by Customer Tier (Tier 1/2/3 cities)
SELECT
    c.Tier,
    COUNT(DISTINCT s.CustomerID) AS Unique_Customers,
    COUNT(*) AS Total_Orders,
    SUM(s.NetSales) AS Total_Revenue,
    ROUND(AVG(s.NetSales), 2) AS Avg_Order_Value
FROM Sales_Data s
JOIN Customer_Details c ON s.CustomerID = c.CustomerID
GROUP BY c.Tier
ORDER BY Total_Revenue DESC;

-- Repeat vs. One-Time Buyers
SELECT
    CASE WHEN Order_Count = 1 THEN 'One-Time Buyer' ELSE 'Repeat Buyer' END AS Customer_Type,
    COUNT(*) AS Num_Customers,
    SUM(Total_Spend) AS Total_Revenue
FROM (
    SELECT CustomerID, COUNT(*) AS Order_Count, SUM(NetSales) AS Total_Spend
    FROM Sales_Data
    GROUP BY CustomerID
) customer_orders
GROUP BY Customer_Type;

-- ============================================================
-- SECTION 5: Order Health (returns & cancellations)
-- ============================================================

-- Order Status Breakdown
SELECT
    OrderStatus,
    COUNT(*) AS Orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Sales_Data), 2) AS Pct_of_Total,
    SUM(NetSales) AS Revenue_Impact
FROM Sales_Data
GROUP BY OrderStatus
ORDER BY Orders DESC;

-- Top Return Reasons
SELECT
    ReturnReason,
    COUNT(*) AS Orders,
    SUM(NetSales) AS Revenue_Lost
FROM Sales_Data
WHERE ReturnReason IS NOT NULL
GROUP BY ReturnReason
ORDER BY Orders DESC;

-- Top Cancellation Reasons
SELECT
    CancellationReason,
    COUNT(*) AS Orders,
    SUM(NetSales) AS Revenue_Lost
FROM Sales_Data
WHERE CancellationReason IS NOT NULL
GROUP BY CancellationReason
ORDER BY Orders DESC;

-- ============================================================
-- SECTION 6: Discount & Margin Analysis
-- ============================================================

-- Discount % and Profit Margin by Product Category
SELECT
    ProductCategory,
    ROUND(AVG(DiscountPct) * 100, 2) AS Avg_Discount_Pct,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit,
    ROUND(SUM(Profit) / SUM(NetSales) * 100, 2) AS Profit_Margin_Pct
FROM Sales_Data
GROUP BY ProductCategory
ORDER BY Avg_Discount_Pct DESC;

-- ============================================================
-- SECTION 7: Festival Impact
-- ============================================================

-- Revenue and Profit by Festival Name
SELECT
    FestivalName,
    COUNT(*) AS Orders,
    ROUND(AVG(DiscountPct) * 100, 2) AS Avg_Discount_Pct,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit,
    ROUND(SUM(Profit) / SUM(NetSales) * 100, 2) AS Profit_Margin_Pct
FROM Sales_Data
WHERE FestivalName IS NOT NULL
GROUP BY FestivalName
ORDER BY Revenue DESC;

-- ============================================================
-- SECTION 8: Delivery Performance
-- ============================================================

-- Average Delivery Days by Region
SELECT
    d.Region,
    COUNT(*) AS Total_Deliveries,
    ROUND(AVG(s.DeliveryDays), 2) AS Avg_Delivery_Days,
    ROUND(AVG(d.Rating), 2) AS Avg_Partner_Rating
FROM Sales_Data s
JOIN Delivery_Partner_Data d ON s.DeliveryPartnerID = d.DeliveryPartnerID
GROUP BY d.Region
ORDER BY Avg_Delivery_Days ASC;

-- ============================================================
-- SECTION 9: Window Functions
-- ============================================================

-- Rank Top 3 Products Within Each Category
SELECT Category, ProductName, Total_Revenue, Rnk
FROM (
    SELECT
        p.Category,
        p.ProductName,
        SUM(s.NetSales) AS Total_Revenue,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(s.NetSales) DESC) AS Rnk
    FROM Sales_Data s
    JOIN Product_Details p ON s.ProductID = p.ProductID
    GROUP BY p.Category, p.ProductName
) ranked
WHERE Rnk <= 3
ORDER BY Category, Rnk;

-- Month-over-Month Revenue Growth
SELECT
    Yr, Mth, Revenue,
    LAG(Revenue) OVER (ORDER BY Yr, Mth) AS Prev_Month_Revenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Yr, Mth))
        / LAG(Revenue) OVER (ORDER BY Yr, Mth) * 100, 2
    ) AS Growth_Pct
FROM (
    SELECT YEAR(OrderDate) AS Yr, MONTH(OrderDate) AS Mth, SUM(NetSales) AS Revenue
    FROM Sales_Data
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
) monthly
ORDER BY Yr, Mth;
