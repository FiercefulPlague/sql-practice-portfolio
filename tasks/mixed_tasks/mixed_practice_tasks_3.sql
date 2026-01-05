/* ============================================================

UŽDUOTIS 3 Produktų kategorijų pelningumo analizė per laiką, teritorijose ir pardavimo 

kanaluose 

Naudok Production_Product, Production_ProductSubcategory, Production_ProductCategory, 

Sales_SalesOrderDetail, Sales_SalesTerritory ir Sales_SalesOrderHeader lenteles.
 
- Šiose lentelėse NETURIME savikainos (COGS), todėl „pelningumas“

  šiame uždavinyje reiškia PAJAMAS (Revenue).

- Pajamos imamos iš Sales_SalesOrderDetail.LineTotal (eilutės suma).

============================================================ */
 
 
/* ============================================================

1) Susiek produktus su subkategorijomis, kategorijomis, teritorijomis

   ir pardavimo kanalais.
 
Idėja: pirmiausia pasidarom „švarią bazę“ su teisingu grūdėtumu:

Category x Territory x Channel x Year x Quarter.

============================================================ */
 
SELECT 
    pc.ProductCategoryID,
    pc.Name AS CategoryName,
    st.TerritoryID,
    st.Name AS TeritoryName,
    CASE
        WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS SalesChannel,
    YEAR(soh.OrderDate) AS OrderYear,
    QUARTER(soh.OrderDate) AS OrderQuarter,
    ROUND(SUM(sod.LineTotal),2) AS CategoryRevenue
FROM sales_salesorderdetail sod
JOIN production_product pp ON sod.ProductID = pp.ProductID
LEFT JOIN production_productsubcategory psc ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN production_productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN sales_salesorderheader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN sales_salesterritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY pc.ProductCategoryID,
    pc.Name,
    st.TerritoryID,
    st.Name,
	SalesChannel,
    YEAR(soh.OrderDate),
    QUARTER(soh.OrderDate);
    
SELECT 
    pc.ProductCategoryID,
    pc.Name AS CategoryName,
    st.TerritoryID,
    st.Name AS TeritoryName,
    CASE
        WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS SalesChannel,
    YEAR(soh.OrderDate) AS OrderYear,
    QUARTER(soh.OrderDate) AS OrderQuarter,
    SUM(sod.LineTotal) AS CategoryRevenue
FROM
    production_product pp
        LEFT JOIN
    production_productsubcategory ps ON pp.ProductSubcategoryID = ps.ProductSubcategoryID
       LEFT JOIN
    production_productcategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
        JOIN
    sales_salesorderdetail sod ON pp.ProductID = sod.ProductID
        JOIN
    sales_salesorderheader soh ON sod.SalesOrderID = soh.SalesOrderID
        JOIN
    sales_salesterritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY pc.ProductCategoryID , pc.Name , st.TerritoryID , st.Name , SalesChannel , YEAR(soh.OrderDate) , QUARTER(soh.OrderDate);
    
-- Apskaičiuok bendras pajamas bei runningtotal kiekvienai kategorijai pagal metus ir ketvirčius  

WITH base AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        st.TerritoryID,
        st.Name AS TerritoryName,
        CASE 
            WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS SalesChannel,
        YEAR(soh.OrderDate) AS OrderYear,
        QUARTER(soh.OrderDate) AS OrderQuarter,
        SUM(sod.LineTotal) AS CategoryRevenue
    FROM sales_salesorderdetail sod
    JOIN production_product pp 
        ON sod.ProductID = pp.ProductID
    JOIN production_productsubcategory psc 
        ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN production_productcategory pc 
        ON psc.ProductCategoryID = pc.ProductCategoryID
    JOIN sales_salesorderheader soh 
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN sales_salesterritory st 
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY
        pc.ProductCategoryID,
        pc.Name,
        st.TerritoryID,
        st.Name,
        SalesChannel,
        OrderYear,
        OrderQuarter
)

