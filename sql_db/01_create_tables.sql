-- Script: 01_create_tables.sql
-- Description: DDL script for initial TechZone database schema setup.
--              Defines Master Data, Transactional Tables, and Audit structures.
-- Author: Ivan Ravarotto
-- Date: 2026-02-14

-- 1. INITIAL SETUP
-- Drop database if exists to ensure a clean slate for testing/deployment
DROP DATABASE IF EXISTS TechZone;
CREATE DATABASE TechZone;
USE TechZone;

-- =============================================
-- SECTION 1: MASTER DATA TABLES
-- Core entities that do not depend on other tables.
-- =============================================

-- Table: CLIENTS
CREATE TABLE CLIENT (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100),
    client_lastname VARCHAR(100),
    client_email VARCHAR(100),
    client_number VARCHAR(20)
);

-- Table: PRODUCTS
CREATE TABLE PRODUCT (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    product_stock INT,
    product_price DECIMAL(10,2), -- DECIMAL is critical for financial data (prevents float rounding errors)
    product_datetime DATETIME
);

-- =============================================
-- SECTION 2: TRANSACTIONAL TABLES
-- Tables that record business events (Sales).
-- =============================================

-- Table: SALE HEADER (The Ticket)
CREATE TABLE SALE (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_client_id INT,
    sale_datetime DATETIME,
    -- Relationship: A sale belongs to one client
    FOREIGN KEY (fk_client_id) REFERENCES CLIENT(client_id)
);

-- Table: SALE DETAIL (Ticket Items)
CREATE TABLE SALE_DETAIL (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_product_id INT,
    fk_sale_id INT,
    purchase_quantity INT,
    purchase_unit_price DECIMAL(10,2), -- Price frozen at the moment of sale
    
    -- Relationships
    FOREIGN KEY (fk_product_id) REFERENCES PRODUCT(product_id),
    FOREIGN KEY (fk_sale_id) REFERENCES SALE(sale_id),
    
    -- Business Rule: A product cannot appear twice in the same sale ID (quantities should be summed instead)
    UNIQUE (fk_product_id, fk_sale_id)
);

-- =============================================
-- SECTION 3: AUDIT TABLES
-- Security and historical tracking tables.
-- =============================================

-- Table: PRICE AUDIT
CREATE TABLE AUDIT_PRICE (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_product_id INT,
    audit_new_price DECIMAL(10,2),
    audit_old_price DECIMAL(10,2),
    change_date DATETIME,
    
    FOREIGN KEY (fk_product_id) REFERENCES PRODUCT(product_id)
);