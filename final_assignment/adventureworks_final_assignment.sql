-- AdventureWorks2019 Test

USE adv;

/*1. Klientų lojalumo analizė.
Scenarijus: Įmonės rinkodaros komanda 2014 m. birželio 30 d.siekia įvertinti klientų
lojalumą. Jūsų užduotis skirta įvertinti klientų elgseną laike. Reikia nustatyti, kurie klientai
pirmą kartą užsakė 2013 metais ir kiek vidutiniškai išleido tais metais, ir ar jie užsakė dar
kartą ir kiekvieno užsakymo sumą 2014 metais.
Naudojamos lentelės: sales_salesorderheader, sales_customer, person_person.
Naudojamos window function: DENSE_RANK().
Laukiamas rezultatas:
+-------+---------+----------+------------------------+-------------+----------------+--------+---------+
| id | vardas | pavarde | uzsakymo_vidurkis_2013 | uzsakymoID | uzsakymo_data | suma | ranking |
+-------+---------+----------+------------------------+-------------+----------------+--------+---------+
| 11012 | Lauren | Walker | 82.85 | 68413 | 2014-03-16 | 6.94 | 1 |
| 11013 | Ian | Jenkins | 43.07 | 74908 | 2014-06-22 | 82.85 | 1 |
| 11014 | Sydney | Bennett | 76.49 | NULL | NULL | NULL | 1 |
+-------+---------+----------+------------------------+-------------+----------------+--------+---------+
9486 rows*/

WITH first_orders AS (
    SELECT
        soh.CustomerID,
        soh.SalesOrderID,
        soh.OrderDate,
        DENSE_RANK() OVER (
            PARTITION BY soh.CustomerID
            ORDER BY soh.OrderDate
        ) AS ranking
    FROM sales_salesorderheader soh
)
, avg_2013 AS (
    SELECT
        CustomerID,
        ROUND(AVG(TotalDue), 2) AS uzsakymo_vidurkis_2013
    FROM sales_salesorderheader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY CustomerID
)
SELECT
    c.CustomerID AS id,
    p.FirstName AS vardas,
    p.LastName AS pavarde,
    a.uzsakymo_vidurkis_2013,
    soh2014.SalesOrderID AS uzsakymoID,
    soh2014.OrderDate AS uzsakymo_data,
    soh2014.TotalDue AS suma,
    fo.ranking
FROM first_orders fo
JOIN sales_customer c 
    ON fo.CustomerID = c.CustomerID
JOIN person_person p 
    ON c.PersonID = p.BusinessEntityID
JOIN avg_2013 a 
    ON a.CustomerID = c.CustomerID
LEFT JOIN sales_salesorderheader soh2014
    ON soh2014.CustomerID = c.CustomerID
    AND YEAR(soh2014.OrderDate) = 2014
WHERE
    fo.ranking = 1
    AND YEAR(fo.OrderDate) = 2013
ORDER BY c.CustomerID;

/*2. Produktų pardavimų analizė pagal prekių kategorijas ir regionus
Užduotis: Parašykite užklausą, kuri apskaičiuoja bendrą produktų pardavimų sumą pagal prekių
kategorijas ir rodo rezultatus pagal regionus. Užklausoje turi būti šie stulpeliai:
• Prekės kategorija (iš ProductCategory)
• Regionas (iš SalesTerritory)
• Bendros pardavimų sumos
Užuomina: Susijunkite SalesOrderDetail su Product ir ProductCategory, tada susijunkite
SalesOrderHeader su SalesTerritory naudojant atitinkamus Foreign Keys. Filtruokite
rezultatus pagal 2013 metų pardavimus.
Tikėtinas rezultatas:
• Prekės kategorija
• Regionas
• Bendros pardavimų sumos
Tikėtini rezultatai:
# kategorija, regionas, suma
'Bikes', 'Australia', '3951062.89'
40 rows*/

SELECT 
    pc.Name AS kategorija, st.Name AS regionas, ROUND(SUM(sod.LineTotal), 2) AS suma
FROM
    sales_salesorderdetail sod
        JOIN
    production_product pp ON sod.ProductID = pp.ProductID
        JOIN
    production_productsubcategory psc ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
        JOIN
    production_productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
        JOIN
    sales_salesorderheader soh ON sod.SalesOrderID = soh.SalesOrderID
        JOIN
    sales_salesterritory st ON soh.TerritoryID = st.TerritoryID
