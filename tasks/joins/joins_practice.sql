-- Atlikti žemiau aprašytas užduotis iš sakila duomenų bazės.
USE SAKILA;
-- 1. Suskaičiuoti, kiek yra aktorių, kurių pavardės prasideda A ir B raidėmis.Rezultatas: aktorių skaičius ir pavardės pirmąją raidę.

SELECT 
    LEFT(last_name, 1) AS pirma_raide, COUNT(*) AS visi
FROM
    actor
WHERE
    last_name LIKE 'A%'
OR last_name LIKE 'B%'
GROUP BY LEFT(last_name, 1);

-- 2. Suskaičiuoti kiek filmų yra nusifilmavę aktoriai. Rezultatas: filmų skaičius, aktoriaus vardas ir pavardė. Pateikti 10 aktorių, nusifilmavusių daugiausiai filmų (TOP 10).

SELECT 
    fa.actor_id,
    COUNT(fa.film_id) AS filmu_skaicius,
    a.first_name,
    a.last_name
FROM
    actor a
JOIN
    film_actor fa ON a.actor_id = fa.actor_id
GROUP BY fa.actor_id
ORDER BY filmu_skaicius DESC
LIMIT 10;

-- 3. Nustatyti kokia yra minimali, maksimali ir vidutinė kaina, sumokama už filmą. Rezultatas: pateikti tik minimalią, maksimalią ir vidutinę kainas.

SELECT 
    p.rental_id,
    f.title,
    MIN(p.amount) AS minimali,
    MAX(p.amount) AS maksimali,
    AVG(p.amount) AS vidutine
FROM
    payment p
JOIN
    rental r ON p.rental_id = r.rental_id
JOIN
    inventory i ON r.inventory_id = i.inventory_id
JOIN
    film f ON i.film_id = f.film_id
GROUP BY p.rental_id , f.title;

SELECT 
    MIN(p.amount) AS minimali,
    MAX(p.amount) AS maksimali,
    AVG(p.amount) AS vidutine
FROM
    payment p;


-- 4. Suskaičiuoti, kiek kiekviena parduotuvė turi klientų.

SELECT 
    s.store_id, COUNT(c.customer_id) AS klientai
FROM
    customer c
JOIN
    store s ON c.store_id = s.store_id
GROUP BY s.store_id;

-- 5. Suskaičiuoti kiek yra kiekvieno žanro filmų. Rezultatas: filmų skaičius ir žanro pavadinimą. Rezultatą surikiuoti pagal filmų skaičių mažėjimo tvarka.

SELECT 
    c.name, COUNT(fc.film_id) AS filmai
FROM
    category c
JOIN
    film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY filmai DESC;

-- 6. Sužinoti, kuriame filme vaidino daugiausiai aktorių. Rezultatas: filmo pavadinimas ir aktorių skaičius.

SELECT 
    f.title, COUNT(fa.actor_id) AS aktoriai
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY aktoriai DESC
LIMIT 1;

-- 7. Pateikti filmus ir juose vaidinusius aktorius. Rezultatas: filmo pavadinimas, aktoriaus vardas ir pavardė. 
-- Rezultate turi būti rodomi tik filmai, kurių identifikatoriaus (film_id) reikšmė yra nuo 1 iki 2. Duomenys rūšiuojami pagal filmo pavadinimą, aktoriaus vardą ir pavardę didėjančia tvarka.

SELECT 
    f.title,
    CONCAT(a.first_name, ' ', a.last_name) AS aktoriaus_vardas
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
WHERE
    f.film_id IN (1 , 2)
ORDER BY f.title ASC , a.first_name ASC , a.last_name ASC;  

-- 8. Suskaičiuoti, kiek filmų yra nusifilmavęs kiekvienas aktorius. Rezultatas: filmų skaičius, aktoriaus vardas, pavardė. Rezultatą surikiuoti pagal filmų skaičių mažėjančia tvarka ir pagal aktoriaus vardą didėjančia tvarka.

SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS aktoriai,
    COUNT(fa.film_id) AS filmai
FROM
    actor a
JOIN
    film_actor fa ON a.actor_id = fa.actor_id
GROUP BY aktoriai
ORDER BY filmai DESC , aktoriai ASC;

-- 9. Suskaičiuoti kiek miestų prasideda A, B, C ir D raidėmis. Rezultatas: miestų skaičius ir miesto pavadinimo pirmoji raidė.

