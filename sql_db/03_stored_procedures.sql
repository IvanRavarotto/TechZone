-- Script: 03_stored_procedures.sql
-- Description: Stored Procedure to generate simulated sales data.
--              FIX: Renamed local variable to avoid column name conflict (NULL price issue).
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
    
    -- FIX: We changed the name to 'v_product_price' to distinguish it from the table column
    DECLARE v_product_price DECIMAL(10,2); 
    
    -- Loop: Generate 'num_sales' transactions
    WHILE i < num_sales DO
        
        -- 1. Select a random REAL Client
        SELECT client_id INTO random_client_id 
        FROM CLIENT 
        ORDER BY RAND() 
        LIMIT 1;

        -- 2. Create Sale Header
        INSERT INTO SALE (fk_client_id, sale_datetime) 
        VALUES (random_client_id, NOW() - INTERVAL FLOOR(RAND() * 60) DAY);
        
        SET last_sale_id = LAST_INSERT_ID();

        -- 3. Add Sale Detail (Random REAL Product)
        -- We select the column 'product_price' and save it into variable 'v_product_price'
        SELECT product_id, product_price 
        INTO random_product_id, v_product_price 
        FROM PRODUCT 
        ORDER BY RAND() 
        LIMIT 1;
        
        -- Select quantity (1 to 3 units)
        SET random_qty = FLOOR(1 + RAND() * 3);
        
        -- Insert Detail using the variable
        INSERT IGNORE INTO SALE_DETAIL (fk_product_id, fk_sale_id, purchase_quantity, purchase_unit_price)
        VALUES (random_product_id, last_sale_id, random_qty, v_product_price);

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;