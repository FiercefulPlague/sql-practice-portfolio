-- Window Functions
-- 1. Calculate Running Total of Sales: Use the SUM() window function to calculate a running total of sales for each year.

SELECT
    YEAR(OrderDate) AS sales_year,
    OrderDate,
    SalesOrderID,
    TotalDue,
    SUM(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_per_year
FROM sales_salesorderheader
ORDER BY sales_year, OrderDate;

-- 2. Rank Sales by Year: Use the RANK() window function to rank sales by the total amount each year within each product category.

WITH yearly_sales AS (
    SELECT
        YEAR(so.OrderDate) AS sales_year,
        pc.Name AS category_name,
        SUM(so.TotalDue) AS total_sales
    FROM sales_salesorderheader so
    JOIN sales_salesorderdetail ss ON so.SalesOrderID = ss.SalesOrderID
    JOIN production_product pp ON ss.ProductID = pp.ProductID
    JOIN production_productsubcategory ps ON pp.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN production_productcategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY
        YEAR(so.OrderDate),
        pc.Name
)
SELECT
    sales_year,
    category_name,
    total_sales,
    RANK() OVER (
        PARTITION BY sales_year
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM yearly_sales
ORDER BY sales_year, sales_rank;


-- 3. Find the Top 3 Products by Sales in Each Category: Use the ROW_NUMBER() window function to identify the top 3 products by sales amount within each category.

WITH yearly_sales AS (
    SELECT
        YEAR(so.OrderDate) AS sales_year,
        pc.Name AS category_name,
        pp.Name AS product_name,
        SUM(so.TotalDue) AS total_sales
    FROM sales_salesorderheader so
    JOIN sales_salesorderdetail ss ON so.SalesOrderID = ss.SalesOrderID
    JOIN production_product pp ON ss.ProductID = pp.ProductID
    JOIN production_productsubcategory ps ON pp.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN production_productcategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY
        YEAR(so.OrderDate),
        pc.Name, pp.Name
)
SELECT
    sales_year,
    category_name,
    product_name,
    total_sales,
    sales_rank
FROM (
    SELECT
        sales_year,
        category_name,
        product_name,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY sales_year, category_name
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM yearly_sales
) ranked
WHERE sales_rank <= 3
ORDER BY sales_year, category_name, sales_rank;

-- 4. Calculate the Moving Average of Monthly Sales: Use the AVG() window function to calculate a 3-month moving average of sales.

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(so.OrderDate, '%Y-%m-01') AS sales_month,
        SUM(so.TotalDue) AS monthly_total
    FROM sales_salesorderheader so
    GROUP BY
        DATE_FORMAT(so.OrderDate, '%Y-%m-01')
)
SELECT
    sales_month,
    monthly_total,
    AVG(monthly_total) OVER (
        ORDER BY sales_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_months
FROM monthly_sales
ORDER BY sales_month;

-- 5. Compare Individual Sales to Average Sales: Use the AVG() window function to compare individual sales amounts to the average sales of the respective year.

SELECT
    YEAR(OrderDate) AS sales_year,
    SalesOrderID,
    TotalDue,
    AVG(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
    ) AS avg_sales_per_year,
    TotalDue - AVG(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
    ) AS sales_vs_avg
FROM sales_salesorderheader
ORDER BY sales_year, SalesOrderID;  

-- 6. Partition Sales by Territory and Rank: Use the DENSE_RANK() window function to rank sales orders by amount within each sales territory.

SELECT
    st.Name AS territory_name,
    so.SalesOrderID,
    so.TotalDue,
    DENSE_RANK() OVER (
        PARTITION BY st.Name
        ORDER BY so.TotalDue DESC
    ) AS sales_rank_in_territory
FROM sales_salesorderheader so
JOIN sales_salesterritory st ON so.TerritoryID = st.TerritoryID
ORDER BY territory_name, sales_rank_in_territory;

-- 7. Calculate Percentile Sales: Use the PERCENT_RANK() window function to calculate the percentile rank of sales orders by amount within each year.

SELECT
    YEAR(OrderDate) AS sales_year,
    SalesOrderID,
    TotalDue,
    PERCENT_RANK() OVER (
        PARTITION BY YEAR(OrderDate)
        ORDER BY TotalDue
    ) AS percentile_rank
FROM sales_salesorderheader
ORDER BY sales_year, percentile_rank;

-- 8. Identify First and Last Sale Date for Each Product: Use the FIRST_VALUE() and LAST_VALUE() window functions to find the first and last sale date for each product.

SELECT
    pp.Name AS product_name,
    so.OrderDate,
    FIRST_VALUE(so.OrderDate) OVER (
        PARTITION BY pp.ProductID
        ORDER BY so.OrderDate
    ) AS first_sale_date,
    LAST_VALUE(so.OrderDate) OVER (
        PARTITION BY pp.ProductID
        ORDER BY so.OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_sale_date
FROM sales_salesorderheader so
JOIN sales_salesorderdetail ss ON so.SalesOrderID = ss.SalesOrderID
JOIN production_product pp ON ss.ProductID = pp.ProductID
ORDER BY product_name, OrderDate;

-- 9. Calculate Cumulative Quantity Sold: Use the SUM() window function to calculate the cumulative quantity sold for each product over time.

SELECT
    pp.Name AS product_name,
    so.OrderDate,
    ss.OrderQty,
    SUM(ss.OrderQty) OVER (
        PARTITION BY pp.ProductID
        ORDER BY so.OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_quantity_sold
FROM sales_salesorderheader so
JOIN sales_salesorderdetail ss ON so.SalesOrderID = ss.SalesOrderID
JOIN production_product pp ON ss.ProductID = pp.ProductID
ORDER BY product_name, OrderDate;

-- 10. Compare Sales Growth by Quarter: Use the LAG() window function to compare sales amounts between consecutive quarters to calculate quarter-over-quarter growth.

WITH quarterly_sales AS (
    SELECT
        YEAR(OrderDate) AS sales_year,
        QUARTER(OrderDate) AS sales_quarter,
        SUM(TotalDue) AS total_sales
    FROM sales_salesorderheader
    GROUP BY YEAR(OrderDate), QUARTER(OrderDate)
)
SELECT
    CONCAT(sales_year, ' Q', sales_quarter) AS quarter,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY sales_year, sales_quarter
    ) AS previous_quarter_sales,
    total_sales - LAG(total_sales) OVER (
        ORDER BY sales_year, sales_quarter
    ) AS sales_growth
FROM quarterly_sales;


-- 11. Determine Employee Ranking by Sales: Use the RANK() window function to rank employees by the total sales they generated.

SELECT
    e.FirstName,
    e.LastName,
    SUM(so.TotalDue) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(so.TotalDue) DESC
    ) AS employee_sales_rank
FROM sales_salesorderheader so
JOIN humanresources_employee e ON so.SalesPersonID = e.EmployeeID
GROUP BY
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY employee_sales_rank;

-- 12. Segment Customers Based on Total Purchases: Use the NTILE() window function to divide customers into quartiles based on their total purchase amount.

SELECT
    p.FirstName,
    p.LastName,
    SUM(so.TotalDue) AS total_sales,
    RANK() OVER (ORDER BY SUM(so.TotalDue) DESC) AS employee_sales_rank
FROM sales_salesorderheader so
JOIN humanresources_employee e ON so.SalesPersonID = e.BusinessEntityID
JOIN person_person p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY p.BusinessEntityID, p.FirstName, p.LastName;

-- 13. Calculate YTD (Year-to-Date) Sales: Use the SUM() window function with a specific range to calculate year-to-date sales for each product.

SELECT
    YEAR(so.OrderDate) AS sales_year,
    pp.Name AS product_name,
    so.OrderDate,
  SUM(ss.LineTotal) OVER (
    PARTITION BY YEAR(so.OrderDate), pp.ProductID
    ORDER BY so.OrderDate
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS ytd_sales
FROM sales_salesorderheader so
JOIN sales_salesorderdetail ss ON so.SalesOrderID = ss.SalesOrderID
JOIN production_product pp ON ss.ProductID = pp.ProductID
ORDER BY sales_year, product_name, OrderDate;

-- 14. Analyze Variance in Monthly Sales: Use the STDDEV() window function to calculate the standard deviation of sales amounts for each month to analyze volatility.

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m') AS sales_month,
        SUM(TotalDue) AS total_sales
    FROM sales_salesorderheader
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
)
SELECT
    sales_month,
    total_sales,
    STDDEV(total_sales) OVER (
        ORDER BY sales_month
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ) AS rolling_stddev
FROM monthly_sales;





