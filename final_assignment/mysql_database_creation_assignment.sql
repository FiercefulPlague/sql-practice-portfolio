-- Database Creation --

DROP DATABASE IF EXISTS game_store;
CREATE DATABASE game_store;
USE game_store; 

 -- Table Creation -- 
 -- Loyalty Level -- 
 
 CREATE TABLE loyaltylevel (
    level_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    min_total_spent DECIMAL(10,2) NOT NULL,
    cashback_percentage DECIMAL(5,2) NOT NULL
);

 -- Customer -- 
 
 CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    loyalty_level_id INT NOT NULL,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(30),
    total_spent DECIMAL(10,2) DEFAULT 0,
    credit_balance DECIMAL(10,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (loyalty_level_id)
        REFERENCES loyaltylevel(level_id)
);

 -- Game -- 
 
 CREATE TABLE game (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    publisher VARCHAR(100),
    release_year YEAR,
    genre VARCHAR(100)
);

 -- GameVersion -- 
 
 CREATE TABLE gameversion (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,

    platform_name VARCHAR(50) NOT NULL,   -- Steam, EA App, PS Store, Xbox Store
    price DECIMAL(10,2) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,

    FOREIGN KEY (game_id)
        REFERENCES game(game_id)
);

 -- DigitalKeys -- 
 
 CREATE TABLE digitalkeys (
    key_id INT AUTO_INCREMENT PRIMARY KEY,
    version_id INT NOT NULL,
    key_code VARCHAR(255) UNIQUE NOT NULL,
    is_sold BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (version_id)
        REFERENCES gameversion(version_id)
);

 -- Orders -- 
 
 CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    cashback_awarded DECIMAL(10,2) DEFAULT 0,

    FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);

 -- OrderItems -- 
 
 CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    version_id INT NOT NULL,
    digital_key_id INT NOT NULL,
    price_at_purchase DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (version_id)
        REFERENCES gameversion(version_id),
    FOREIGN KEY (digital_key_id)
        REFERENCES digitalkeys(key_id)
);

-- DATA INSERT -- 
-- Loyalty Level -- 

INSERT INTO loyaltylevel (name, min_total_spent, cashback_percentage) VALUES
('Bronze', 0, 2),
('Silver', 300, 4),
('Gold', 1000, 7);

-- Customer -- 

INSERT INTO customer (loyalty_level_id, firstname, lastname, email, phone, total_spent, credit_balance) VALUES
(1, 'Jonas', 'Petrauskas', 'jonas.p@gmail.com', '+37060011223', 120.50, 2.41),
(2, 'Ieva', 'Jankauskaitė', 'ieva.j@gmail.com', '+37061233456', 480.00, 19.20),
(3, 'Tomas', 'Rimkus', 'tomas.r@gmail.com', '+37064555221', 1340.99, 93.87),
(1, 'Rūta', 'Butkutė', 'ruta.b@gmail.com', '+37062422119', 89.99, 1.80),
(2, 'Karolis', 'Misiūnas', 'karolis.m@gmail.com', '+37069914422', 620.10, 24.80);

-- Game -- 

INSERT INTO game (title, publisher, release_year, genre) VALUES
('Red Dead Redemption 2', 'Rockstar Games', 2018, 'Action-Adventure'),
('Hogwarts Legacy', 'Warner Bros', 2023, 'RPG'),
('God of War', 'Sony Santa Monica', 2018, 'Action'),
('Devil May Cry 5', 'Capcom', 2019, 'Hack and Slash'),
('Titanfall 2', 'Electronic Arts', 2016, 'FPS');

-- GameVersion -- 

INSERT INTO gameversion (game_id, platform_name, price, sku) VALUES
-- Red Dead Redemption 2
(1, 'Steam', 59.99, 'RDR2-STEAM'),
(1, 'Rockstar Launcher', 59.99, 'RDR2-RL'),

-- Hogwarts Legacy
(2, 'Steam', 69.99, 'HL-STEAM'),
(2, 'PlayStation Store', 69.99, 'HL-PS'),

-- God of War
(3, 'Steam', 39.99, 'GOW-STEAM'),

-- Devil May Cry 5
(4, 'Steam', 29.99, 'DMC5-STEAM'),

