-- 1. Išveskite visų klientų vardus ir pavardes iš person_person.

SELECT 
    FirstName, LastName
FROM
    person_person;
    
-- 2. Suskaičiuokite kiek įrašų yra lentelėje person_person   

SELECT 
    COUNT(*) AS visi
FROM
    person_person;
    
-- 3. Išveskite visus miestus iš person_address, nesikartojančius.

SELECT DISTINCT
    (City)
FROM
    person_address;

-- 4.  Raskite kiek žmonių turi el. paštą (naudokite emailaddress).  

SELECT 
    COUNT(*)
FROM
    person_emailaddress;

-- 5. Išveskite pirmus 10 produktų iš production_product.

SELECT 
    ProductID, name 
FROM
    production_product
ORDER BY ListPrice DESC
LIMIT 10;

-- 6. Raskite visus produktus, kurių svoris yra didesnis nei 100.

SELECT 
    ProductID, Name, Weight
FROM
    production_product
WHERE
    Weight > 100;

-- 7. Raskite visas šalis, kurios prasideda raide 'C', naudokite LIKE

SELECT 
    Name
FROM
    person_countryregion
WHERE
    Name LIKE 'C%';

-- 8. Išveskite dabartinę datą naudodami CURRENT_DATE().

SELECT current_date();
SELECT DATE(MAX(OrderDate)), DATE(MIN(OrderDate)) FROM sales_salesorderheader;

-- 9. Raskite, kiek produktų neturi nurodyto svorio (weight IS NULL).

SELECT 
    ProductID, Name, Weight
FROM
    production_product
WHERE
    Weight IS NULL;
    
-- 10.  Suskaičiuokite, kiek darbuotojų yra lentelėje humanresources_employee

SELECT 
    COUNT(*) AS darbuotojai
FROM
    humanresources_employee;

SELECT 
    BusinessEntityID, JobTitle
FROM
    humanresources_employee;
    
-- 11. Raskite visus darbuotojus, kurių gimimo data po 1980 metų.

SELECT BusinessEntityID, JobTitle, BirthDate FROM humanresources_employee
WHERE YEAR(BirthDate) > 1980;

-- 12. Raskite visus produktus, kurių pavadinime yra žodis "Helmet".

SELECT ProductID, Name FROM production_product
WHERE Name LIKE '%Helmet%';

-- 13. Rūšiuokite produktus pagal kainą mažėjančia tvarka.

SELECT Name, ListPrice FROM production_product
ORDER BY ListPrice DESC;

-- 14. Apskaičiuokite vidutinę produkto kainą

SELECT 
    Name, ROUND(AVG(ListPrice), 2) AS vidutine_kaina
FROM
    production_product
GROUP BY Name
HAVING vidutine_kaina > 0;
    
-- 15. Konvertuokite produkto pavadinimą į didžiąsias raides.

SELECT 
    UPPER(Name)
FROM
    production_product;
    
-- 16. Raskite miestus, kurių pavadinimas ilgesnis nei 10 simbolių.

SELECT DISTINCT city FROM person_address 
WHERE character_length(city)>10;
 
    
-- 17. Apskaičiuokite kiek žmonių gyvena kiekviename mieste.

SELECT pa.City, COUNT(pp.BusinessEntityid) AS zmones FROM person_person pp
JOIN person_businessentityaddress pb ON pp.BusinessEntityID = pb.BusinessEntityID
JOIN person_address pa ON pb.AddressID = pa.AddressID 
GROUP BY pa.City;

-- 18. Raskite visus darbuotojus, kurių pavardė baigiasi 'son'

SELECT 
    pp.FirstName, pp.LastName
FROM
     humanresources_employee he
        JOIN
    person_person pp ON he.BusinessEntityID = pp.BusinessEntityID
WHERE
    pp.LastName LIKE '%SON';
    
-- 19. Sujunkite person_person ir emailaddress, kad gautumėte žmogų su jo el. paštu.

SELECT 
    pp.FirstName, pp.LastName, pe.EmailAddress
