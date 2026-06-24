/* =====================================================================================
   Proyecto: TechZone - End-to-End Data Engineering Pipeline
   Módulo: 03_stored_procedures.sql
   Autor: Iván Ravarotto
   Descripción: Procedimiento Almacenado (Stored Procedure) para la generación de
                datos sintéticos (ventas ficticias). Facilita las pruebas de estrés,
                QA (Quality Assurance) y la validación del modelo de Power BI.
   ===================================================================================== */

USE TechZone;

-- =====================================================================================
-- 1. LIMPIEZA PREVENTIVA (Idempotencia)
-- =====================================================================================
DROP PROCEDURE IF EXISTS simulate_sales;

DELIMITER //

-- =====================================================================================
-- 2. DEFINICIÓN DEL PROCEDIMIENTO ALMACENADO
-- Parámetro de entrada: num_sales (Cantidad de ventas a simular)
-- =====================================================================================
CREATE PROCEDURE simulate_sales(IN num_sales INT)
BEGIN
    -- Declaración de variables de control
    DECLARE i INT DEFAULT 0;
    DECLARE random_client_id INT;
    DECLARE last_sale_id INT;
    DECLARE random_product_id INT;
    DECLARE random_qty INT;
    
    -- Nota Arquitectónica: Usamos el prefijo 'v_' para la variable del precio
    -- para evitar una colisión de nombres (Ambigüedad) con la columna real de la tabla.
    DECLARE v_product_price DECIMAL(10,2); 
    
    -- =================================================================================
    -- BUCLE PRINCIPAL: Generación masiva de transacciones
    -- =================================================================================
    WHILE i < num_sales DO
        
        -- Paso 1: Seleccionar un cliente aleatorio que YA EXISTA (Integridad Referencial)
        SELECT client_id INTO random_client_id 
        FROM CLIENT 
        ORDER BY RAND() 
        LIMIT 1;

        -- Paso 2: Crear la cabecera de la venta (Factura)
        -- Genera una fecha aleatoria dentro de los últimos 60 días
        INSERT INTO SALE (client_id, sale_date) 
        VALUES (random_client_id, NOW() - INTERVAL FLOOR(RAND() * 60) DAY);
        
        -- Capturar el ID de la factura recién generada
        SET last_sale_id = LAST_INSERT_ID();

        -- Paso 3: Buscar un producto aleatorio y capturar su precio actual
        SELECT product_id, product_price 
        INTO random_product_id, v_product_price 
        FROM PRODUCT 
        ORDER BY RAND() 
        LIMIT 1;
        
        -- Generar una cantidad de compra lógica (Entre 1 y 3 unidades)
        SET random_qty = FLOOR(1 + RAND() * 3);
        
        -- Paso 4: Insertar el registro final del detalle de venta
        -- Guardamos el 'v_product_price' como histórico en la factura.
        INSERT INTO SALE_DETAIL (sale_id, product_id, quantity, unit_price)
        VALUES (last_sale_id, random_product_id, random_qty, v_product_price);
        
        -- Avanzar el contador del bucle
        SET i = i + 1;
        
    END WHILE;
END //

DELIMITER ;

-- =====================================================================================
-- ZONA DE EJECUCIÓN Y PRUEBAS
-- Descomentar estas líneas para simular 50 ventas y comprobar resultados:
-- =====================================================================================
-- CALL simulate_sales(50);
-- SELECT * FROM SALE;
-- SELECT * FROM SALE_DETAIL;