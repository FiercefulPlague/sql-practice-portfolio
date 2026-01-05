USE adv;

-- MySQL Intermediate Practice – Marketingo analizė
-- Duomenų bazė: AdventureWorks2019
 
/*Task 1 – Pigiausias produktas subkategorijoje (pricing / offer)
Parašyk SQL užklausą, kuri grąžintų produkto pavadinimą, katalogo kainą (ListPrice) ir ListPrice su alias „LeastExpensive“ tam produktui, 
kurio pardavimo kaina yra mažiausia pasirinktoje produkto subkategorijoje (ProductSubcategoryID = 37).
Naudojama lentelė: Production_Product
Reikalavimai:
filtruoti pagal ProductSubcategoryID = 37
Teisingai nustatyti  pigiausią produktą (naudok MIN)*/

SELECT 
    Name, ListPrice AS 'LeastExpensive'
FROM
    production_product
WHERE
    ProductSubcategoryID = 37
        AND ListPrice = (SELECT 
            MIN(ListPrice)
        FROM
            production_product
        WHERE
            ProductSubcategoryID = 37);
            
/*Task 2 – Produktų kainų segmentavimas
Parašyk SQL užklausą, kuri klasifikuotų produktus toje pačioje subkategorijoje
(ProductSubcategoryID = 37) į kainų segmentus.
Naudojama lentelė: Production_Product
Reikalavimai:
Išvesti: produkto pavadinimą, ListPrice ir kainų segmentą
CASE:
< 20 → Budget
20–30 → Mid
> 30 → Premium*/

SELECT 
    Name,
    ListPrice,
    CASE
        WHEN ListPrice < 20 THEN 'Budget'
        WHEN ListPrice BETWEEN 20 AND 30 THEN 'Mid'
        ELSE 'Premium'
    END AS 'Segment'
FROM
    production_product
WHERE
    ProductSubcategoryID = 37;

/*Task 3 – Pardavimų kanalų palyginimas (verslo žvalgyba)
Parašyk SQL užklausą, kuri parodytų, kiek užsakymų buvo atlikta kiekvienu pardavimo kanalu.
Naudojama lentelė: Sales_SalesOrderHeader
Reikalavimai:
naudoti OnlineOrderFlag kanalų nustatymui (Online / Direct)
išvesti pardavimo kanalą ir užsakymų skaičių (COUNT ir GROUP BY)*/

SELECT 
    CASE
        WHEN OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS SalesChannel,
    COUNT(SalesOrderID) AS SalesNumber
FROM
    sales_salesorderheader
GROUP BY SalesChannel;

/*Task 4 – Sales channels pagal teritorijas (verslo žvalgyba)
Kiek užsakymų buvo kiekvienoje teritorijoje per kiekvieną pardavimo kanalą.
Naudojamos lentelės: Sales_SalesOrderHeader, Sales_SalesTerritory
Reikalavimai:
išvesti: teritorijos pavadinimą, pardavimo kanalą, užsakymų skaičių
naudoti JOIN, CASE, COUNT, GROUP BY*/

SELECT 
    st.Name AS 'Territory',
    CASE
        WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS SalesChannel,
    COUNT(soh.SalesOrderID) AS 'Sales'
FROM
    sales_salesorderheader soh
JOIN
    sales_salesterritory st 
ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name , SalesChannel; 

/*Task 5 – apžvalginė marketingo ataskaita (mini BI report)
Parašyk SQL užklausą, kuri sukurtų apžvalginę marketingo ataskaitą pagal teritorijas.
Naudojamos lentelės: Sales_SalesOrderHeader, Sales_SalesTerritory
Reikalavimai:
išvesti: teritorijos pavadinimą, OrdersOnline (online užsakymų skaičių), OrdersDirect (direct
užsakymų skaičių), TotalOrders, ChannelWinner – kuris kanalas dominuoja teritorijoje (Online,
Direct, Equal)
 Naudoti SUM(CASE WHEN ...), GROUP BY, CASE*/
 