FROM
    person_emailaddress pe
        JOIN
    person_person pp ON pe.BusinessEntityID = pp.BusinessEntityID;
    
-- 20. Suskirstykite produktus į grupes pagal productsubcategoryid ir suskaičiuokite, kiek jų kiekvienoje.

SELECT 
    psc.ProductSubcategoryID, psc.Name, COUNT(pp.ProductID) AS kiekis
FROM
    production_productsubcategory psc
JOIN
    production_product pp 
ON psc.ProductSubcategoryID = pp.ProductSubcategoryID
GROUP BY psc.ProductSubcategoryID;

-- 21. Naudodami JOIN, parodykite klientų vardus ir miestus.

SELECT 
    pp.FirstName, pp.LastName, pa.City
FROM
    person_address pa
        JOIN
    person_businessentityaddress pb ON pa.AddressID = pb.AddressID
        JOIN
    person_person pp ON pb.BusinessEntityID = pp.BusinessEntityID;
    
SELECT DISTINCT
    pp.FirstName, pp.LastName, pa.City
FROM sales_customer sc
JOIN person_person pp 
  ON sc.PersonID = pp.BusinessEntityID      -- priklauso nuo tavo schemos
JOIN person_businessentityaddress pb 
  ON pp.BusinessEntityID = pb.BusinessEntityID
JOIN person_address pa 
  ON pb.AddressID = pa.AddressID;

-- 22. Sujunkite produktų ir jų kategorijų lenteles, parodykite produktų pavadinimus ir kategorijų pavadinimus.

SELECT 
    pp.Name AS Produktas, ppc.Name AS Kategorija
FROM
    production_productcategory ppc
        JOIN
    production_productsubcategory pps ON ppc.ProductCategoryID = pps.ProductCategoryID
        JOIN
    production_product pp ON pps.ProductSubcategoryID = pp.ProductSubcategoryID;

-- 23. Raskite 5 brangiausius produktus.

SELECT 
    Name, ListPrice
FROM
    production_product
ORDER BY ListPrice DESC
LIMIT 5;

-- 24. Naudokite CASE, kad pažymėtumėte produktus kaip 'Lengvas', 'Vidutinis', 'Sunkus' pagal svorį.

SELECT 
    Name,
    Weight,
    CASE
        WHEN Weight > 50 THEN 'Sunkus'
        WHEN Weight BETWEEN 15 AND 50 THEN 'Vidutinis'
        WHEN Weight IS NULL THEN 'Nenurodyta'
        ELSE 'Lengvas'
    END AS Svoris
FROM
    production_product;

-- 25. Naudokite IF() funkciją produkto kainos analizei – ar viršija 500.

SELECT 
    Name,
    ListPrice,
    IF(ListPrice > 500,
        'Virsija',
        'Nevirsija') AS 'Kainos Palyginimas'
FROM
    production_product;

-- 26. Raskite klientus, kurie turi daugiau nei vieną adresą (naudokite GROUP BY ir HAVING).

SELECT 
    CONCAT(pp.FirstName, ' ', pp.LastName) AS klientas,
    COUNT(pa.AddressID) AS adresai
FROM
    person_person pp
        JOIN
    person_businessentityaddress pb ON pp.BusinessEntityID = pb.BusinessEntityID
        JOIN
    person_address pa ON pb.AddressID = pa.AddressID
GROUP BY klientas
HAVING adresai > 1;

-- 27. Sukurkite CTE, kuris grąžina visus produktus, kurių kaina viršija vidurkį.

WITH vidurkis AS (SELECT 
    ROUND(AVG(ListPrice), 2) AS vid_kaina
FROM
    production_product)
SELECT 
    pp.name, pp.ListPrice, v.vid_kaina
FROM
    production_product pp
        CROSS JOIN
    vidurkis v
WHERE
    pp.ListPrice > v.vid_kaina;

-- 28. Naudokite subquery, kad rastumėte produktus brangesnius už visų produktų medianą.

SELECT 
    Name, ListPrice
FROM
    production_product
