-- CHATGPT LEARNING

SELECT 
	OrderDate, 
    SalesOrderID, 
    TotalDue, 
    AVG(TotalDue) OVER (PARTITION BY YEAR(OrderDate)) AS avg_year_sales, 
    TotalDue - AVG(TotalDue) OVER (PARTITION BY YEAR(OrderDate)) AS difference  
FROM sales_salesorderheader;

SELECT 
	OrderDate, 
    SalesOrderID, 
    TotalDue, 
    SUM(TotalDue) OVER (PARTITION BY YEAR(OrderDate) ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total 
FROM sales_salesorderheader;

SELECT 
    OrderDate, 
    SalesOrderID, 
    TotalDue, 
    LAG(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
        ORDER BY OrderDate
    ) AS prev_total,
    TotalDue - LAG(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
        ORDER BY OrderDate
    ) AS skirtumas
FROM sales_salesorderheader;

SELECT 
	OrderDate, 
	SalesOrderID, 
    TotalDue, 
    RANK() OVER 
    (PARTITION BY YEAR(OrderDate) 
    ORDER BY TotalDue DESC) 
    AS rankas 
FROM sales_salesorderheader;

WITH ranked_orders AS (
    SELECT
        OrderDate,
        SalesOrderID,
        TotalDue,
        RANK() OVER (
            PARTITION BY YEAR(OrderDate)
            ORDER BY TotalDue DESC
        ) AS rankas
    FROM sales_salesorderheader
)
SELECT
    OrderDate,
    SalesOrderID,
    TotalDue,
    rankas
FROM ranked_orders
WHERE rankas <= 3
ORDER BY YEAR(OrderDate), rankas;



