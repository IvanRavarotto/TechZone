/* =====================================================================================
   Proyecto: TechZone - End-to-End Data Engineering Pipeline
   Módulo: 02_triggers.sql
   Autor: Iván Ravarotto
   Descripción: Implementa disparadores (triggers) de auditoría para registrar 
                automáticamente los cambios históricos en los precios de los productos 
                y mantener la consistencia financiera.
   ===================================================================================== */

USE TechZone;

-- =====================================================================================
-- 1. LIMPIEZA PREVENTIVA (Idempotencia)
-- Eliminamos el trigger si ya existe para evitar errores al redesplegar el script.
-- =====================================================================================
DROP TRIGGER IF EXISTS after_product_price_update;

DELIMITER $$

-- =====================================================================================
-- 2. DEFINICIÓN DEL TRIGGER: Auditoría de actualización de precios
-- =====================================================================================
CREATE TRIGGER after_product_price_update
AFTER UPDATE ON PRODUCT
FOR EACH ROW
BEGIN
    -- Lógica de negocio: Solo escribimos en el log de auditoría SI el precio realmente cambió.
    -- Esto evita saturar (spamear) la tabla de logs si lo único que se actualizó fue el stock o el nombre.
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

-- =====================================================================================
-- ZONA DE PRUEBAS QA (Quality Assurance)
-- Descomentar estas líneas únicamente para verificación manual en entorno de desarrollo.
-- =====================================================================================
-- UPDATE PRODUCT SET product_price = 899.99 WHERE product_id = 21;
-- SELECT * FROM AUDIT_PRICE ORDER BY change_date DESC;