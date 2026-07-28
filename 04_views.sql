-- ============================================================
-- boAt Sales Analytics Project
-- 04_views.sql
-- Purpose: Reusable views that power the Power BI dashboard.
-- Each view pre-aggregates Sales_Data along one analytical
-- dimension so Power BI queries stay fast and simple.
-- ============================================================

USE boat_sales_project;

-- ------------------------------------------------------------
-- Monthly revenue & profit trend
-- ------------------------------------------------------------
CREATE VIEW vw_MonthlySales AS
SELECT YEAR(OrderDate) AS Yr, MONTH(OrderDate) AS Mth,
       SUM(NetSales) AS Revenue, SUM(Profit) AS Profit
FROM Sales_Data
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

-- ------------------------------------------------------------
-- Channel performance (includes BaseShare for actual-vs-expected
-- share comparisons in the dashboard)
-- ------------------------------------------------------------
CREATE VIEW vw_channelperformance AS
SELECT ch.ChannelName, ch.ChannelType, ch.BaseShare,
       SUM(s.NetSales) AS Revenue, SUM(s.Profit) AS Profit,
       COUNT(*) AS Orders
FROM Sales_Data s
JOIN Sales_Channel ch ON s.ChannelID = ch.ChannelID
GROUP BY ch.ChannelName, ch.ChannelType, ch.BaseShare;

-- ------------------------------------------------------------
-- Customer segment / age band / tier revenue breakdown
-- ------------------------------------------------------------
CREATE VIEW vw_CustomerSegments AS
SELECT c.Segment, c.AgeBand, c.Tier,
       SUM(s.NetSales) AS Revenue, COUNT(*) AS Orders
FROM Sales_Data s
JOIN Customer_Details c ON s.CustomerID = c.CustomerID
GROUP BY c.Segment, c.AgeBand, c.Tier;

-- ------------------------------------------------------------
-- Product-level revenue and units sold
-- ------------------------------------------------------------
CREATE VIEW vw_ProductPerformance AS
SELECT p.Category, p.ProductName, p.HeroFlag,
       SUM(s.NetSales) AS Revenue, SUM(s.Quantity) AS Units_Sold
FROM Sales_Data s
JOIN Product_Details p ON s.ProductID = p.ProductID
GROUP BY p.Category, p.ProductName, p.HeroFlag;

-- ------------------------------------------------------------
-- Order status / return / cancellation breakdown
-- ------------------------------------------------------------
CREATE VIEW vw_OrderHealth AS
SELECT OrderStatus, ReturnReason, CancellationReason,
       COUNT(*) AS Orders, SUM(NetSales) AS Revenue
FROM Sales_Data
GROUP BY OrderStatus, ReturnReason, CancellationReason;

-- ------------------------------------------------------------
-- Festival vs. non-festival period impact
-- (Non-festival rows are grouped under the label 'Non-Festival')
-- ------------------------------------------------------------
CREATE VIEW vw_festivalimpact AS
SELECT
    CASE WHEN FestivalName IS NULL THEN 'Non-Festival' ELSE FestivalName END AS Period,
    IsFestivalPeriod,
    COUNT(*) AS Orders,
    ROUND(AVG(DiscountPct) * 100, 2) AS Avg_Discount_Pct,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit,
    ROUND(SUM(Profit) / SUM(NetSales) * 100, 2) AS Profit_Margin_Pct
FROM Sales_Data
GROUP BY
    CASE WHEN FestivalName IS NULL THEN 'Non-Festival' ELSE FestivalName END,
    IsFestivalPeriod;

-- ------------------------------------------------------------
-- Category-level discount and profit margin
-- ------------------------------------------------------------
CREATE VIEW vw_categorymargin AS
SELECT
    ProductCategory AS Category,
    ROUND(AVG(DiscountPct) * 100, 2) AS Avg_Discount_Pct,
    SUM(NetSales) AS Revenue,
    SUM(Profit) AS Profit,
    ROUND(SUM(Profit) / SUM(NetSales) * 100, 2) AS Profit_Margin_Pct
FROM Sales_Data
GROUP BY ProductCategory;

-- ------------------------------------------------------------
-- Delivery performance by region
-- ------------------------------------------------------------
CREATE VIEW vw_deliveryperformance AS
SELECT
    d.Region,
    COUNT(*) AS Total_Deliveries,
    ROUND(AVG(s.DeliveryDays), 2) AS Avg_Delivery_Days,
    ROUND(AVG(d.Rating), 2) AS Avg_Partner_Rating
FROM Sales_Data s
JOIN Delivery_Partner_Data d ON s.DeliveryPartnerID = d.DeliveryPartnerID
GROUP BY d.Region;

-- ------------------------------------------------------------
-- Confirm all views were created successfully
-- ------------------------------------------------------------
SHOW FULL TABLES WHERE Table_type = 'VIEW';