-- Titanfall 2
(5, 'Steam', 19.99, 'TF2-STEAM'),
(5, 'EA App', 19.99, 'TF2-EA');

-- DigitalKeys -- 

INSERT INTO digitalkeys (version_id, key_code) VALUES
-- RDR2 Steam
(1, 'RDR2STEAMKDLQW9921'),
(1, 'RDR2STEAM992KDLA22'),
(1, 'RDR2STEAM882KDLA91'),

-- RDR2 Rockstar Launcher
(2, 'RDR2RL992KDLA221'),
(2, 'RDR2RLKDLA992331'),
(2, 'RDR2RL882KDLA912'),

-- Hogwarts Legacy Steam
(3, 'HLSTEAM992KDLA221'),
(3, 'HLSTEAMKDLA882311'),
(3, 'HLSTEAM992233KD1'),

-- Hogwarts Legacy PS
(4, 'HLPS992KDLA221'),
(4, 'HLPSKDLA882311'),
(4, 'HLPS992233KD1'),

-- God of War Steam
(5, 'GOWSTEAM992KDLA21'),
(5, 'GOWSTEAMKDLA88231'),
(5, 'GOWSTEAM992233KD'),

-- Devil May Cry 5 Steam
(6, 'DMC5STEAM992KDLA'),
(6, 'DMC5STEAMKDLA88'),
(6, 'DMC5STEAM992233'),

-- Titanfall 2 Steam
(7, 'TF2STEAM992KDLA'),
(7, 'TF2STEAMKDLA88'),
(7, 'TF2STEAM992233'),

-- Titanfall 2 EA App
(8, 'TF2EA992KDLA22'),
(8, 'TF2EAKDLA88231'),
(8, 'TF2EA992233KD');

-- Orders -- 

INSERT INTO orders (customer_id, total_amount, cashback_awarded) VALUES
(1, 59.99, 1.20),
(2, 69.99, 2.80),
(3, 119.98, 8.40),
(4, 39.99, 0.80),
(5, 49.98, 2.00);

-- OrderItems -- 

INSERT INTO orderitems (order_id, version_id, digital_key_id, price_at_purchase) VALUES
(1, 1, 1, 59.99),
(2, 3, 7, 69.99),
(3, 1, 2, 59.99),
(3, 5, 13, 39.99),
(4, 6, 16, 29.99),
(5, 7, 19, 19.99);

UPDATE digitalkeys dk
JOIN orderitems oi ON dk.key_id = oi.digital_key_id
SET dk.is_sold = TRUE; 

-- DATABASE TESTING --  

SELECT * FROM customer;
SELECT * FROM digitalkeys;
SELECT * FROM game;
SELECT * FROM gameversion;
SELECT * FROM loyaltylevel;
SELECT * FROM orderitems;
SELECT * FROM orders;

/*Task 1: List all customers with their loyalty level
Goal: Verify that each customer is correctly assigned to a loyalty level.
Display customer first name, last name, email and loyalty level name.*/

SELECT 
    c.firstname, c.lastname, c.email, l.name
FROM
    customer c
        JOIN
    loyaltylevel l ON c.loyalty_level_id = l.level_id;

/*Task 2: Show all games available in the store
Goal: Verify that the game catalog is correctly stored.
Display game title, publisher, release year and genre.*/

SELECT title, publisher, release_year, genre FROM game;

/*Task 3: Show all game versions with platform and price
Goal: Verify that each game can have multiple digital versions.
Display game title, platform name and price.*/

SELECT g.title, gv.platform_name, gv.price FROM game g
JOIN gameversion gv ON g.game_id = gv.game_id;

/*Task 4: List all digital keys and their sale status
Goal: Verify digital key inventory management.
Display key code, related game title, platform name and whether the key is sold or not.*/

SELECT 
    d.key_code,
    g.title,
    gv.platform_name,
    CASE
        WHEN d.is_sold = 1 THEN 'Sold'
        ELSE 'Not Sold'
    END AS sale_status
FROM
    digitalkeys d
        JOIN
    gameversion gv ON d.version_id = gv.version_id
        JOIN
    game g ON gv.game_id = g.game_id;

