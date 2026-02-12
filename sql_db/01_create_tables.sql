DROP DATABASE IF EXISTS TechZone;
CREATE DATABASE TechZone;
USE TechZone;

CREATE TABLE `CLIENT` (
	client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100),
    client_lastname VARCHAR(100),
    client_email VARCHAR(100),
    client_number VARCHAR(20)
);

CREATE TABLE SALE(
	sale_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_client_id INT,
    foreign key (fk_client_id) REFERENCES `CLIENT`(client_id),
    sale_datetime DATETIME
);

CREATE TABLE PRODUCT(
	product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    product_stock INT,
    product_price DECIMAL(10,2),
	product_datetime DATETIME
);


CREATE TABLE SALE_DETAIL(
	detail_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_product_id INT,
    fk_sale_id INT,
    FOREIGN KEY (fk_product_id) REFERENCES PRODUCT(product_id),
    FOREIGN KEY (fk_sale_id) REFERENCES SALE(sale_id),
    purchase_quantity INT,
    purchase_unit_price DECIMAL(10,2),
    UNIQUE (fk_product_id, fk_sale_id)
);

CREATE TABLE AUDIT_PRICE(
	audit_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_product_id INT,
    FOREIGN KEY (fk_product_id) REFERENCES PRODUCT(product_id),
    audit_new_price DECIMAL(10,2),
    audit_old_price DECIMAL(10,2),
    change_date DATETIME
);