USE adv;

-- 1.1 Patikra: ar yra indeksas ant ProductID
SHOW INDEX FROM sales_salesorderdetail;

-- 1.4 Užklausa: atrinkti visus parduotus kiekius produktui ProductID = 800

SELECT
    SalesOrderID,
    SalesOrderDetailID,
    ProductID,
    OrderQty
FROM sales_salesorderdetail
WHERE ProductID = 800;
 
-- 1.5 EXPLAIN: ar naudojamas indeksas ant ProductID

EXPLAIN
SELECT
    SalesOrderID,
    SalesOrderDetailID,
    ProductID,
    OrderQty
FROM sales_salesorderdetail
WHERE ProductID = 800;
 
 SHOW INDEX FROM sales_salesorderheader;
SHOW INDEX FROM sales_customer;

-- Optimizuota versija (naudojant tinkamą WHERE ir indeksą)
CREATE INDEX idx_orderdate ON sales_salesorderheader(orderdate);
alter table sales_salesorderheader
drop index idx_orderdate;

-- =========================================

-- 1. BASIC INDEX.

-- =========================================

-- Create an index on customerid to speed up filtering

show indexes from sales_salesorderheader;

CREATE INDEX idx_customerid ON sales_salesorderheader(customerid);
 
-- Query using the index

EXPLAIN 
SELECT salesorderid, orderdate, customerid
FROM sales_salesorderheader
WHERE customerid = 11000;
 
 -- =========================================
-- 2. UNIQUE INDEX
-- =========================================
-- Ensure uniqueness and speed on businessentityid
SHOW INDEX FROM humanresources_employee;
 
CREATE UNIQUE INDEX idx_unique_businessentityid ON humanresources_employee(businessentityid);
 
-- Query using the unique index
EXPLAIN SELECT * FROM humanresources_employee WHERE businessentityid = 100;

-- =========================================
-- 3. COMPOSITE INDEX
-- =========================================
-- Create index on multiple columns used together in WHERE
SHOW INDEX FROM sales_salesorderheader;
CREATE INDEX idx_composite_order ON sales_salesorderheader(customerid, orderdate);
 
-- Query that benefits from the composite index
EXPLAIN SELECT salesorderid, orderdate, customerid
FROM sales_salesorderheader
WHERE customerid = 11000 AND orderdate >= '2012-01-01';

SELECT DATABASE() AS BAZE;

-- Patikrinam indeksus person_person lentelėje:
SHOW INDEX FROM person_person;

SELECT
    p.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM person_person p
WHERE p.LastName LIKE 'S%';

-------------------------------------------------
				-- PRAKTIKA-- 
-------------------------------------------------

-- Temos: Query Optimization su AdventureWorks2019
-- Naudojamos lentelės: production_product, sales_salesorderdetail

-- =========================================
-- Užduotis 1:
-- Patikrink, ar lentelėje sales_salesorderdetail yra indeksas ant productid.
-- Jei ne – sukurk jį.
-- Tada parašyk užklausą, kuri atrenka visus parduotus kiekius produktui su productid = 800.
-- Patikrink EXPLAIN rezultatus.
-- =========================================

SHOW INDEX FROM sales_salesorderdetail;

SELECT
    SalesOrderID,
    SalesOrderDetailID,
    ProductID,
    OrderQty
FROM sales_salesorderdetail
WHERE ProductID = 800;

EXPLAIN SELECT
    SalesOrderID,
    SalesOrderDetailID,
    ProductID,
    OrderQty
FROM sales_salesorderdetail
WHERE ProductID = 800;

-- =========================================
-- Užduotis 2:
-- Sukurk composite index ant sales_salesorderdetail (productid, orderqty).
-- Tada parašyk užklausą, kuri atrenka visus produktus, kurių užsakymo kiekis didesnis nei 5 ir productid = 800.
-- =========================================

CREATE INDEX idx_product_quantity ON sales_salesorderdetail (productid, orderqty);
SHOW INDEX FROM sales_salesorderdetail;

SELECT 
    SalesOrderID, ProductID, OrderQty
FROM
    sales_salesorderdetail
WHERE
    OrderQty > 5 AND ProductID = 800;
    
EXPLAIN SELECT 
    SalesOrderID, ProductID, OrderQty
FROM
    sales_salesorderdetail
WHERE
    OrderQty > 5 AND ProductID = 800;

-- =========================================
-- Užduotis 3:
-- Parašyk JOIN užklausą, kuri grąžina produkto pavadinimą, kiekį ir orderid.
-- JOIN tarp production_product ir sales_salesorderdetail.
-- Filtruok tik orderqty > 10.
-- Patikrink EXPLAIN.
-- =========================================

SELECT 
    pp.Name, so.OrderQty, so.SalesOrderID
FROM
    sales_salesorderdetail so
        JOIN
    production_product pp ON so.ProductID = pp.ProductID
WHERE
    OrderQty > 10;

-- =========================================
-- Užduotis 4:
-- Parašyk blogą ir gerą WHERE pavyzdį:
-- a) Naudok funkciją: WHERE ROUND(orderqty, 0) = 10
-- b) Pataisyk, kad būtų galima naudoti indeksą
-- =========================================

SELECT
    SalesOrderID,
    ProductID,
    OrderQty
FROM sales_salesorderdetail
WHERE ROUND(OrderQty, 0) = 10; -- Bloga


SELECT
    SalesOrderID,
    ProductID,
    OrderQty
FROM sales_salesorderdetail
WHERE OrderQty = 10;

-- =========================================
-- Užduotis 5:
-- Palygink šias dvi užklausas:
-- a) IN subquery: grąžina visų produktų pavadinimus, kurie yra parduoti
-- b) EXISTS versija – tą patį per EXISTS
-- Patikrink EXPLAIN ir palygink našumą.
-- =========================================

SELECT Name
FROM production_product
WHERE ProductID IN (
    SELECT ProductID
    FROM sales_salesorderdetail
);

SELECT p.Name
FROM production_product p
WHERE EXISTS (
    SELECT 1
    FROM sales_salesorderdetail sod
    WHERE sod.ProductID = p.ProductID
);


























