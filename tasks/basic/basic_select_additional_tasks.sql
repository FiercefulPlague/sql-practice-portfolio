-- Užduotims atlikti reikalingos šios sakila duomenų bazės lentos: rental, payment, film_category, film, actor, address.
USE SAKILA;
-- 1. Kiek skirtingų prekių buvo išnuomota?

SELECT 
    COUNT(DISTINCT inventory_id) AS skirtingos_prekes
FROM
    rental;

-- 2. Top 5 klientai, kurie daugiausia kartų naudojosi nuomos paslaugomis.

SELECT 
    customer_id, COUNT(customer_id) AS nuoma
FROM
    rental
GROUP BY customer_id
ORDER BY nuoma DESC
LIMIT 5;

-- 3. Išrinkti nuomos id, kurių nuomos ir grąžinimo datos sutampa.  Rezultatas: nuomos id, nuomos data, grąžinimo data. Pateikti mažėjimo tvarka pagalnuomos id (reikalinga papildoma date() funkcija).

SELECT 
    rental_id, rental_date, return_date
FROM
    rental
WHERE
    DATE(rental_date) = DATE(return_date)
ORDER BY rental_id DESC;

-- 4. Kuris klientas išleido daugiausia pinigų nuomos paslaugoms? Pateikti tik vieną klientą ir išleistą pinigų sumą.

SELECT 
    customer_id, SUM(amount) AS pinigu_suma
FROM
    payment
GROUP BY customer_id
ORDER BY pinigu_suma DESC
LIMIT 1;

SELECT 
    p.customer_id, c.first_name, c.last_name, SUM(p.amount) AS pinigu_suma
FROM
    payment P
JOIN customer c ON p.customer_id= c.customer_id
GROUP BY p.customer_id
ORDER BY pinigu_suma DESC
LIMIT 1;

-- 5. Kiek klientų aptarnavo kiekvienas darbuotojas, kiek nuomos paslaugų pardavė ir už kokią vertę?

SELECT 
    staff_id,
    COUNT(DISTINCT customer_id) AS klientai,
    COUNT(rental_id) AS nuomos_paslaugos,
    SUM(amount) AS verte
FROM
    payment
GROUP BY staff_id;

-- 6. Į ekraną išvesti visus nuomos id, kurie prasideda '9', suskaičiuoti jų vertę, pateikti nuo mažiausio nuomos id.

SELECT 
    rental_id, SUM(amount) AS verte
FROM
    payment
WHERE
    rental_id LIKE '9%'
GROUP BY rental_id
ORDER BY rental_id ASC;

-- 7. Kurios kategorijos filmų yra mažiausiai?

SELECT 
    category_id, COUNT(category_id) AS filmai
FROM
    film_category
GROUP BY category_id
ORDER BY filmai ASC
LIMIT 1;

-- 8. Į ekraną išvesti filmų aprašymus, kurių reitingas 'R' ir aprašyme yra žodis 'MySQL'.

SELECT 
    description
FROM
    film
WHERE
    rating = 'R'
        AND description LIKE '%MySQL%';

-- 9. Surasti filmų id, kurių trukmė 46, 47, 48, 49, 50, 51 minutės. Rezultatas: pateikiamas didėjančia tvarka pagal trukmę.

SELECT 
    film_id, length
FROM
    film
WHERE
    length BETWEEN 46 AND 51
ORDER BY length ASC;

-- 10. Į ekraną išvesti filmų pavadinimus, kurie prasideda raidė 'G' ir filmo trukmė mažesnė nei 70 minučių.

SELECT 
    title
FROM
    film
WHERE
    title LIKE 'G%' AND length < 70;

-- 11. Suskaičiuoti, kiek yra aktorių, kurių pirmoji vardo raidė yra 'A', o pirmoji pavardės raidė 'W'.

SELECT 
    COUNT(*) AS aktoriai
FROM
    actor
WHERE
    first_name LIKE 'A%'
        AND last_name LIKE 'W%';

-- 12. Suskaičiuoti kiek yra klientų, kurių pavardėje yra dvi O raidės ('OO').

SELECT 
    COUNT(*)
FROM
    customer
WHERE
    last_name LIKE '%OO%';

-- 13. Kiek rajonuose skirtingų adresų? Pateikti tuos rajonus, kurių adresų skaičius didesnis arba lygus 9.

SELECT 
    district, COUNT(address_id) AS adresai
FROM
    address
GROUP BY district
HAVING COUNT(address_id) >= 9;


-- 14. Į ekraną išvesti visus unikalius rajonų pavadinimus, kurie baigiasi raide 'D'.

SELECT DISTINCT
    district
FROM
    address
WHERE
    district LIKE '%D';

-- 15. Į ekraną išvesti adresus ir rajonus, kurių telefono numeris prasideda ir baigiasi skaičiumi '9'.

SELECT 
    address, district
FROM
    address
WHERE
    phone LIKE '9%9';