SELECT 
    st.Name AS 'Territory',
    SUM(CASE
        WHEN soh.OnlineOrderFlag = 1 THEN 1
        ELSE 0
    END) AS OnlineSales,
    SUM(CASE
        WHEN soh.OnlineOrderFlag = 0 THEN 1
        ELSE 0
    END) AS DirectSales,
    COUNT(soh.SalesOrderID) AS 'TotalSales',
    CASE
        WHEN
            SUM(CASE
                WHEN soh.OnlineOrderFlag = 1 THEN 1
                ELSE 0
            END) > SUM(CASE
                WHEN soh.OnlineOrderFlag = 0 THEN 1
                ELSE 0
            END)
        THEN
            'Online'
        WHEN
            SUM(CASE
                WHEN soh.OnlineOrderFlag = 1 THEN soh.TotalDue
                ELSE 0
            END) < SUM(CASE
                WHEN soh.OnlineOrderFlag = 0 THEN soh.TotalDue
                ELSE 0
            END)
        THEN
            'Direct'
        ELSE 'Equal'
    END AS 'ChannelWinner'
FROM
    sales_salesorderheader soh
        JOIN
    sales_salesterritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name; 
 
/*Task 6 – Periodų analizė pagal kanalus (metai–mėnuo)
Parašyk SQL užklausą, kuri parodytų metinius ir mėnesinius pardavimus pagal kanalus,
naudojant TotalDue.
Naudojama lentelė: Sales_SalesOrderHeader
Reikalavimai:
Išvesk stulpelius: OrderYear (metai), OrderMonth (mėnuo), SalesChannel (Online /
Direct pagal OnlineOrderFlag), Orders (užsakymų skaičius), Revenue
(SUM(TotalDue))
Naudoti funkcijas: YEAR(), MONTH(), CASE, COUNT(), SUM()
Grupavimas: pagal metus, mėnesį ir kanalą
Rikiavimas: pagal metus, mėnesį, kanalą*/

SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    CASE
        WHEN OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS SalesChannel,
    COUNT(SalesOrderID) AS Orders,
    SUM(TotalDue) AS Sales
FROM
    sales_salesorderheader
GROUP BY Year , Month , SalesChannel
ORDER BY Year , Month , SalesChannel;

/*Task 6.1 – Reitingavimas: teritorijų rangai pagal sales channel
Parašyk SQL užklausą, kuri kiekvienam metų–mėnesio periodui išreitinguotų teritorijas pagal
pajamas (SUM(TotalDue)), bet atskirai Online ir Direct kanalams.
Naudojamos lentelės: Sales_SalesOrderHeader, Sales_SalesTerritory
Reikalavimai:
Išvesti: OrderYear, OrderMonth, SalesChannel (Online / Direct), TerritoryName,
Revenue (SUM(TotalDue)), RevenueRank (rangas teritorijoms pagal pajamas)
 Naudoti window function: RANK() arba DENSE_RANK()
Rangą skaičiuok taip, kad:
kiekvienam metų–mėnesio periodui būtų atskiras reitingas
kiekvienam kanalui būtų atskiras reitingas
Rikiavimas rezultate: pagal metus, mėnesį, kanalą, rangą (nuo 1)*/ 

WITH revenue_base AS (
    SELECT
        YEAR(soh.OrderDate) AS OrderYear,
        MONTH(soh.OrderDate) AS OrderMonth,
        CASE
            WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS SalesChannel,
        st.Name AS TerritoryName,
        SUM(soh.TotalDue) AS Revenue
    FROM sales_salesorderheader soh
    JOIN sales_salesterritory st
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY
        YEAR(soh.OrderDate),
        MONTH(soh.OrderDate),
        SalesChannel,
        st.Name
)

SELECT
    OrderYear,
    OrderMonth,
    SalesChannel,
    TerritoryName,
    Revenue,
    RANK() OVER (
        PARTITION BY OrderYear, OrderMonth, SalesChannel
        ORDER BY Revenue DESC
    ) AS RevenueRank
FROM revenue_base
ORDER BY
    OrderYear,
    OrderMonth,
    SalesChannel,
    RevenueRank;          
