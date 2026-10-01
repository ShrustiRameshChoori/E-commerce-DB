-- ============================================================
-- E-commerce DB | Schema (MySQL 8.0+)
-- ============================================================
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE customers (
    customer_id  INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(20)  DEFAULT NULL,
    city         VARCHAR(50)  DEFAULT NULL,
    country      VARCHAR(50)  NOT NULL DEFAULT 'India',
    signup_date  DATE         NOT NULL
);

CREATE TABLE products (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50)  DEFAULT NULL,
    price           DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity  INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    order_date      DATE NOT NULL,
    order_status    VARCHAR(20) NOT NULL
                    CHECK (order_status IN ('Completed','Shipped','Pending','Cancelled')),
    payment_method  VARCHAR(30) DEFAULT NULL,
    shipping_city   VARCHAR(50) DEFAULT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_item_id  INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL CHECK (quantity > 0),
    unit_price     DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    discount_pct   DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (discount_pct BETWEEN 0 AND 100),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id)     ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Indexes for common join / filter columns
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date     ON orders(order_date);
CREATE INDEX idx_items_order     ON order_items(order_id);
CREATE INDEX idx_items_product   ON order_items(product_id);

-- Reusable view: net line value after discount
CREATE VIEW v_order_lines AS
SELECT oi.order_item_id, oi.order_id, oi.product_id, oi.quantity, oi.unit_price,
       oi.discount_pct,
       ROUND(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100), 2) AS line_total
FROM order_items oi;
