-- STORED PROCEDURES-- 
-- Pavyzdys 1: Gauti kliento vardą ir pavardę pagal customer_id
DROP PROCEDURE IF EXISTS get_customer_name;
DELIMITER $$
CREATE PROCEDURE get_customer_name (
    IN cust_id INT,
    OUT full_name VARCHAR(100)
)
BEGIN
    SELECT CONCAT(first_name, ' ', last_name)
    INTO full_name
    FROM customer
    WHERE customer_id = cust_id;
END$$
DELIMITER ;
 
-- Naudojimas:
CALL get_customer_name(11, @name);
SELECT @name;

-- Pavyzdys 2: Suskaičiuoti filmų kiekį pagal kategorijos ID

DROP PROCEDURE IF EXISTS count_films_in_category;

DELIMITER $$
CREATE PROCEDURE count_films_in_category (
    IN cat_id INT,
    OUT film_count INT
)
BEGIN
    SELECT COUNT(*)
    INTO film_count
    FROM film_category
    WHERE category_id = cat_id;
END$$
DELIMITER ;

select distinct category_id from film_category;

-- Naudojimas:

CALL count_films_in_category(1, @count);
SELECT @count;
 
 -- Pavyzdys 3: 2 rezultatai 
DROP PROCEDURE IF EXISTS get_category_revenue_summary;
DELIMITER $$
 
CREATE PROCEDURE get_category_revenue_summary ()
BEGIN
    -- Pirmas rezultatas: Pajamos pagal kategoriją
    SELECT ca.name AS category_name,
           SUM(p.amount) AS total_revenue
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category ca ON fc.category_id = ca.category_id
    GROUP BY ca.name
    ORDER BY total_revenue DESC;
 
    -- Antras rezultatas: Vidutinė filmų kaina pagal kategoriją
    SELECT ca.name AS category_name,
           round(AVG(f.rental_rate),2) AS average_rental_rate
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category ca ON fc.category_id = ca.category_id
    GROUP BY ca.name
    ORDER BY average_rental_rate DESC;
END$$
 
DELIMITER ;
 
 
-- Naudojimas:
CALL get_category_revenue_summary();

-- Pavyzdys 4: Procedūra su IF logika - skiriasi nuo MySQL IF funkcijos ;)
DROP PROCEDURE IF EXISTS check_film_price_category;
DELIMITER $$
 
CREATE PROCEDURE check_film_price_category (
    IN p_film_id INT,
    OUT price_category VARCHAR(20)
)
BEGIN
    DECLARE rental_price DECIMAL(4,2);
 
    SELECT rental_rate INTO rental_price
    FROM film
    WHERE film_id = p_film_id;
 
    -- IF logika kainos kategorijai priskirti
    IF rental_price >= 4.00 THEN
        SET price_category = 'Expensive';
    ELSEIF rental_price >= 2.00 THEN
        SET price_category = 'Medium';
    ELSE
        SET price_category = 'Cheap';
    END IF;
END$$
 
DELIMITER ;

-- Naudojimas:
CALL check_film_price_category(159, @category);
SELECT @category;

-- Pavyzdys 5: Procedūra su CASE logika
DROP PROCEDURE IF EXISTS get_film_category_by_rating;
DELIMITER $$
 
CREATE PROCEDURE get_film_category_by_rating (
    IN p_film_id INT,
    OUT category_text VARCHAR(20)
)
BEGIN
    DECLARE film_rating VARCHAR(15);
 
    -- Taisyklinga WHERE sąlyga: parametrą atskiriam nuo stulpelio
    SELECT rating INTO film_rating
    FROM film
    WHERE film_id = p_film_id;
 
    -- CASE logika pagal rating
    CASE film_rating
        WHEN 'G' THEN SET category_text = 'Family';
        WHEN 'PG' THEN SET category_text = 'Kids';
        WHEN 'PG-13' THEN SET category_text = 'Teens';
        WHEN 'R' THEN SET category_text = 'Adults';
        ELSE SET category_text = 'Unknown';
    END CASE;
END$$
 
DELIMITER ;
 
CALL get_film_category_by_rating(100, @category);
SELECT @category;

-- Pavyzdys 6: Procedūra su WHILE ciklu
DROP PROCEDURE IF EXISTS simple_while_loop;
DELIMITER $$
CREATE PROCEDURE simple_while_loop ()
BEGIN
    DECLARE counter INT DEFAULT 1;
 
    WHILE counter <= 5 DO
        SELECT CONCAT('Counter is: ', counter);
        SET counter = counter + 1;
    END WHILE;
END$$
DELIMITER ;
 
call simple_while_loop();

-- FUNCTIONS-- 
-- Pavyzdys 1: Funkcija, kuri grąžina film rental kainą pagal film_id
DROP FUNCTION IF EXISTS get_film_rental_price;
DELIMITER $$
CREATE FUNCTION get_film_rental_price(p_film_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
    DECLARE rental_price DECIMAL(4,2);
    SELECT rental_rate INTO rental_price
    FROM film
    WHERE film_id = p_film_id;
    RETURN rental_price;
END$$
DELIMITER ;
 
-- Naudojimas:
SELECT get_film_rental_price(110);

-- Pavyzdys 2: Funkcija, kuri apskaičiuoja bendrą sumokėtą sumą pagal customer_id
DROP FUNCTION IF EXISTS get_customer_total_payments;
DELIMITER $$
CREATE FUNCTION get_customer_total_payments(p_customer_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_payment DECIMAL(10,2);
    SELECT SUM(amount) INTO total_payment
    FROM payment
    WHERE customer_id = p_customer_id;
    RETURN IFNULL(total_payment, 0);
END$$
DELIMITER ;
 
-- Naudojimas:
SELECT customer_id, get_customer_total_payments(customer_id) AS total_paid FROM customer ;
-- limit 5;
-- galim patikrinti, ar yra nemokanciu
SELECT 
    customer_id, 
    first_name, 
    last_name, 
    get_customer_total_payments(customer_id) AS total_paid
FROM 
    customer
WHERE 
    get_customer_total_payments(customer_id) >= 100
ORDER BY 
    customer_id;

-- Pavyzdys 3: Funkcija, kuri pagal rental_rate grąžina kainos kategoriją
DROP FUNCTION IF EXISTS classify_film_price;
DELIMITER $$
CREATE FUNCTION classify_film_price(p_rental_rate DECIMAL(4,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_rental_rate >= 4.00 THEN 'Expensive'
        WHEN p_rental_rate >= 2.00 THEN 'Medium'
        ELSE 'Cheap'
    END;
END$$
DELIMITER ;
 
-- Naudojimas:
SELECT 
    film_id,
    title,
    rental_rate,
    CLASSIFY_FILM_PRICE(rental_rate) AS price_category
FROM
    film
LIMIT 10;

-- Pavyzdys 4: Funkcija, kuri grąžina filmų kiekį tam tikroje kategorijoje
DROP FUNCTION IF EXISTS count_films_in_category;
DELIMITER $$
CREATE FUNCTION count_films_in_category(p_category_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE film_count INT;
    SELECT COUNT(*) INTO film_count
    FROM film_category
    WHERE category_id = p_category_id;
    RETURN film_count;
END$$
DELIMITER ;
 
-- Naudojimas:
SELECT category_id, name, count_films_in_category(category_id) AS film_count FROM category;





























