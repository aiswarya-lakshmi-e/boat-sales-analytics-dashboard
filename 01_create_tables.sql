-- ============================================================
-- boAt Sales Analytics Project
-- 01_create_tables.sql
-- Purpose: Create the database and all 5 base tables with
-- proper data types, primary keys, and foreign key relationships.
-- ============================================================

CREATE DATABASE boat_sales_project;
USE boat_sales_project;

-- ------------------------------------------------------------
-- Customer dimension
-- ------------------------------------------------------------
CREATE TABLE Customer_Details (
    CustomerID INT PRIMARY KEY,
    SignupDate VARCHAR(20),   -- loaded as text first (DD-MM-YYYY), converted to DATE later
    Gender VARCHAR(10),
    AgeBand VARCHAR(10),
    Segment VARCHAR(30),
    Tier VARCHAR(10),
    City VARCHAR(50),
    State VARCHAR(50),
    Region VARCHAR(20),
    PreferredChannel VARCHAR(50),
    ActivityWeight DECIMAL(10,4)
);

-- ------------------------------------------------------------
-- Product dimension
-- ------------------------------------------------------------
CREATE TABLE Product_Details (
    ProductID INT PRIMARY KEY,
    Brand VARCHAR(30),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    ProductName VARCHAR(100),
    HeroFlag INT,
    LaunchYear INT,
    MRP DECIMAL(10,2),
    CostPrice DECIMAL(10,2),
    PopularityWeight DECIMAL(15,10),
    DemandCluster VARCHAR(20)
);

-- ------------------------------------------------------------
-- Sales channel dimension
-- ------------------------------------------------------------
CREATE TABLE Sales_Channel (
    ChannelID INT PRIMARY KEY,
    ChannelName VARCHAR(50),
    ChannelType VARCHAR(30),
    ChannelScope VARCHAR(20),
    RegionScope VARCHAR(20),
    BaseShare DECIMAL(5,2)
);

-- ------------------------------------------------------------
-- Delivery partner dimension
-- ------------------------------------------------------------
CREATE TABLE Delivery_Partner_Data (
    DeliveryPartnerID INT PRIMARY KEY,
    PartnerName VARCHAR(50),
    HomeCity VARCHAR(50),
    Region VARCHAR(20),
    VehicleType VARCHAR(30),
    Rating DECIMAL(3,1),
    ExperienceYears INT
);

-- ------------------------------------------------------------
-- Sales fact table (975,000 rows) — the core transactional table
-- ------------------------------------------------------------
CREATE TABLE Sales_Data (
    SalesID INT PRIMARY KEY,
    OrderDate VARCHAR(20),   -- loaded as text first (DD-MM-YYYY), converted to DATE later
    OrderHour INT,
    CustomerID INT,
    ProductID INT,
    ChannelID INT,
    DeliveryPartnerID INT,
    Quantity INT,
    GrossMRPValue DECIMAL(12,2),
    DiscountPct DECIMAL(6,4),
    DiscountAmount DECIMAL(12,2),
    SellingPrice DECIMAL(12,2),
    NetSales DECIMAL(12,2),
    GSTRate INT,
    GSTAmount DECIMAL(12,2),
    COGS DECIMAL(12,2),
    ShippingCost DECIMAL(10,2),
    Profit DECIMAL(12,2),
    PaymentMethod VARCHAR(30),
    OrderStatus VARCHAR(20),
    CancellationReason VARCHAR(50),
    ReturnReason VARCHAR(50),
    DeliveryDays INT,
    CustomerTier VARCHAR(10),
    CustomerSegment VARCHAR(30),
    CityTier VARCHAR(10),
    ChannelType VARCHAR(20),
    IsFestivalPeriod INT,
    FestivalName VARCHAR(50),
    IsWeekend INT,
    ProductCategory VARCHAR(50),
    HeroFlag INT,
    FOREIGN KEY (ProductID) REFERENCES Product_Details(ProductID),
    FOREIGN KEY (ChannelID) REFERENCES Sales_Channel(ChannelID),
    FOREIGN KEY (DeliveryPartnerID) REFERENCES Delivery_Partner_Data(DeliveryPartnerID)
);

-- Added separately since Customer_Details is loaded after Sales_Data's initial
-- creation in some workflows; kept here for a single source of truth on schema.
ALTER TABLE Sales_Data
    ADD FOREIGN KEY (CustomerID) REFERENCES Customer_Details(CustomerID);
