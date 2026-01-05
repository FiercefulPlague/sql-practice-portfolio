USE adv;

/*ADV_Practice_Intermediate
Užduotys praktikai*/
/*1. LEFT JOIN kartojimas
Išvesti produkto pavadinimą ir užsakymo numerį (SalesOrderID) visiems produktams.
Naudojamos lentelės:
Production_Product AS p
LEFT JOIN Sales_SalesOrderDetail AS sod*/

SELECT 
    p.Name, sod.SalesOrderID
FROM
    production_product p
        LEFT JOIN
    sales_salesorderdetail sod ON p.ProductID = sod.ProductID;

/*2. RIGHT JOIN kartojimas
Išvesti teritorijos pavadinimą ir BusinessEntityID. Rezultate turi būti visi pardavėjai, nesvarbu, ar
jie dirba toje teritorijoje.
Naudojamos lentelės:
Sales_SalesTerritory
Sales_SalesPerson*/

SELECT 
    sst.Name, ssp.BusinessEntityID
FROM
    sales_salesterritory sst
        RIGHT JOIN
    sales_salesperson ssp ON sst.TerritoryID = ssp.TerritoryID;

/*3. JOIN kartojimas
Išvesti kontaktus, kurie nėra iš US ir gyvena miestuose, kurių pavadinimas prasideda „Pa“.
Išvesti stulpelius: AddressLine1, AddressLine2, City, PostalCode, CountryRegionCode.
Naudojamos lentelės:
Person_Address AS a
Person_StateProvince AS s*/

SELECT 
    a.AddressLine1,
    a.AddressLine2,
    a.City,
    a.PostalCode,
    s.CountryRegionCode
FROM
    person_address a
        JOIN
    person_stateprovince s ON a.StateProvinceID = s.StateProvinceID
WHERE
    s.CountryRegionCode NOT LIKE 'US'
        AND a.City LIKE 'Pa%';

/*4. JOIN kartojimas su subquery arba CTE
Išvesti darbuotojų vardą ir pavardę (kartu) ir jų gyvenamą miestą.
Naudojamos lentelės:
Person_Person
HumanResources_Employee
Person_Address
Person_BusinessEntityAddress*/

WITH address AS (SELECT 
    pp.FirstName, pp.LastName, pb.BusinessEntityID, a.City
FROM
    person_person pp
        JOIN
    humanresources_employee he ON pp.BusinessEntityID = he.BusinessEntityID
        JOIN
    person_businessentityaddress pb ON he.BusinessEntityID = pb.BusinessEntityID
        JOIN
    person_address a ON pb.AddressID = a.AddressID)
SELECT 
    CONCAT(FirstName, ' ', LastName) AS employee, City
FROM
    address;

/*5. UNION ALL kartojimas
Parašyti SQL užklausą, kuri pateiktų visų raudonos arba mėlynos spalvos produktų sąrašą.
Išvesti: pavadinimą, spalvą ir katalogo kainą (ListPrice).
Rūšiuoti pagal ListPrice.
Naudojama lentelė:
Production_Product*/

SELECT Name, Color, ListPrice
FROM Production_Product
WHERE Color = 'Red'

UNION ALL

SELECT Name, Color, ListPrice
FROM Production_Product
WHERE Color = 'Blue'
ORDER BY ListPrice;


/*6. CTE kartojimas
Rasti, kiek užsakymų per metus įvykdo kiekvienas pardavėjas.
Naudojamos lentelės:
Sales_SalesOrderHeader
Sales_SalesPerson*/

WITH orders_per_year AS (
    SELECT
        SalesPersonID,
        YEAR(OrderDate) AS OrderYear,
        COUNT(*) AS OrdersCount
    FROM Sales_SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID, YEAR(OrderDate)
)
SELECT *
FROM orders_per_year
ORDER BY SalesPersonID, OrderYear;


/*7. Aritmetiniai skaičiavimai
Apskaičiuoti bendros metų pardavimų sumos (SalesYTD) padalijimą iš komisinių procentinės
dalies (CommissionPCT).
Išvesti SalesYTD, CommissionPCT ir apskaičiuotą reikšmę, suapvalintą iki artimiausio sveikojo
skaičiaus.
Naudojama lentelė:
Sales_SalesPerson*/

SELECT
    SalesYTD,
    CommissionPCT,
    ROUND(SalesYTD / NULLIF(CommissionPCT, 0)) AS SalesYTD_div_Commission
FROM Sales_SalesPerson;


