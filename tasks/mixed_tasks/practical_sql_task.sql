-- 1 uzduotis
SELECT 
    title, length
FROM
    film; 

-- 2 uzduotis    
SELECT 
    first_name, last_name, email
FROM
    customer;
    
-- 3 uzduotis
SELECT 
    *
FROM
    film
WHERE
    title LIKE 'C%';
    
-- 4 uzduotis
SELECT 
	*
FROM
   film
ORDER BY title ASC
LIMIT 10;

-- 5 uzduotis
SELECT 
    *
FROM
    customer
WHERE
    last_name = 'Smith';

-- 6 uzduotis
SELECT 
    *
FROM
    film
ORDER BY length DESC
LIMIT 5;

-- 7 uzduotis
SELECT 
    *
FROM
    film
WHERE
    length > 100 AND rental_rate > 2.99;