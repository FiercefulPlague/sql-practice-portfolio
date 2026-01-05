-- /*MySQL functions Tasks BONUS už gražų kodą ir gerą formatavimą, įvairius kodų variantus, kūrybiškumą
USE SAKILA;
-- 1. Raskite aktorių vardus, kurių pavardė prasideda raide „A“, ir pridėkite simbolių skaičių prie kiekvieno jų vardo.

SELECT 
    first_name,
    last_name,
    LENGTH(first_name) AS simboliu_skaicius
FROM
    actor
WHERE
    last_name LIKE 'A%';

-- 2. Apskaičiuokite kiekvieno kliento nuomos mokesčio vidurkį.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS kliento_vardas,
    AVG(p.amount) AS vidutine_suma
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY kliento_vardas;

-- 3. Sugrupuokite nuomas pagal metus ir mėnesį bei parodykite jų skaičių.

SELECT 
    CONCAT(YEAR(rental_date),
            '-',
            MONTH(rental_date)) AS nuomos_data,
    COUNT(*) AS kartai
FROM
    rental
GROUP BY nuomos_data;

-- 4. Parodykite klientų vardus su jų bendrais mokėjimais, apvalinant iki dviejų skaitmenų po kablelio.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS kliento_vardas,
    ROUND(SUM(p.amount),2) AS bendra_suma
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY kliento_vardas
ORDER BY bendra_suma DESC;


-- 5. Rodyti kiekvieną filmą, id, pavadinimo pirmus 2 žodžius ir ar jo trukmė ilgesnė nei vidutinė (IF)

SELECT 
    film_id,
    SUBSTRING_INDEX(title, ' ', 2) AS pirmi_zodziai,
    IF(length > (SELECT 
                AVG(length)
            FROM
                film),
        'Longer',
	IF(length = (SELECT 
                    AVG(length)
                FROM
                    film),
            'Equal',
            'Shorter')) AS palyginimas
FROM
    film;


-- 6. Išveskite visas kategorijas ir skaičių filmų, priklausančių kiekvienai kategorijai, bendrą pelną, vidutinį nuomos įkainį.

SELECT 
    c.name,
    COUNT(f.film_id) AS filmai,
    SUM(p.amount) AS pelnas,
    ROUND(AVG(f.rental_rate), 2) AS vid_nuoma
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
JOIN
    payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

-- 7. Raskite visų nuomų, kurios įvyko darbo dienomis ir savaitgaliais, skaičių ir generuotas sumas

SELECT 
    CASE
        WHEN DAYOFWEEK(r.rental_date) IN (1, 7) THEN 'Weekend'
		ELSE 'Weekday'
    END AS dienos_tipas,
    COUNT(r.rental_id) AS nuomu_skaicius,
    SUM(p.amount) AS suma
FROM
    payment p
JOIN rental r ON p.rental_id = r.rental_id
GROUP BY dienos_tipas;

-- 8. Išveskite aktorius, kurių vardai yra ilgesni nei 6 simboliai.

SELECT 
    *
FROM
    actor
WHERE
    LENGTH(first_name) > 6;

-- 9. Išveskite filmų pavadinimus kartu su jų kategorijomis, sudarytą viename stulpelyje.

SELECT 
    CONCAT(f.title, ':', c.name) AS filmai
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id;

-- 10. Raskite aktoriaus pilną vardą ir kiek filmų jis (ji) suvaidino.

SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS aktorius,
    COUNT(f.film_id)
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
GROUP BY aktorius;

-- 11. Parodykite nuomų, kurios buvo grąžintos vėluojant 3 dienas ar daugiau, skaičių.

SELECT 
    COUNT(*) AS velavo
FROM
    rental
WHERE
    DATEDIFF(return_date, rental_date) >= 3;
    
SELECT COUNT(*) AS veluojanciu_nuomu_sk
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE DATEDIFF(r.return_date, r.rental_date) > f.rental_duration + 3;
 

-- 12. Raskite visų filmų pavadinimų raidžių skaičių vidurkį.

SELECT ROUND(AVG(LENGTH(title)),2) AS pavadinimo_ilgis FROM film;

-- 13. Išveskite klientus, kurių vardai prasideda raide „M“, ir parodykite jų mokėjimų sumą.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS klientas,
    SUM(p.amount) AS mokejimo_suma
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
WHERE
    LEFT(c.first_name, 1) = 'M'
GROUP BY klientas;

-- 14. Apskaičiuokite, kokią pajamų dalį sudaro nuomos, kurios truko mažiau nei 5 dienas.

SELECT 
    CONCAT(ROUND(SUM(CASE
                        WHEN DATEDIFF(r.return_date, r.rental_date) < 5 THEN p.amount
                        ELSE 0
                    END) / SUM(p.amount) * 100,
                    2),
            '%') AS pajamu_dalis
FROM
    rental r
        JOIN
    payment p USING (rental_id);

-- 15. Parodykite filmų trukmes, sugrupuotas pagal intervalus (pvz., 0-60 min, 61-120 min ir t.t.).

SELECT 
    CASE
        WHEN length BETWEEN 0 AND 60 THEN '0-60min'
        WHEN length BETWEEN 61 AND 120 THEN '61-120min'
        WHEN length BETWEEN 121 AND 180 THEN '121-180min'
        ELSE '181+ min'
    END AS trukme,
    COUNT(*) AS filmai
FROM
    film
GROUP BY trukme;

-- 16. Klientai su paskutine nuomos data ir jos mėnesiu

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS klientas,
    MAX(r.rental_date) AS paskutine_nuoma,
    MONTH(MAX(r.rental_date)) AS menuo
FROM
    customer c
LEFT JOIN
    rental r ON c.customer_id = r.customer_id
GROUP BY klientas;

-- 17. Kiek nuomų atliko kiekvienas klientas (vardas pavardė sujungti)

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS klientas,
    COUNT(r.rental_id)
FROM
    customer c
JOIN
    rental r ON c.customer_id = r.customer_id
GROUP BY klientas;

-- 18. Rodyti kiekvienos nuomos trukmę dienomis

SELECT 
    DATEDIFF(return_date, rental_date) AS nuomos_trukme
FROM
    rental;

-- 19. Priskirti klientui kategoriją pagal jų generuotas sumas (CASE)

SELECT 
    CONCAT(c.customer_id,
            ':',
            c.first_name,
            ' ',
            c.last_name) AS klientas,
    SUM(p.amount) AS suma,
    CASE
        WHEN SUM(p.amount) < 50 THEN 'Zemas'
        WHEN SUM(p.amount) BETWEEN 50 AND 150 THEN 'Vidutinis'
        ELSE 'Aukstas'
    END AS kategorija
FROM
    customer c
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY klientas;

