WHERE
    YEAR(soh.OrderDate) = 2013
GROUP BY pc.Name , st.Name;

/*3. Pardavimų departamento darbuotojų našumas
Užduotis: Vadovybė nori įvertinti pardavimų darbuotojų efektyvumą pagal jų priskirtus
departamentus. Naudojant duomenis iš lentelių SalesOrderHeader, Person,
EmployeeDepartmentHistory ir Department, reikia apskaičiuoti bendrą kiekvieno darbuotojo
pardavimų sumą, nustatyti, kuriam departamentui jis priklauso, ir palyginti darbuotojo
rezultatus su to departamento vidurkiu. Skaičiavimui naudojama window function AVG(...)
OVER (PARTITION BY DepartmentID), kuri leidžia gauti departamento vidutinę pardavimų sumą.
Palyginimui reikia pridėti stulpelį, rodantį darbuotojo santykinį našumą procentais, ir tekstinį
įvertinimą (ar darbuotojo rezultatas viršija, atitinka ar nesiekia vidurkio), naudojant CASE.
Tikėtini rezultatai:
+-----+---------+----------+-------------+------------------------+-----------------------------+-------------------
-----+--------------------+
| id | vardas | pavarde | departamentas | darbuotojo_pardavimai | departamento_pard_vidurkis
| santykinis_nasumas_proc | vertinimas |
+-----+---------+----------+-------------+------------------------+-----------------------------+-------------------
-----+--------------------+
| 276 | Linda | Mitchell | Sales | 11695019.06 | 5339732.18 | 219.0 |
Viršija vidurkį |
| 277 | Jillian | Carson | Sales | 11342385.90 | 5339732.18 | 212.4 |
Viršija vidurkį |
| 275 | Michael | Blythe | Sales | 10475367.08 | 5339732.18 | 196.2 |
Viršija vidurkį |
+-----+---------+----------+-------------+------------------------+-----------------------------+-------------------
-----+--------------------+
17 rows*/

WITH employee_sales AS (
    SELECT
        soh.SalesPersonID AS EmployeeID,
        SUM(soh.TotalDue) AS darbuotojo_pardavimai
    FROM Sales_SalesOrderHeader soh
    WHERE soh.SalesPersonID IS NOT NULL
    GROUP BY soh.SalesPersonID
),

employee_department AS (
    SELECT
        edh.BusinessEntityID AS EmployeeID,
        edh.DepartmentID
    FROM HumanResources_EmployeeDepartmentHistory edh
    WHERE edh.EndDate IS NULL
),

employee_base AS (
    SELECT
        es.EmployeeID,
        p.FirstName,
        p.LastName,
        d.Name AS departamentas,
        ed.DepartmentID,
        es.darbuotojo_pardavimai,
        AVG(es.darbuotojo_pardavimai) OVER (
            PARTITION BY ed.DepartmentID
        ) AS departamento_pard_vidurkis
    FROM employee_sales es
    JOIN employee_department ed
        ON es.EmployeeID = ed.EmployeeID
    JOIN HumanResources_Department d
        ON ed.DepartmentID = d.DepartmentID
    JOIN Person_Person p
        ON es.EmployeeID = p.BusinessEntityID
)

SELECT
    EmployeeID AS id,
    FirstName AS vardas,
    LastName AS pavarde,
    departamentas,
    ROUND(darbuotojo_pardavimai, 2) AS darbuotojo_pardavimai,
    ROUND(departamento_pard_vidurkis, 2) AS departamento_pard_vidurkis,
    ROUND(
        (darbuotojo_pardavimai / departamento_pard_vidurkis) * 100,
        1
    ) AS santykinis_nasumas_proc,
    CASE
        WHEN darbuotojo_pardavimai > departamento_pard_vidurkis
            THEN 'Viršija vidurkį'
        WHEN darbuotojo_pardavimai = departamento_pard_vidurkis
            THEN 'Atitinka vidurkį'
        ELSE 'Nesiekia vidurkio'
    END AS vertinimas
FROM employee_base
ORDER BY darbuotojo_pardavimai DESC;