WHERE
    ListPrice > (SELECT 
            ROUND(AVG(ListPrice), 2)
        FROM
            production_product);
            
WITH ordered_prices AS (
  SELECT 
    ListPrice,
    ROW_NUMBER() OVER (ORDER BY ListPrice) AS row_num,
    COUNT(*) OVER () AS total_rows
  FROM production_product
  WHERE ListPrice > 0
),
median_calc AS (
  SELECT AVG(ListPrice) AS median_price
  FROM ordered_prices
  WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
)
SELECT 
  p.ProductID,
  p.Name,
  p.ListPrice
FROM production_product AS p
CROSS JOIN median_calc AS m
WHERE p.ListPrice > m.median_price
ORDER BY p.ListPrice DESC, p.ProductID;

select * from production_product;
SELECT p1.*
FROM production_product p1
WHERE (
  SELECT COUNT(*) 
  FROM production_product p2
  WHERE p2.ListPrice < p1.ListPrice
) >= (
  SELECT COUNT(*) 
  FROM production_product
) / 2;
 
WITH ordered_prices AS (
  SELECT listprice,
         ROW_NUMBER() OVER (ORDER BY listprice) AS rn,
         COUNT(*) OVER () AS total
  FROM production_product
),
median_price AS (
  SELECT listprice
  FROM ordered_prices
  WHERE rn = FLOOR((total + 1)/2)
)
SELECT * 
FROM production_product
WHERE listprice > (SELECT listprice FROM median_price);

-- 29. Raskite šalis, kuriose gyvena daugiau nei 5 žmonės (pagal adresus).

SELECT 
    pc.Name, COUNT(pp.BusinessEntityID) AS klientai
FROM
    person_person pp
JOIN
    person_businessentityaddress pb 
ON pp.BusinessEntityID = pb.BusinessEntityID
JOIN
    person_address pa 
ON pb.AddressID = pa.AddressID
JOIN
    person_stateprovince ps 
ON pa.StateProvinceID = ps.StateProvinceID
JOIN
    person_countryregion pc 
ON ps.CountryRegionCode = pc.CountryRegionCode
GROUP BY pc.Name
HAVING klientai > 5;

-- 30. Apskaičiuokite bendrą visų užsakymų pardavimo sumą iš sales_salesorderheader.

SELECT SUM(TotalDue) AS bendra_suma FROM sales_salesorderheader;

-- 31. Raskite kiek klientų pateikė bent vieną užsakymą.

SELECT 
    sc.CustomerID,
    pp.FirstName,
    pp.LastName,
    COUNT(ss.SalesOrderID) AS pirkimai
FROM
    sales_customer sc
        JOIN
    sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID
        JOIN
    person_person pp ON sc.CustomerID = pp.BusinessEntityID
GROUP BY sc.CustomerID
HAVING pirkimai >= 1;

SELECT COUNT(DISTINCT sc.CustomerID) AS klientu_kiekis
FROM sales_customer sc
JOIN sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID;


-- 32. Raskite kiekvieno kliento visų užsakymų sumą (vardas, pavardė, suma).

SELECT 
    sc.CustomerID,
    pp.FirstName,
    pp.LastName,
    SUM(ss.TotalDue) AS pirkimai
FROM
    sales_customer sc
        JOIN
    sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID
        JOIN
    person_person pp ON sc.CustomerID = pp.BusinessEntityID
GROUP BY sc.CustomerID;

-- 33. Apskaičiuokite kiek užsakymų buvo pateikta kiekvieną mėnesį.

SELECT 
    YEAR(OrderDate),
    MONTH(OrderDate),
    COUNT(SalesOrderID) AS uzsakymai
FROM
    sales_salesorderheader
GROUP BY YEAR(OrderDate) , MONTH(OrderDate);

-- 34. Išveskite 10 dažniausiai parduodamų produktų pagal kiekį.

SELECT 
    pp.ProductID, pp.Name, COUNT(sso.SalesOrderID) AS kiekis
FROM
    sales_salesorderheader sso
        JOIN
    sales_salesorderdetail ss ON sso.SalesOrderID = ss.SalesOrderID
        JOIN
    production_product pp ON ss.ProductID = pp.ProductID