/*Task 5: Show all unsold digital keys
Goal: Verify that unsold keys can be identified and filtered.
Display only digital keys where is_sold = FALSE, including game title and platform.*/

SELECT 
    d.key_code,
    g.title,
    gv.platform_name,
    CASE
        WHEN d.is_sold = 1 THEN 'Sold'
        ELSE 'Not Sold'
    END AS sale_status
FROM
    digitalkeys d
        JOIN
    gameversion gv ON d.version_id = gv.version_id
        JOIN
    game g ON gv.game_id = g.game_id
    WHERE d.is_sold = 0;

/*Task 6: Show purchase history for each customer
Goal: Verify customer–order relationship.
Display customer name, order date, total amount and cashback awarded.*/

SELECT 
    CONCAT(c.firstname, ' ', c.lastname) AS customer,
    o.order_datetime,
    o.total_amount,
    o.cashback_awarded
FROM
    orders o
        JOIN
    customer c ON o.customer_id = c.customer_id;

/*Task 7: Show detailed order contents
Goal: Verify that orders correctly link to purchased games and digital keys.
Display order ID, game title, platform, price at purchase and digital key code.*/

SELECT 
    oi.order_id,
    g.title,
    gv.platform_name,
    oi.price_at_purchase,
    d.key_code
FROM
    orderitems oi
JOIN
    digitalkeys d ON oi.digital_key_id = d.key_id
JOIN
    gameversion gv ON d.version_id = gv.version_id
JOIN
    game g ON gv.game_id = g.game_id;

/*Task 8: Find the most popular games by number of sales
Goal: Verify sales analytics using JOIN and GROUP BY.
Display game titles ordered by number of sold digital keys (descending).*/

SELECT 
    g.title,
    SUM(CASE
        WHEN d.is_sold = 1 THEN 1
        ELSE 0
    END) AS sales
FROM
    game g
        JOIN
    gameversion gv ON g.game_id = gv.game_id
        JOIN
    digitalkeys d ON gv.version_id = d.version_id
GROUP BY g.title
ORDER BY sales DESC;

/*Task 9: Show total revenue generated by each loyalty level
Goal: Verify business-level analytics.
Display loyalty level name and total revenue generated by customers in that level.*/

SELECT 
    l.name, SUM(o.total_amount) AS total_revenue
FROM
    orders o
        JOIN
    customer c ON o.customer_id = c.customer_id
        JOIN
    loyaltylevel l ON c.loyalty_level_id = l.level_id
GROUP BY l.name;

/*Task 10: Identify customers who earned the most cashback
Goal: Verify loyalty program effectiveness.
Display customer name and total cashback earned, ordered from highest to lowest.*/

SELECT 
    CONCAT(c.firstname, ' ', c.lastname) AS customer,
    SUM(o.cashback_awarded) AS total_cashback
FROM
    orders o
        JOIN
    customer c ON o.customer_id = c.customer_id
GROUP BY customer
ORDER BY total_cashback DESC;

/*Task 11: Show all customers including those without any orders
Goal: Verify LEFT JOIN functionality.
Ensure that customers who have not placed any orders are still displayed.
Display customer first name, last name, email, order ID and order total (if available).*/

SELECT 
    c.firstname,
    c.lastname,
    c.email,
    o.order_id,
    o.total_amount
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id;


/*Task 12: Show all games including those that have no digital keys
Goal: Verify RIGHT JOIN functionality.
Ensure that games are shown even if no digital keys have been generated or sold yet.
Display game title, platform name and digital key code (if available).*/

SELECT 
    g.title,
    gv.platform_name,
    d.key_code
FROM digitalkeys d
RIGHT JOIN gameversion gv ON d.version_id = gv.version_id
RIGHT JOIN game g ON gv.game_id = g.game_id;


/*Task 13: Combine sold and unsold digital keys into a single result set
Goal: Verify UNION functionality.
Ensure that data from multiple SELECT statements can be merged into one result.
Display digital key code and sale status.*/

SELECT 
    key_code,
    'Sold' AS sale_status
FROM digitalkeys
WHERE is_sold = 1

UNION ALL

SELECT 
    key_code,
    'Not Sold' AS sale_status
FROM digitalkeys
WHERE is_sold = 0;
