/*4. Pardavimų analize pagal laikotarpį ir produktų grupes
Užduotis: Parašykite užklausą, kuri apskaičiuoja bendrą pardavimų sumą per metus (2013)
pagal produktų grupes ir pateikia šiuos duomenis:
• Prekės grupė (iš ProductSubcategory)
• Bendros pardavimų sumos
• Pardavimų kiekis
• Vidutinė pardavimo kaina
Užuomina: Susijunkite SalesOrderDetail su Product ir ProductSubcategory. Filtruokite pagal
2013 metų pardavimus ir apskaičiuokite bendrą pardavimų sumą, kiekį ir vidutinę pardavimo
kainą (rikiuojant desc)..
Tikėtinas rezultatas:
# prekes_grupe, kiekis, pardavimu_suma, vidutine_pardavimo_kaina
'Mountain Bikes', '11741', '13046301.82', '1111.17'
35 rows*/

SELECT 
    psc.Name AS prekes_grupe,
    SUM(sod.OrderQty) AS kiekis,
    ROUND(SUM(sod.LineTotal), 2) AS pardavimu_suma,
    ROUND(SUM(sod.LineTotal) / SUM(sod.OrderQty),2) AS vidutine_pardavimo_kaina
FROM
    sales_salesorderdetail sod
        JOIN
    production_product pp ON sod.ProductID = pp.ProductID
        JOIN
    production_productsubcategory psc ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
        JOIN
    sales_salesorderheader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE
    YEAR(soh.OrderDate) = 2013
GROUP BY psc.Name;

/*5. Gamybos ir tiekimo grandinės efektyvumo analizė
Užduotis: Parašykite užklausą, kuri apskaičiuoja prekių tiekimo laiką pagal gamintoją.
Pateikite šiuos duomenis:
• Tiekimo grandinės tiekėjo pavadinimas (iš Supplier)
• Prekės pavadinimas (iš Product)
• Laikas nuo užsakymo iki pristatymo (laiko skirtumas tarp OrderDate ir ShipDate)
Užuomina: Susijunkite Product su ProductSupplier, o ProductSupplier su Supplier.
Apskaičiuokite vidutinį tiekimo laiką pagal tiekėją. Išrūšiuokite pagal tiekėją ir produktą.
Tikėtinas rezultatas:
# tiekejas, produktas, vid_pristatymo_laikas
'Advanced Bicycles', 'Thin-Jam Hex Nut 1', '10'
'Advanced Bicycles', 'Thin-Jam Hex Nut 10', '10'
'Advanced Bicycles', 'Thin-Jam Hex Nut 11', '10'
460 rows.*/

-- Neradau lenteliu ProductSupplier ir Supplier tai naudojau Purchasing

SELECT
    v.Name AS tiekejas,
    p.Name AS produktas,
    ROUND(
        AVG(
            DATEDIFF(
                poh.ShipDate,
                poh.OrderDate
            )
        ),
        0
    ) AS vid_pristatymo_laikas
FROM purchasing_purchaseorderheader poh
JOIN purchasing_purchaseorderdetail pod
    ON poh.PurchaseOrderID = pod.PurchaseOrderID
JOIN production_product p
    ON pod.ProductID = p.ProductID
JOIN purchasing_productvendor pv
    ON p.ProductID = pv.ProductID
JOIN purchasing_vendor v
    ON pv.BusinessEntityID = v.BusinessEntityID
WHERE poh.ShipDate IS NOT NULL
GROUP BY
    v.Name,
    p.Name
ORDER BY
    v.Name,
    p.Name;

/*6. Pardavimų sezoniškumo analizė
Užduotis: Parašykite užklausą, kuri apskaičiuoja mėnesio pardavimus 2013 metais,
naudodamiesi SalesOrderHeader duomenimis. Užklausoje turi būti:
• Mėnuo (iš OrderDate)
• Bendros pardavimų sumos
• Pardavimų kiekis
Užuomina: Filtruokite pagal 2023 metus, naudokite MONTH() funkciją, kad išgautumėte
mėnesio reikšmę ir MONTHNAME() mėnesio pavadinimui, ir apskaičiuokite bendrą pardavimų
sumą bei kiekį kiekvienam mėnesiui.
# menuo, menuo_pavadinimas, pardavimu_kiekis, pardavimu_suma
'1', 'January', '407', '2354903.68'
12 rows*/

SELECT 
    MONTH(OrderDate) AS menuo,
    MONTHNAME(OrderDate) AS menuo_pavadinimas,
    COUNT(SalesOrderID) AS pardavimu_kiekis,
    ROUND(SUM(TotalDue), 2) AS pardavimu_suma
FROM
    sales_salesorderheader
WHERE
    YEAR(OrderDate) = 2013
GROUP BY menuo , menuo_pavadinimas; 
