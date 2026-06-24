/* =====================================================================================
   Proyecto: TechZone - End-to-End Data Engineering Pipeline
   Módulo: 01_create_tables.sql
   Autor: Iván Ravarotto
   Descripción: Define el esquema de la base de datos relacional bajo la 3FN 
                (Tercera Forma Normal). Crea las tablas principales de la lógica 
                de negocio: CLIENT, PRODUCT, SALE y SALE_DETAIL.
   ===================================================================================== */

-- Creación de la base de datos si no existe y selección de la misma
CREATE DATABASE IF NOT EXISTS TechZone;
USE TechZone;

-- =====================================================================================
-- TABLA: CLIENT (Información de Clientes)
-- =====================================================================================
CREATE TABLE IF NOT EXISTS CLIENT (
    client_id INT AUTO_INCREMENT PRIMARY KEY, -- ID autoincremental único para cada cliente
    client_name VARCHAR(100) NOT NULL,        -- Nombre obligatorio
    client_lastname VARCHAR(100) NOT NULL,    -- Apellido obligatorio
    client_email VARCHAR(100) UNIQUE NOT NULL,-- Email obligatorio y único (evita registros duplicados)
    client_number VARCHAR(20)                 -- Teléfono de contacto (opcional)
);

-- =====================================================================================
-- TABLA: PRODUCT (Catálogo de Productos)
-- =====================================================================================
CREATE TABLE IF NOT EXISTS PRODUCT (
    product_id INT AUTO_INCREMENT PRIMARY KEY,     -- ID autoincremental único para cada producto
    product_name VARCHAR(150) NOT NULL UNIQUE,     -- Nombre único comercial del producto
    product_price DECIMAL(10, 2) NOT NULL,         -- Usamos DECIMAL para precisión financiera exacta
    product_stock INT NOT NULL DEFAULT 0,          -- Stock disponible (por defecto inicia en 0)
    product_datetime DATETIME DEFAULT CURRENT_TIMESTAMP -- Fecha de auditoría de inserción/cambio
);

-- =====================================================================================
-- TABLA: SALE (Encabezado de Ventas / Factura)
-- =====================================================================================
CREATE TABLE IF NOT EXISTS SALE (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,        -- Número de transacción/factura único
    client_id INT NOT NULL,                        -- Cliente que realiza la compra (Relación FK)
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,  -- Fecha y hora exacta de la compra
    sale_total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,-- Monto total de la venta (precisión decimal)
    -- Definición de Llave Foránea para asegurar la Integridad Referencial
    FOREIGN KEY (client_id) REFERENCES CLIENT(client_id) ON DELETE RESTRICT
);

-- =====================================================================================
-- TABLA: SALE_DETAIL (Detalle de cada Producto en la Venta)
-- =====================================================================================
CREATE TABLE IF NOT EXISTS SALE_DETAIL (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,      -- ID único para cada línea de la factura
    sale_id INT NOT NULL,                          -- Relación con la cabecera de la venta
    product_id INT NOT NULL,                       -- Relación con el producto vendido
    quantity INT NOT NULL CHECK (quantity > 0),    -- Validación: No se permiten ventas de 0 o cantidades negativas
    unit_price DECIMAL(10, 2) NOT NULL,            -- Precio histórico al que se vendió en ese instante
    -- Restricciones de Llaves Foráneas
    FOREIGN KEY (sale_id) REFERENCES SALE(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id) ON DELETE RESTRICT
);