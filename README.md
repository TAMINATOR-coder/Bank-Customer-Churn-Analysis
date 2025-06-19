# Bank-Customer-Churn-Analysis
This project explores customer segmentation, profitability tiers, and risk profiling in a banking dataset using PostgreSQL. It walks through data creation, enrichment, pattern analysis, and ranking of high-value customers - forming a foundation for strategic decisions across marketing, retention, and financial risk.

---

## Table of Contents
1. [Database Setup](#database-setup)
2. [Data Preview](#data-preview)
3. [Customer Segmentation](#customer-segmentation)
4. [Churn Analysis](#churn-analysis)
5. [Profitability Tiering](#profitability-tiering)
6. [Risk Profiling](#risk-profiling)
7. [Segment-Level Insights](#segment-level-insights)
8. [Top Revenue Contributors](#top-revenue-contributors)

---

## Database Setup

We begin by defining the core `Customers` table, capturing demographics, engagement metrics, revenue contribution, and activity levels.

```sql
CREATE TABLE Customers (
    CustomerID          TEXT PRIMARY KEY,
    IsPremium           BOOL,
    TotalRevenue        NUMERIC(12,2),
    Churned             BOOL,
    EngagementScore     NUMERIC(5,2),
    LastActiveDate      DATE,
    MonthlyTransactions INT,
    BalancedTrendScore  NUMERIC(5,2),
    Region              TEXT,
    AccountType         TEXT
);
```

## Premium vs Regular Count
Getting a count of the Premium(high revenue generating) and Regular(Medium to low revenue generating) Customers

```
SELECT 
    IsPremium,
    COUNT(*) AS CustomerCount
FROM Customers
GROUP BY IsPremium;
```


## Churn Rate By Customer Class
This query calculates churn rate per segment
```
SELECT 
    IsPremium,
    COUNT(*) AS Total,
    SUM(CASE WHEN Churned THEN 1 ELSE 0 END) AS Churned,
    ROUND((SUM(CASE WHEN Churned THEN 1 ELSE 0 END)::DECIMAL / COUNT(*)) * 100, 2) AS ChurnRate
FROM Customers
GROUP BY IsPremium;
```


## Profitability Tiering
Create Tiered customer Segments(High, Medium & Low) Based on Revenue generated from them
```
CREATE TEMP TABLE Customer_tiers AS 
SELECT 
    CustomerID,        
    IsPremium,
    TotalRevenue,        
    Churned,             
    EngagementScore,     
    LastActiveDate,      
    MonthlyTransactions, 
    BalancedTrendScore,  
    Region,            
    AccountType,
    CASE 
        WHEN TotalRevenue >= 10000 THEN 'High'
        WHEN TotalRevenue >= 5000  THEN 'Medium'
        ELSE 'Low'
    END AS Profitability_Tier
FROM Customers;
```

## Risk Profiling
Identifying customers At-Risk of churn using multiple factors (Multifactor Conditions)
```
SELECT 
    CustomerID,
    IsPremium,
    Churned,
    TotalRevenue,
    EngagementScore,
    BalancedTrendScore,
    MonthlyTransactions,
    CASE 
        WHEN Churned AND EngagementScore < 50 AND BalancedTrendScore < 0 THEN 'High Risk'
        WHEN Churned AND (
            (EngagementScore >= 50 AND BalancedTrendScore < 70) 
            OR BalancedTrendScore < 0
        ) THEN 'Moderate Risk'
        WHEN NOT Churned AND (
            EngagementScore < 70 
            OR BalancedTrendScore < 0 
            OR MonthlyTransactions < 3
        ) THEN 'Watch'
        ELSE 'Stable'
    END AS Risk_Flag
FROM Customer_tiers
WHERE IsPremium = TRUE;
```

## Profitability Analysis
This adds up different churn behaviors across customer tiers
```
SELECT 
    Profitability_tier,
    COUNT(*) AS TotalCustomers,
    ROUND(AVG(EngagementScore), 2) AS AvgEngagement,
    SUM(CASE WHEN Churned THEN 1 ELSE 0 END) AS TotalChurned,
    ROUND(AVG(MonthlyTransactions), 2) AS AvgTransactions
FROM Customer_tiers
GROUP BY Profitability_tier
ORDER BY 
    CASE Profitability_tier
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END;
```







