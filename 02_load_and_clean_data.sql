-- ============================================================
-- boAt Sales Analytics Project
-- 02_load_and_clean_data.sql
-- Purpose: Load the 5 source CSVs into their tables, convert
-- text date columns into real DATE types, and validate that the
-- load completed cleanly (row counts, orphan records, duplicates).
-- ============================================================

USE boat_sales_project;

-- ------------------------------------------------------------
-- Load data (parent/dimension tables first, fact table last)
-- Note: paths below reflect the local machine used during
-- development; update to your own file locations before running.
-- ------------------------------------------------------------

LOAD DATA LOCAL INFILE 'C:/Users/user/OneDrive/Desktop/SQLData/Customer_Details.csv'
INTO TABLE Customer_Details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    CustomerID, SignupDate, Gender, AgeBand, Segment, Tier,
    City, State, Region, PreferredChannel, ActivityWeight
);
SELECT COUNT(*) FROM Customer_Details;   -- expect 150000

LOAD DATA LOCAL INFILE 'C:/Users/user/OneDrive/Desktop/SQLData/Product_Details.csv'
INTO TABLE Product_Details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM Product_Details;    -- expect 106

LOAD DATA LOCAL INFILE 'C:/Users/user/OneDrive/Desktop/SQLData/Sales_Channel.csv'
INTO TABLE Sales_Channel
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM Sales_Channel;      -- expect 7

LOAD DATA LOCAL INFILE 'C:/Users/user/OneDrive/Desktop/SQLData/Delivery_Partner_Data.csv'
INTO TABLE Delivery_Partner_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM Delivery_Partner_Data; -- expect 180

LOAD DATA LOCAL INFILE 'C:/Users/user/OneDrive/Desktop/SQLData/Sales_Data.csv'
INTO TABLE Sales_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM Sales_Data;         -- expect 975000

-- ------------------------------------------------------------
-- Date cleanup
-- Customer_Details.SignupDate was already stored as YYYY-MM-DD
-- text, so a direct type change is enough.
-- Sales_Data.OrderDate was stored as DD-MM-YYYY text, so it
-- needs STR_TO_DATE() to parse it correctly before conversion.
-- ------------------------------------------------------------

ALTER TABLE Customer_Details MODIFY COLUMN SignupDate DATE;

ALTER TABLE Sales_Data ADD COLUMN OrderDate_Fixed DATE;
UPDATE Sales_Data SET OrderDate_Fixed = STR_TO_DATE(OrderDate, '%d-%m-%Y');
ALTER TABLE Sales_Data DROP COLUMN OrderDate;
ALTER TABLE Sales_Data CHANGE OrderDate_Fixed OrderDate DATE;

-- Verify the conversions worked
SELECT SignupDate FROM Customer_Details LIMIT 5;
SELECT OrderDate FROM Sales_Data LIMIT 5;

SELECT COUNT(*) FROM Customer_Details WHERE SignupDate IS NULL; -- expect 0
SELECT COUNT(*) FROM Sales_Data WHERE OrderDate IS NULL;         -- expect 0

-- ------------------------------------------------------------
-- Validation: orphan record checks
-- Confirms every foreign key in Sales_Data has a matching row
-- in its parent dimension table.
-- ------------------------------------------------------------

SELECT COUNT(*) FROM Sales_Data s
LEFT JOIN Product_Details p ON s.ProductID = p.ProductID
WHERE p.ProductID IS NULL;   -- expect 0

SELECT COUNT(*) FROM Sales_Data s
LEFT JOIN Sales_Channel ch ON s.ChannelID = ch.ChannelID
WHERE ch.ChannelID IS NULL;  -- expect 0

SELECT COUNT(*) FROM Sales_Data s
LEFT JOIN Delivery_Partner_Data d ON s.DeliveryPartnerID = d.DeliveryPartnerID
WHERE d.DeliveryPartnerID IS NULL; -- expect 0

-- ------------------------------------------------------------
-- Validation: duplicate primary key check
-- ------------------------------------------------------------

SELECT SalesID, COUNT(*)
FROM Sales_Data
GROUP BY SalesID
HAVING COUNT(*) > 1;   -- expect no rows returned
