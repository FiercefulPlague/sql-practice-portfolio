-- 1. Užduotis. Raskite filmus, kurių nuomos kaina didesnė už visų filmų vidurkį.
SELECT 
    film_id, title, rental_rate
FROM
    film
WHERE
    rental_rate > (SELECT 
            AVG(rental_rate)
        FROM
            film);
            
-- 2. Raskite klientus, kurių vardas yra ilgesnis nei visų klientų vardų vidutinė trukmė.

SELECT 
    customer_id, first_name, last_name
FROM
    customer
WHERE
    LENGTH(first_name) > (SELECT 
            AVG(LENGTH(first_name)) 
        FROM
            customer);
            
-- 3. Raskite filmus, kurių trukmė ilgesnė nei vidutinė jų kalbos filmų trukmė.

WITH vid_trukme AS 
(SELECT 
    language_id, AVG(length) AS avg_length
FROM
    film
GROUP BY language_id)
SELECT 
    f.film_id, f.title, l.name, f.length
FROM
    film f
        JOIN
    language l ON f.language_id = l.language_id
        JOIN
    vid_trukme v ON f.language_id = v.language_id
WHERE
    f.length > v.avg_length
    ORDER BY f.length DESC;


-- 4. Raskite klientus, kurie paskutinį kartą nuomojo filmą seniau nei vidutinė visų paskutinių nuomų data.

WITH paskutines AS (
    SELECT customer_id,
           MAX(rental_date) AS last_rental
    FROM rental
    GROUP BY customer_id
),
vidurkis AS (
    SELECT AVG(last_rental) AS avg_last
    FROM paskutines
)
SELECT c.first_name,
       c.last_name,
       p.last_rental
FROM customer c
JOIN paskutines p ON c.customer_id = p.customer_id
CROSS JOIN vidurkis v
WHERE p.last_rental < v.avg_last;

-- 5. Raskite filmus, kurių pavadinimo ilgis didesnis nei vidutinis pavadinimų ilgis.

SELECT film_id, title FROM film
WHERE LENGTH(title) > (SELECT AVG(LENGTH(title)) FROM film); 

-- 6. Naudojant CTE, raskite kiekvieno kliento bendrą nuomų skaičių, sumą ir priskirkite kategoriją: 'Lojalus', 'Vidutinis', 'Naujokas'. Naudoti Case.

WITH customer_stats AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT r.rental_id) AS rental_count,
        COALESCE(SUM(p.amount), 0) AS total_amount
    FROM customer AS c
    LEFT JOIN rental AS r
        ON c.customer_id = r.customer_id
    LEFT JOIN payment AS p
        ON r.rental_id = p.rental_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    cs.first_name,
    cs.last_name,
    cs.rental_count,
    cs.total_amount,
    CASE
        WHEN cs.total_amount >= 150 THEN 'Lojalus'
        WHEN cs.total_amount >= 50 THEN 'Vidutinis'
        ELSE 'Naujokas'
    END AS customer_category
FROM customer_stats AS cs
ORDER BY cs.total_amount DESC;

-- 7. Naudojant CTE, raskite kiekvieno filmo aprašymo ilgį simboliais ir pažymėkite, ar jis ilgas (daugiau nei 30 simbolių). Naudoti IF.

WITH aprasymo_ilgis AS 
(SELECT 
    film_id, LENGTH(description) AS ilgis
FROM
    film)
SELECT 
    f.title,
    IF(ai.ilgis >= 30, 'ilgas', 'trumpas') AS ilgis
FROM
    film f
JOIN
    aprasymo_ilgis ai 
ON f.film_id = ai.film_id;

-- 8 Naudodami CTE, suskaičiuokite, kiek klientų gyvena kiekviename mieste, ir pažymėkite, ar klientų skaičius viršija ar ne 10. Case

WITH klientai_mieste AS (SELECT 
    ci.city_id, ci.city, COUNT(c.customer_id) AS klientai
FROM
    customer c
JOIN
    address a 
ON c.address_id = a.address_id
JOIN
    city ci 
ON a.city_id = ci.city_id
GROUP BY ci.city_id , ci.city)
SELECT 
    ci.city_id,
    ci.city,
    CASE
        WHEN km.klientai >= 10 THEN 'daugiau'
        ELSE 'maziau'
    END AS kiek_klientu
FROM
    city ci
JOIN
    klientai_mieste km 
ON ci.city_id = km.city_id; 


-- 9. Naudojant CTE, raskite kiekvieno darbuotojo vidutinę nuomos sumą ir pažymėkite, ar ji didesnė nei 3. IF.

WITH vid_sum AS (SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    ROUND(AVG(p.amount), 2) AS vidutine_suma
FROM
    staff s
JOIN
    payment p 
ON s.staff_id = p.staff_id
GROUP BY s.staff_id)
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    vs.vidutine_suma,
    IF(vs.vidutine_suma > 3, 'Taip', 'NE') AS 'Ar didesne nei 3'
FROM
    staff s
JOIN
    vid_sum vs 
ON s.staff_id = vs.staff_id; 


-- 10. Naudodami CTE, suskaičiuokite, kiek kartų kiekvienas filmas buvo išnuomotas ir priskirkite populiarumo lygį. Case.

WITH nuomos_kiekis AS (SELECT 
    f.film_id, f.title, COUNT(r.rental_id) AS kiekis
FROM
    film f
        JOIN
    inventory i ON f.film_id = i.film_id
        JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id)
SELECT 
    f.film_id,
    f.title,
    CASE
        WHEN nk.kiekis >= 40 THEN 'Labai populiarus'
        WHEN nk.kiekis >=20 THEN 'Populiarus'
        ELSE 'Nepopuliarus'
    END AS Populiarumas
FROM
    film f
        JOIN
    nuomos_kiekis nk ON f.film_id = nk.film_id; 

-- 11. Naudojant CTE, suskaičiuokite kiekvienos kategorijos filmų vidutinę trukmę ir klasifikuokite: 'Trumpi', 'Vidutiniai', 'Ilgi'.

WITH filmu_trukme AS (SELECT 
    c.category_id,
    c.name,
    ROUND(AVG(f.length), 2) AS vidutine_trukme
FROM
    film f
JOIN
    film_category fc 
ON f.film_id = fc.film_id
JOIN
    category c
ON fc.category_id = c.category_id
GROUP BY c.category_id)
SELECT 
    c.category_id,
    c.name,
    ft.vidutine_trukme,
    CASE
        WHEN ft.vidutine_trukme <= 110 THEN 'Trumpi'
        WHEN ft.vidutine_trukme BETWEEN 111 AND 120 THEN 'Vidutiniai'
        ELSE 'Ilgi'
    END AS 'Trukme'
FROM
    category c
        JOIN
    filmu_trukme ft ON c.category_id = ft.category_id;

-- 12. Naudodami CTE, suskaičiuokite, kiek kiekvienas klientas sumokėjo ir ar viršijo bendrą vidurkį. Case.

WITH klientu_sumos AS (SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS suma
FROM
    customer c
JOIN
    payment p 
ON c.customer_id = p.customer_id
GROUP BY c.customer_id),
average AS (SELECT 
    ROUND(AVG(suma), 2) AS vidurkis
FROM
    klientu_sumos)

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ks.suma,
    CASE
        WHEN ks.suma > a.vidurkis THEN 'Virsija'
        ELSE 'Nevirsija'
    END AS palyginimas
FROM
    customer c
JOIN
    klientu_sumos ks 
ON c.customer_id = ks.customer_id
CROSS JOIN
    average a;