SELECT 
    LEFT(city, 1) AS pirma_raide, COUNT(*) AS visi
FROM
    city
WHERE
    city LIKE 'A%' OR city LIKE 'B%'
OR city LIKE 'C%'
OR city LIKE 'D%'
GROUP BY pirma_raide;

SELECT * FROM city;

-- 10. Suskaičiuoti, kiek kiekvienas klientas yra sumokėjęs pinigų už filmų nuomą.Rezultatas: kliento vardas, pavardė, adresas, apygarda (district) ir sumokėta pinigų suma. 
-- Turi būti pateikiami tik tie klientai, kurie yra sumokėję 170 ar didesnę pinigų sumą.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS klientas,
    CONCAT(a.address, ' ', a.district) AS adresas,
    SUM(p.amount) AS pinigu_suma
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
JOIN
    address a ON c.address_id = a.address_id
GROUP BY klientas , adresas
HAVING pinigu_suma >= 170;

-- 11. Suskaičiuoti, kiek pinigų už filmus yra sumokėję kiekvienos apygardos klientai kartu. Rezultatas: apygardą (district) ir išleista pinigų suma. 
-- Pateikti tik tas apygardas, kurios yra išleidusios daugiau nei 700 pinigų. Duomenis surūšiuoti pagal apygardą didėjančia tvarka.

SELECT 
    a.district, SUM(p.amount) AS pinigu_suma
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
JOIN
    address a ON c.address_id = a.address_id
GROUP BY a.district
HAVING pinigu_suma >= 700
ORDER BY a.district ASC;


-- 12. Suskaičiuoti, kiek filmų nusifilmavo kiekvienas aktorius priklausomai nuo filmo žanro (kategorijos). Rezultatas: filmų skaičius, aktoriaus vardas ir pavardė, filmo žanras (kategorija). 
-- Rezultatą surūšiuoti pagal aktoriaus vardą, pavardę, filmo žanrą didėjančia tvarka.

SELECT 
    a.first_name,
    a.last_name,
    c.name,
    COUNT(f.film_id) AS filmai
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
GROUP BY a.actor_id , c.category_id
ORDER BY a.first_name ASC , a.last_name ASC , c.name ASC;


-- 13. Suskaičiuoti kiek filmų savo filmo aprašyme turi žodį „drama“. (Kiek kartų žodis pasikartoja nėra svarbu). Rezultatas: tik filmų skaičius ir filmo žanras. 
-- Pateikti tik tuos filmų žanrus, kurie turi 7 ir daugiau filmų, kuriuose yra žodis „drama“ (filmo aprašymui naudoti lauką iš lentos film_text).

SELECT 
    c.name, COUNT(f.film_id) AS filmai
FROM
    film f
JOIN
    film_text ft ON f.film_id = ft.film_id
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
WHERE
    ft.description LIKE '%drama%'
GROUP BY c.name
HAVING filmai >= 7; 

-- 14. Suskaičiuoti kiek klientų yra kiekvienoje šalyje. Rezultatas: klientų skaičius ir šalis. Duomenis surikiuoti pagal klientų skaičių mažėjančia tvarka. 
-- Pateikti tik 5 šalis, turinčias daugiausiai klientų.

SELECT 
    co.country, COUNT(c.customer_id) AS klientu_skaicius
FROM
    customer c
JOIN
    address a ON c.address_id = a.address_id
JOIN
    city ci ON a.city_id = ci.city_id
JOIN
    country co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY klientu_skaicius DESC
LIMIT 5;
 
-- 15. Suskaičiuoti kiekvienoje parduotuvėje bendrai visų klientų sumokėtą sumą. Rezultatas: parduotuvės identifikatorius (store_id), parduotuvės adresas, miestas ir šalis,

SELECT 
    s.store_id,
    a.address,
    ci.city,
    co.country,
    SUM(p.amount) AS klientu_sumoketa_suma
FROM
    store s
JOIN
    customer c ON s.store_id = c.store_id
JOIN
    payment p ON c.customer_id = p.customer_id
JOIN
    address a ON s.address_id = a.address_id
JOIN
    city ci ON a.city_id = ci.city_id
JOIN
    country co ON ci.country_id = co.country_id
GROUP BY s.store_id , a.address , ci.city , co.country;


