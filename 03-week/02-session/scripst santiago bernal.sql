-- =========================================
-- EJERCICIO 8: Rentabilidad por Categoría de Producto
-- Archivo único: creación, datos de prueba y consulta
-- =========================================

-- 1️⃣ Crear base de datos y usarla
CREATE DATABASE IF NOT EXISTS product_finance;
USE product_finance;

-- 2️⃣ Crear tablas

-- Categoría de producto
CREATE TABLE product_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

-- Producto
CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(50),
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    status ENUM('active','inactive') NOT NULL,
    FOREIGN KEY (category_id) REFERENCES product_category(id)
);

-- Factura
CREATE TABLE bill (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('issued','paid','cancelled') NOT NULL
);

-- Detalle de factura
CREATE TABLE bill_detail (
    bill_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    FOREIGN KEY (bill_id) REFERENCES bill(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

-- 3️⃣ Insertar datos de prueba

INSERT INTO product_category (name) VALUES
('Electrónica'), ('Ropa'), ('Hogar');

INSERT INTO product (category_id, name, price, cost, status) VALUES
(1,'Televisor', 500.00, 400.00, 'active'),
(1,'Laptop', 1000.00, 800.00, 'active'),
(2,'Camisa', 50.00, 30.00, 'active'),
(2,'Pantalón', 70.00, 40.00, 'active'),
(3,'Lámpara', 30.00, 15.00, 'active');

INSERT INTO bill (status) VALUES
('paid'),('paid'),('paid');

INSERT INTO bill_detail (bill_id, product_id, quantity, unit_price, discount) VALUES
(1,1,2,500.00,50.00),
(1,2,1,1000.00,100.00),
(2,3,5,50.00,25.00),
(2,4,2,70.00,10.00),
(3,5,3,30.00,0.00);

-- 4️⃣ Consulta final: Rentabilidad por categoría

SELECT
    pc.name AS category_name,
    COUNT(DISTINCT p.id) AS active_products,
    SUM(bd.quantity) AS total_units_sold,
    ROUND(SUM(bd.unit_price * bd.quantity),2) AS gross_income,
    ROUND(SUM(bd.discount),2) AS total_discounts,
    ROUND(SUM(bd.unit_price * bd.quantity) - SUM(bd.discount),2) AS net_income,
    ROUND(AVG(((bd.unit_price - p.cost)/bd.unit_price)*100),2) AS avg_margin_percent,
    
    -- Producto más rentable por margen
    (SELECT p2.name
     FROM product p2
     INNER JOIN bill_detail bd2 ON p2.id = bd2.product_id
     INNER JOIN bill b2 ON bd2.bill_id = b2.id
     WHERE p2.category_id = pc.id
       AND p2.status='active'
       AND b2.status='paid'
     ORDER BY ((bd2.unit_price - p2.cost)/bd2.unit_price) DESC
     LIMIT 1
    ) AS top_product

FROM product_category pc

INNER JOIN product p ON p.category_id = pc.id AND p.status='active'
INNER JOIN bill_detail bd ON bd.product_id = p.id
INNER JOIN bill b ON b.id = bd.bill_id AND b.status='paid'

GROUP BY pc.id, pc.name
ORDER BY net_income DESC;
