-- Script: 03_stored_procedures.sql
-- Description: Stored Procedure to generate simulated sales data.
--              Updated to robustly select existing IDs (ignoring gaps).
-- Author: Ivan Ravarotto
-- Date: 2026-02-14

USE TechZone;

DROP PROCEDURE IF EXISTS simulate_sales;

DELIMITER //

CREATE PROCEDURE simulate_sales(IN num_sales INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE random_client_id INT;
    DECLARE last_sale_id INT;
    DECLARE random_product_id INT;
    DECLARE random_qty INT;
    DECLARE product_price DECIMAL(10,2);
    
    -- Loop: Generate 'num_sales' transactions
    WHILE i < num_sales DO
        
        -- =======================================================
        -- 1. Select a random REAL Client
        -- =======================================================
        -- Instead of guessing numbers, we ask the table for an existing ID.
        -- This prevents errors if ID 1 was deleted or if there are gaps.
        SELECT client_id INTO random_client_id 
        FROM CLIENT 
        ORDER BY RAND() 
        LIMIT 1;

        -- 2. Create Sale Header (Simulating dates from the last 60 days)
        INSERT INTO SALE (fk_client_id, sale_datetime) 
        VALUES (random_client_id, NOW() - INTERVAL FLOOR(RAND() * 60) DAY);
        
        SET last_sale_id = LAST_INSERT_ID();

        -- =======================================================
        -- 3. Add Sale Detail (Random REAL Product)
        -- =======================================================
        -- We do the same for products: select one that is guaranteed to exist.
        SELECT product_id, product_price 
        INTO random_product_id, product_price 
        FROM PRODUCT 
        ORDER BY RAND() 
        LIMIT 1;
        
        -- Select quantity (1 to 3 units)
        SET random_qty = FLOOR(1 + RAND() * 3);
        
        -- Insert Detail
        -- We use IGNORE in case chance selects the same product twice for the same sale (rare but possible)
        INSERT IGNORE INTO SALE_DETAIL (fk_product_id, fk_sale_id, purchase_quantity, purchase_unit_price)
        VALUES (random_product_id, last_sale_id, random_qty, product_price);

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;