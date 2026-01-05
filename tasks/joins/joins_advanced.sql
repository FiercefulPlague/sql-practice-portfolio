USE SAKILA;
-- 1. Raskite, kuriame filme vaidino daugiausia aktorių. Rezultatas: Filmo pavadinimas ir aktorių skaičius.

SELECT 
    f.title, COUNT(fa.actor_id) AS aktoriai
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY aktoriai DESC
LIMIT 1;

-- 2. Kiek kartų filmas „Academy Dinosaur“ buvo išnuomotas parduotuvėje, kurios ID yra 1? Rezultatas: Išnuomotų filmų skaičius.

SELECT 
    COUNT(rental_id) AS filmu_skaicius
FROM
    film f
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
WHERE
    f.title LIKE 'Academy Dinosaur'
        AND i.store_id = 1;

-- 3. Išvardinkite trijų populiariausių filmų pavadinimus. Rezultatas: Filmo pavadinimas, nuomos kartai.

SELECT 
    f.title, COUNT(rental_id) AS filmu_skaicius
FROM
    film f
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY filmu_skaicius DESC
LIMIT 3;

-- 4. Suskaičiuokite, kiek filmų yra nusifilmavę aktoriai. Rezultatas: Filmų skaičius, aktoriaus vardas ir pavardė. Papildoma sąlyga: Pateikite 10 aktorių, nusifilmavusių daugiausiai filmų (Top 10).

SELECT 
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS filmu_skaicius
FROM
    film_actor fa
JOIN
    actor a ON fa.actor_id = a.actor_id
GROUP BY a.first_name , a.last_name
ORDER BY filmu_skaicius DESC
LIMIT 10;

-- 5. Suskaičiuokite, kiek yra kiekvieno žanro filmų ir kokia yra vidutinė kiekvieno žanro filmo trukmė. Rezultatas: Filmų skaičius ir žanro pavadinimas. 
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal vidutinę filmo trukmę mažėjimo tvarka.

SELECT 
    c.name,
    COUNT(fc.film_id) AS kiekis,
    ROUND(AVG(f.length), 2) AS trukme
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY trukme DESC;

-- 6. Pateikite filmus, kurių film_id reikšmė yra nuo 1 iki 5, ir juose vaidinusius aktorius. Rezultatas: Filmo pavadinimas, aktoriaus vardas ir pavardė. 
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal filmo pavadinimą didėjimo tvarka ir pagal aktoriaus vardą bei pavardę mažėjimo tvarka.

SELECT 
    f.title, CONCAT(a.first_name, ' ', a.last_name) AS aktorius
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
WHERE
    f.film_id BETWEEN 1 AND 5
ORDER BY f.title ASC , a.first_name DESC , a.last_name DESC;

-- 7. Suskaičiuokite, kiek kiekvienas klientas yra sumokėjęs už filmų nuomą. Rezultatas: Kliento vardas, pavardė, adresas ir sumokėta suma. Papildoma sąlyga: Pateikite tik tuos klientus, kurie yra sumokėję 170 ar didesnę sumą.

SELECT 
    c.first_name, c.last_name, a.address, SUM(p.amount) AS suma
FROM
    customer c
JOIN
    address a ON c.address_id = a.address_id
JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name , c.last_name , a.address
HAVING suma >= 170; 

-- 8. Raskite, kiek filmų nusifilmavo kiekvienas aktorius, priklausomai nuo filmo žanro. Rezultatas: Filmų skaičius, aktoriaus vardas ir pavardė, filmo žanras. 
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal aktoriaus vardą, pavardę ir filmo žanrą didėjimo tvarka.

SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS aktoriai,
    c.name,
    COUNT(f.film_id) AS filmu_skaicius
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
GROUP BY aktoriai , c.name
ORDER BY aktoriai ASC , c.name ASC;

-- 9. Suskaičiuokite, kiek klientų yra kiekvienoje šalyje. Rezultatas: Šalis ir klientų skaičius. 
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal klientų skaičių mažėjimo tvarka. Pateikite tik 5 šalis, turinčias daugiausiai klientų.

SELECT 
    co.country, COUNT(c.customer_id) AS klientai
FROM
    customer c
JOIN
    address a ON c.address_id = a.address_id
JOIN
    city ci ON a.city_id = ci.city_id
JOIN
    country co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY klientai DESC
LIMIT 5;

-- 10. Kuris filmas atnešė didžiausias pajamas? Rezultatas: Filmo pavadinimas ir pajamos.

SELECT 
    f.title, SUM(p.amount) AS pajamos
FROM
    film f
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
JOIN
    payment p ON r.rental_id = p.rental_id
GROUP BY f.title
ORDER BY pajamos DESC
LIMIT 1;

-- 11. Kiek kartų buvo nuomojamasi kiekvienoje šalyje? Rezultatas: Šalies pavadinimas, nuomos kartai. 
-- Papildoma sąlyga: Išvardinkite tik tas šalis, kuriose buvo nuomojamasi bent kartą. Rezultatus išrikiuokite pagal nuomos kartus mažėjimo tvarka.

SELECT 
    co.country, COUNT(r.rental_id) AS nuomos_kartai
FROM
    customer c
JOIN
    address a ON c.address_id = a.address_id
JOIN
    city ci ON a.city_id = ci.city_id
JOIN
    country co ON ci.country_id = co.country_id
JOIN
    payment p ON c.customer_id = p.customer_id
JOIN
    rental r ON p.rental_id = r.rental_id
GROUP BY co.country
HAVING nuomos_kartai >= 1
ORDER BY nuomos_kartai DESC;

-- 12. Kiek kartų kiekviena filmo kategorija buvo išnuomota? Rezultatas: Kategorijos pavadinimas, nuomos kartai. 
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal nuomos kartus mažėjimo tvarka.

SELECT 
    c.name, COUNT(r.rental_id) AS nuomos_kartai
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY c.name
ORDER BY nuomos_kartai DESC;

-- 13. Raskite kiekvienoje parduotuvėje bendrai visų klientų sumokėtą sumą. Rezultatas: Parduotuvės ID, adresas, miestas, šalis ir pajamos.

SELECT 
    s.store_id,
    a.address,
    ci.city,
    co.country,
    SUM(p.amount) AS pajamos
FROM
    store s
JOIN
    address a ON s.address_id = a.address_id
JOIN
    city ci ON a.city_id = ci.city_id
JOIN
    country co ON ci.country_id = co.country_id
JOIN
    staff st ON s.store_id = st.store_id
JOIN
    payment p ON st.staff_id = p.staff_id
GROUP BY s.store_id , a.address , ci.city , co.country;

-- 14. Išvardinkite lankytojus, kurie nuomavosi „sci-fi“ žanro filmus daugiau nei du kartus. Rezultatas: Lankytojo vardas, pavardė, nuomos kartai. 
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal nuomos kartus didėjimo tvarka.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS klientas,
    COUNT(r.rental_id) AS nuomos_kartai
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category ca ON fc.category_id = ca.category_id
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
JOIN
    payment p ON r.rental_id = p.rental_id
JOIN
    customer c ON p.customer_id = c.customer_id
WHERE
    ca.name LIKE 'Sci-fi'
GROUP BY klientas
HAVING nuomos_kartai > 2
ORDER BY nuomos_kartai ASC;





