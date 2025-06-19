CREATE TABLE Customers(CustomerID          TEXT PRIMARY KEY,
                       IsPremium           BOOL,
					   TotalRevenue        NUMERIC (12,2),
					   Churned             BOOL,
					   EngagementScore     NUMERIC (5,2),
					   LastActiveDate      DATE,
					   MonthlyTransactions INT,
					   BalancedTrendScore  NUMERIC (5,2),
					   Region              TEXT,
					   AccountType         TEXT
					   );
-- See Structure					   
SELECT*
FROM Customers LIMIT 10,

-- Count Premium vs Regular Customers
SELECT IsPremium,
COUNT(*)
FROM Customers
GROUP BY IsPremium;

-- Churn Rate By Premium Status
SELECT IsPremium,
COUNT(*) AS Total,
SUM(CASE WHEN Churned THEN 1 ELSE 0 END) AS Churned,
ROUND ((SUM(CASE WHEN Churned THEN 1 ELSE 0 END):: DECIMAL/COUNT(*))*100,2) AS ChurnRate
FROM Customers
GROUP BY IsPremium;

-- Create Temporary Table with Tiers
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
FROM Customers


-- To See The Temporary Table
SELECT *
FROM Customer_tiers LIMIT 10;

-- Identify Risk Profiles Using Multifactor Condition
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

-- Using GROUP BY To Summarise Patterns 


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

-- Rank Top 15 Customers
WITH ranked_customers AS (
    SELECT *,
           RANK() OVER (ORDER BY TotalRevenue DESC) AS Revenue_Rank
    FROM Customer_tiers
)
SELECT * 
FROM ranked_customers
WHERE Revenue_Rank <= (
    SELECT ROUND(0.15 * COUNT(*)) FROM Customer_tiers
);

					  
  
					   
				

					   
					