/*8. STRING duomenų tipo manipuliavimas
Išvesti produktų pavadinimus, kurių kainos yra tarp 1000 ir 1220.
Pavadinimus išvesti trimis būdais: naudojant LOWER(), UPPER() ir LOWER(UPPER()).
Naudojama lentelė:
Production_Product*/

SELECT
    Name,
    LOWER(Name) AS name_lower,
    UPPER(Name) AS name_upper,
    LOWER(UPPER(Name)) AS name_lower_upper
FROM Production_Product
WHERE ListPrice BETWEEN 1000 AND 1220;


/*9. Wildcards kartojimas
Iš Production_Product išrinkti ProductID ir pavadinimą produktų, kurių pavadinimas prasideda
„Lock %“.*/

SELECT ProductID, Name
FROM Production_Product
WHERE Name LIKE 'Lock %';


/*10. CASE ir loginės sąlygos
Iš lentelės HumanResources_Employee parašyti SQL užklausą, kuri grąžintų darbuotojų ID ir
reikšmę, ar darbuotojas gauna pastovų atlyginimą (SalariedFlag) kaip TRUE arba FALSE.
Rezultatus surikiuoti taip:
– pirmiausia darbuotojai su pastoviu atlyginimu, mažėjančia ID tvarka;
– po jų kiti darbuotojai, didėjančia ID tvarka.
Naudoti CASE tiek stulpelio konvertavimui, tiek rikiavimui.*/

SELECT
    BusinessEntityID,
    CASE
        WHEN SalariedFlag = 1 THEN 'TRUE'
        ELSE 'FALSE'
    END AS IsSalaried
FROM HumanResources_Employee
ORDER BY
    CASE WHEN SalariedFlag = 1 THEN 0 ELSE 1 END,
    CASE WHEN SalariedFlag = 1 THEN BusinessEntityID END DESC,
    CASE WHEN SalariedFlag = 0 THEN BusinessEntityID END ASC;


/*11. Window Functions kartojimas
Naudojamos lentelės: Sales_SalesPerson, Person_Person, Person_Address.
Parašyti SQL užklausą, kuri atrinktų asmenis, gyvenančius teritorijoje ir kurių SalesYTD ≠ 0.
Grąžinti: vardą, pavardę, eilučių numeraciją (Row Number), reitingą (Rank), glaustą reitingą
(Dense Rank), kvartilį (Quartile), SalesYTD ir PostalCode.
Rikiuoti pagal PostalCode.
Naudoti ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE().*/

SELECT
    pp.FirstName,
    pp.LastName,
    ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS RowNum,
    RANK() OVER (ORDER BY sp.SalesYTD DESC) AS SalesRank,
    DENSE_RANK() OVER (ORDER BY sp.SalesYTD DESC) AS SalesDenseRank,
    NTILE(4) OVER (ORDER BY sp.SalesYTD DESC) AS Quartile,
    sp.SalesYTD,
    a.PostalCode
FROM Sales_SalesPerson sp
JOIN Person_Person pp
    ON sp.BusinessEntityID = pp.BusinessEntityID
JOIN Person_BusinessEntityAddress bea
    ON sp.BusinessEntityID = bea.BusinessEntityID
JOIN Person_Address a
    ON bea.AddressID = a.AddressID
WHERE sp.TerritoryID IS NOT NULL
  AND sp.SalesYTD <> 0
ORDER BY a.PostalCode;


/*12. Agregacijų kartojimas su Window Functions
Iš lentelės Sales_SalesOrderDetail apskaičiuoti suminį kiekį, vidurkį, užsakymų skaičių,
mažiausią ir didžiausią OrderQty kiekvienam SalesOrderID.
Atrinkti tik SalesOrderID: 43659 ir 43664.
Grąžinti: SalesOrderID, ProductID, OrderQty, suminį kiekį, vidurkį, užsakymų skaičių, minimalų
ir maksimalų kiekį.
Naudoti SUM(), AVG(), COUNT(), MIN(), MAX() su OVER (PARTITION BY SalesOrderID).*/

SELECT
    SalesOrderID,
    ProductID,
    OrderQty,
    SUM(OrderQty)  OVER (PARTITION BY SalesOrderID) AS SumQty,
    AVG(OrderQty)  OVER (PARTITION BY SalesOrderID) AS AvgQty,
    COUNT(*)       OVER (PARTITION BY SalesOrderID) AS CntLines,
    MIN(OrderQty)  OVER (PARTITION BY SalesOrderID) AS MinQty,
    MAX(OrderQty)  OVER (PARTITION BY SalesOrderID) AS MaxQty
FROM Sales_SalesOrderDetail
WHERE SalesOrderID IN (43659, 43664)
ORDER BY SalesOrderID, ProductID;