GROUP BY pp.ProductID , pp.Name
ORDER BY kiekis DESC
LIMIT 10;

SELECT 
    pp.ProductID,
    pp.Name,
    SUM(ss.OrderQty) AS kiekis
FROM sales_salesorderdetail ss
JOIN production_product pp ON ss.ProductID = pp.ProductID
GROUP BY pp.ProductID, pp.Name
ORDER BY kiekis DESC
LIMIT 10;

-- 35. Raskite visus klientus, kurių pirkimo suma viršija vidutinę visų klientų sumą. (su subquery)

SELECT 
    sc.CustomerID, pp.FirstName, pp.LastName, ss.TotalDue
FROM
    sales_customer sc
        JOIN
    sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID
        JOIN
    person_person pp ON sc.CustomerID = pp.BusinessEntityID
WHERE
    ss.TotalDue > (SELECT 
            AVG(ss.TotalDue)
        FROM
            sales_salesorderheader ss);
		
SELECT 
    sc.CustomerID,
    pp.FirstName,
    pp.LastName,
    SUM(ss.TotalDue) AS suma
FROM sales_customer sc
JOIN sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID
JOIN person_person pp ON sc.PersonID = pp.BusinessEntityID
GROUP BY sc.CustomerID, pp.FirstName, pp.LastName
HAVING suma > (
    SELECT AVG(client_suma) 
    FROM (
        SELECT SUM(TotalDue) AS client_suma
        FROM sales_salesorderheader
        GROUP BY CustomerID
    ) t
);

-- 36. Parodykite kiekvieno produkto pavadinimą ir jo bendrą pardavimų sumą (naudoti JOIN su sales_salesorderdetail).

SELECT 
    pp.ProductID, pp.Name, SUM(ss.LineTotal) AS kiekis
FROM
    sales_salesorderdetail ss
        JOIN
    production_product pp ON ss.ProductID = pp.ProductID
GROUP BY pp.ProductID , pp.Name;

-- 37. Naudokite CASE, kad parodytumėte, ar produktas yra 'Pigus', 'Vidutinės kainos', ar 'Brangus' (pagal listprice).

SELECT 
    ProductID,
    Name,
    ListPrice,
    CASE
        WHEN ListPrice BETWEEN 0 AND 750 THEN 'Pigus'
        WHEN ListPrice BETWEEN 751 AND 1500 THEN 'Vidutines kainos'
        ELSE 'Brangus'
    END AS 'Kainos palyginimas'
FROM
    production_product;

-- 38. Išveskite užsakymus, kurių pristatymo kaina didesnė nei 10 % nuo visos užsakymo sumos (CASE ar IF su skaičiavimu).

SELECT SalesOrderID, Freight, TotalDue, CASE WHEN Freight > (TotalDue * 0.10)  THEN 'didesnis' ELSE 'mazesnis' END AS compare  FROM sales_salesorderheader;

-- 39. Raskite klientus, kurie pateikė daugiau nei 5 užsakymus.

SELECT sc.CustomerID, COUNT(ss.SalesOrderID) AS kiekis FROM sales_customer sc
JOIN sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID
GROUP BY sc.CustomerID
HAVING COUNT(ss.SalesOrderID) >= 5;

-- 40. Parodykite visų produktų sąrašą ir pažymėkite, ar jie kada nors buvo parduoti (CASE WHEN EXISTS (...) THEN 'Taip' ELSE 'Ne').

SELECT 
    pp.ProductID,
    pp.Name,
    CASE
        WHEN
            EXISTS( SELECT 
                    1
                FROM
                    sales_salesorderdetail so
                WHERE
                    so.ProductID = pp.ProductID)
        THEN
            'Taip'
        ELSE 'Ne'
    END AS SaleStatus
FROM
    production_product pp; 

-- 41. Apskaičiuokite pelną kiekvienam produktui (kaina - standarto kaina), parodykite tik tuos, kurių pelnas > 0.

