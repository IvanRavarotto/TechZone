-- Script: 02_triggers.sql
-- Description: Automated trigger to audit product price changes.
--              Captures old and new prices with a timestamp.
-- Author: Ivan Ravarotto
-- Date: 2026-02-14

USE TechZone;

-- 1. Preventive Cleanup: Drop trigger if exists to avoid conflicts during redeployment.
DROP TRIGGER IF EXISTS after_product_price_update;

DELIMITER $$

-- 2. Trigger Definition
CREATE TRIGGER after_product_price_update
AFTER UPDATE ON PRODUCT
FOR EACH ROW
BEGIN
    -- Logic: Only write to audit log IF the price actually changed.
    -- This avoids spamming the log if only stock or name is updated.
    IF NEW.product_price <> OLD.product_price THEN
        
        INSERT INTO AUDIT_PRICE (
            fk_product_id, 
            audit_new_price, 
            audit_old_price, 
            change_date
        )
        VALUES (
            OLD.product_id, 
            NEW.product_price, 
            OLD.product_price, 
            NOW()
        );
        
    END IF;
END$$

DELIMITER ;

-- =============================================
-- TESTING ZONE (MANUAL QA)
-- Uncomment these lines only for manual verification
-- =============================================
-- UPDATE PRODUCT SET product_price = 899.99 WHERE product_id = 21;
-- SELECT * FROM audit_price ORDER BY change_date DESC;