SELECT
    ProductCategoryID,
    CategoryName,
    TerritoryID,
    TerritoryName,
    SalesChannel,
    OrderYear,
    OrderQuarter,
    ROUND(CategoryRevenue, 2) AS CategoryRevenue,
    ROUND(
        SUM(CategoryRevenue) OVER (
            PARTITION BY ProductCategoryID, TerritoryID, SalesChannel
            ORDER BY OrderYear, OrderQuarter
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS RunningTotalRevenue

FROM base
ORDER BY
    ProductCategoryID,
    TerritoryID,
    SalesChannel,
    OrderYear,
    OrderQuarter;

-- 3. Naudok CASE, kad kategorijas suskirstytum į „High Profit“ ir „Low Profit“.

WITH base AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        st.TerritoryID,
        st.Name AS TerritoryName,
        CASE 
            WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS SalesChannel,
        YEAR(soh.OrderDate) AS OrderYear,
        QUARTER(soh.OrderDate) AS OrderQuarter,
        SUM(sod.LineTotal) AS CategoryRevenue
    FROM sales_salesorderdetail sod
    JOIN production_product pp 
        ON sod.ProductID = pp.ProductID
    JOIN production_productsubcategory psc 
        ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN production_productcategory pc 
        ON psc.ProductCategoryID = pc.ProductCategoryID
    JOIN sales_salesorderheader soh 
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN sales_salesterritory st 
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY
        pc.ProductCategoryID,
        pc.Name,
        st.TerritoryID,
        st.Name,
        SalesChannel,
        OrderYear,
        OrderQuarter
)
SELECT
    ProductCategoryID,
    CategoryName,
    TerritoryID,
    TerritoryName,
    SalesChannel,
    OrderYear,
    OrderQuarter,
    ROUND(CategoryRevenue, 2) AS CategoryRevenue,
    CASE WHEN ROUND(CategoryRevenue, 2) BETWEEN 0 AND 20000 THEN 'Low Profit' ELSE 'High Profit' END AS CategoryProfit
FROM base
ORDER BY
    ProductCategoryID,
    TerritoryID,
    SalesChannel,
    OrderYear,
    OrderQuarter;

-- 4. Naudok procentinį skaičiavimą, kad parodytum, kiek kiekviena kategorija sudaro bendrų pajamų.

WITH base AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        st.TerritoryID,
        st.Name AS TerritoryName,
        CASE 
            WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS SalesChannel,
        YEAR(soh.OrderDate) AS OrderYear,
        QUARTER(soh.OrderDate) AS OrderQuarter,
        SUM(sod.LineTotal) AS CategoryRevenue
    FROM sales_salesorderdetail sod
    JOIN production_product pp 
        ON sod.ProductID = pp.ProductID
    JOIN production_productsubcategory psc 
        ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN production_productcategory pc 
        ON psc.ProductCategoryID = pc.ProductCategoryID
    JOIN sales_salesorderheader soh 
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN sales_salesterritory st 
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY
        pc.ProductCategoryID,
        pc.Name,
        st.TerritoryID,
        st.Name,
        SalesChannel,
        OrderYear,
        OrderQuarter
)
SELECT
    ProductCategoryID,
    CategoryName,
    TerritoryID,
    TerritoryName,
    SalesChannel,
    OrderYear,
    OrderQuarter,
    ROUND(CategoryRevenue, 2) AS CategoryRevenue,
    ROUND(
        SUM(CategoryRevenue) OVER (
            PARTITION BY TerritoryID, SalesChannel, OrderYear, OrderQuarter
        ), 2
    ) AS TotalRevenue,
    ROUND(CategoryRevenue / SUM(CategoryRevenue) OVER (
            PARTITION BY TerritoryID, SalesChannel, OrderYear, OrderQuarter
        ) * 100,2) AS RevenuePercent
FROM base
ORDER BY
    ProductCategoryID,
    TerritoryID,
    SalesChannel,
    OrderYear,
    OrderQuarter;

-- 5. Panaudok RANK ir DENSE_RANK funkciją, kad išreitinguotum kategorijas pagal pelningumą teritorijose ir kanaluose. Įtrauk tendencijų analizę, ar kategorijos pajamos auga, mažėja ar lieka stabilios laikui bėgant.

WITH base AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        st.TerritoryID,
        st.Name AS TerritoryName,
        CASE 
            WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS SalesChannel,
        YEAR(soh.OrderDate) AS OrderYear,
        QUARTER(soh.OrderDate) AS OrderQuarter,
        SUM(sod.LineTotal) AS CategoryRevenue
    FROM sales_salesorderdetail sod
    JOIN production_product pp 
        ON sod.ProductID = pp.ProductID
    JOIN production_productsubcategory psc 
        ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN production_productcategory pc 
        ON psc.ProductCategoryID = pc.ProductCategoryID
    JOIN sales_salesorderheader soh 
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN sales_salesterritory st 
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY
        pc.ProductCategoryID,
        pc.Name,
        st.TerritoryID,
        st.Name,
        SalesChannel,
        OrderYear,
        OrderQuarter
),
enriched AS (
    SELECT
        ProductCategoryID,
        CategoryName,
        TerritoryID,
        TerritoryName,
        SalesChannel,
        OrderYear,
        OrderQuarter,
        CategoryRevenue,

        SUM(CategoryRevenue) OVER (
            PARTITION BY TerritoryID, SalesChannel, OrderYear, OrderQuarter
        ) AS TotalRevenue,

        CategoryRevenue /
        SUM(CategoryRevenue) OVER (
            PARTITION BY TerritoryID, SalesChannel, OrderYear, OrderQuarter
        ) * 100 AS RevenuePercent,

        RANK() OVER (
            PARTITION BY TerritoryID, SalesChannel
            ORDER BY CategoryRevenue DESC
        ) AS RevenueRank,

        DENSE_RANK() OVER (
            PARTITION BY TerritoryID, SalesChannel
            ORDER BY CategoryRevenue DESC
        ) AS RevenueDenseRank,

        LAG(CategoryRevenue) OVER (
            PARTITION BY ProductCategoryID, TerritoryID, SalesChannel
            ORDER BY OrderYear, OrderQuarter
        ) AS PrevRevenue

    FROM base
)
SELECT
    ProductCategoryID,
    CategoryName,
    TerritoryID,
    TerritoryName,
    SalesChannel,
    OrderYear,
    OrderQuarter,
    CategoryRevenue,
    TotalRevenue,
    RevenuePercent,
	RevenueRank,
    RevenueDenseRank,
    PrevRevenue,
    CASE WHEN CategoryRevenue <  PrevRevenue THEN 'Mazeja' 
    WHEN CategoryRevenue =  PrevRevenue THEN 'Stabilios' 
    ELSE 'Dideja' 
    END AS Tendencija
FROM enriched
ORDER BY
    ProductCategoryID,
    TerritoryID,
    SalesChannel,
    OrderYear,
    OrderQuarter;














    
    