SELECT 
    ProductID, Name, ListPrice - StandardCost AS pelnas
FROM
    production_product
WHERE
    ListPrice - StandardCost > 0; 

-- 42. Parodykite klientus, kurie pirko prekes už daugiau nei 1000.

SELECT 
    sc.CustomerID,
    pp.FirstName,
    pp.LastName,
    SUM(ss.TotalDue) AS pirkimai
FROM
    sales_customer sc
        JOIN
    sales_salesorderheader ss ON sc.CustomerID = ss.CustomerID
        JOIN
    person_person pp ON sc.CustomerID = pp.BusinessEntityID
GROUP BY sc.CustomerID
HAVING pirkimai > 1000;

-- 43. Parodykite produktus, kurie yra brangesni nei bet kuris "Helmet" tipo produktas. (su ANY ar subquery)

SELECT 
    ProductID, Name, ListPrice
FROM
    production_product
WHERE
    ListPrice > (SELECT 
            MAX(ListPrice)
        FROM
            production_product
        WHERE
            Name LIKE '%Helmet%');

-- 44. Parodykite kiekvienos produktų subkategorijos pardavimo sumą.

SELECT 
    pps.ProductSubcategoryID, pps.Name, SUM(sso.LineTotal)
FROM
    production_product pp
        JOIN
    production_productsubcategory pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
        JOIN
    sales_salesorderdetail sso ON pp.ProductID = sso.ProductID
GROUP BY pps.ProductSubcategoryID , pps.Name; 

-- 45. Parodykite tik tuos produktus, kurių buvo parduota daugiau nei 100 vienetų.

SELECT 
    pp.ProductID, pp.Name, COUNT(ss.SalesOrderID) AS kiekis
FROM
    production_product pp
        JOIN
    sales_salesorderdetail ss ON pp.ProductID = ss.ProductID
GROUP BY pp.ProductID , pp.Name
HAVING COUNT(ss.SalesOrderID) > 100;

SELECT 
    pp.ProductID, pp.Name, SUM(ss.OrderQty) AS kiekis
FROM production_product pp
JOIN sales_salesorderdetail ss ON pp.ProductID = ss.ProductID
GROUP BY pp.ProductID, pp.Name
HAVING SUM(ss.OrderQty) > 100;

-- 46. Apskaičiuokite kiek produktų yra kiekvienoje kainos kategorijoje: <100, 100–500, >500.

SELECT 
    CASE
        WHEN ListPrice < 100 THEN '<100'
        WHEN ListPrice BETWEEN 100 AND 500 THEN '100-500'
        ELSE '>500'
    END AS Kategorija,
    COUNT(ProductID) AS kiekis
FROM
    production_product
GROUP BY Kategorija;

-- 47. Parodykite darbuotojus, kurie dirba daugiau nei metus, 5 metus ir daugiau nei 10 metų (skaičiuoti su DATEDIFF()).

SELECT 
    pp.BusinessEntityID,
    pp.FirstName,
    pp.LastName,
    CASE 
         WHEN DATEDIFF(CURRENT_DATE(), he.HireDate) > 3650 THEN '>10 years'
        WHEN DATEDIFF(CURRENT_DATE(), he.HireDate) > 1825 THEN '>5 years'
        WHEN DATEDIFF(CURRENT_DATE(), he.HireDate) > 365 THEN '>1 year'
        ELSE '<=1 year'
    END AS stazas
FROM person_person pp
JOIN humanresources_employee he 
    ON pp.BusinessEntityID = he.BusinessEntityID
JOIN humanresources_employeedepartmenthistory hed 
    ON he.BusinessEntityID = hed.BusinessEntityID;

-- 48. Raskite, kurie produktai generavo didžiausią pardavimų pajamų sumą.

SELECT 
    pp.ProductID, pp.Name, SUM(ss.LineTotal) AS kiekis
FROM
    production_product pp
        JOIN
    sales_salesorderdetail ss ON pp.ProductID = ss.ProductID
GROUP BY pp.ProductID , pp.Name
ORDER BY kiekis DESC;






