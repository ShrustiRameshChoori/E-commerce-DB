-- ============================================================
-- E-commerce DB | Analysis queries (MySQL 8.0+)
-- Net line value = quantity * unit_price * (1 - discount_pct/100)  -> view v_order_lines
-- Revenue counts only 'Completed' orders unless stated.
-- ============================================================
USE ecommerce_db;

-- ---------- SECTION A: Basic SELECT / WHERE / ORDER BY ----------
-- A1. Customers sorted by last name
SELECT customer_id, first_name, last_name, city FROM customers ORDER BY last_name;

-- A2. Low-stock products (< 10)
SELECT product_name, stock_quantity FROM products WHERE stock_quantity < 10 ORDER BY stock_quantity;

-- A3. Orders placed in January 2026
SELECT * FROM orders WHERE order_date >= '2026-01-01' AND order_date < '2026-02-01';

-- A4. Distinct order statuses
SELECT DISTINCT order_status FROM orders;

-- A5. Customers whose first name starts with A or P
SELECT first_name, last_name FROM customers WHERE first_name LIKE 'A%' OR first_name LIKE 'P%';

-- A6. Products priced between 3000 and 10000
SELECT product_name, price FROM products WHERE price BETWEEN 3000 AND 10000 ORDER BY price DESC;

-- ---------- SECTION B: NULL handling ----------
-- B1. Customers without a phone number
SELECT first_name, last_name, email FROM customers WHERE phone IS NULL;

-- B2. Orders missing payment method or shipping city
SELECT order_id, customer_id, order_status FROM orders
WHERE payment_method IS NULL OR shipping_city IS NULL;

-- B3. COALESCE: phone fallback
SELECT first_name, COALESCE(phone, 'N/A') AS contact FROM customers;

-- B4. COALESCE: uncategorised products
SELECT product_name, COALESCE(category, 'Unassigned') AS category FROM products;

-- B5. Orders per payment method (NULL shown as 'Unknown')
SELECT COALESCE(payment_method, 'Unknown') AS payment_method, COUNT(*) AS total_orders
FROM orders GROUP BY COALESCE(payment_method, 'Unknown') ORDER BY total_orders DESC;

-- ---------- SECTION C: JOINs ----------
-- C1. INNER JOIN: orders with customer names
SELECT o.order_id, CONCAT(c.first_name,' ',c.last_name) AS customer, o.order_date, o.order_status
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_date;

-- C2. LEFT JOIN: order count per customer (incl. zero)
SELECT c.customer_id, c.first_name, COUNT(o.order_id) AS total_orders
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name ORDER BY total_orders DESC;

-- C3. Customers who never ordered
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- C4. Products never ordered
SELECT p.product_id, p.product_name
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- C5. Four-table join: full order breakdown
SELECT o.order_id, c.first_name, p.product_name, l.quantity, l.unit_price, l.discount_pct, l.line_total
FROM v_order_lines l
JOIN orders    o ON o.order_id   = l.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products  p ON p.product_id  = l.product_id
ORDER BY o.order_id;

-- ---------- SECTION D: Aggregations & business metrics ----------
-- D1. Total revenue (Completed)
SELECT SUM(l.line_total) AS total_revenue
FROM v_order_lines l JOIN orders o ON o.order_id = l.order_id
WHERE o.order_status = 'Completed';

-- D2. Revenue by status (shows what is lost / pending)
SELECT o.order_status, COUNT(DISTINCT o.order_id) AS orders, SUM(l.line_total) AS value
FROM orders o JOIN v_order_lines l ON l.order_id = o.order_id
GROUP BY o.order_status;

-- D3. Average order value (Completed)
SELECT ROUND(AVG(t.order_total),2) AS avg_order_value FROM (
    SELECT o.order_id, SUM(l.line_total) AS order_total
    FROM orders o JOIN v_order_lines l ON l.order_id = o.order_id
    WHERE o.order_status = 'Completed' GROUP BY o.order_id) t;

-- D4. Revenue by country
SELECT c.country, SUM(l.line_total) AS revenue
FROM customers c JOIN orders o ON o.customer_id = c.customer_id
JOIN v_order_lines l ON l.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.country ORDER BY revenue DESC;

-- D5. Revenue by category
SELECT COALESCE(p.category,'Unassigned') AS category, SUM(l.quantity) AS units, SUM(l.line_total) AS revenue
FROM v_order_lines l JOIN orders o ON o.order_id = l.order_id
JOIN products p ON p.product_id = l.product_id
WHERE o.order_status = 'Completed'
GROUP BY COALESCE(p.category,'Unassigned') ORDER BY revenue DESC;

-- D6. Top 3 products by units sold
SELECT p.product_name, SUM(l.quantity) AS units_sold
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
JOIN orders o ON o.order_id = l.order_id AND o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name ORDER BY units_sold DESC LIMIT 3;

-- D7. Top customers by spend
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer, SUM(l.line_total) AS total_spent
FROM customers c JOIN orders o ON o.customer_id = c.customer_id
JOIN v_order_lines l ON l.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, customer ORDER BY total_spent DESC LIMIT 5;

-- D8. Customer tiers with CASE
SELECT c.first_name, SUM(l.line_total) AS total_spent,
       CASE WHEN SUM(l.line_total) >= 50000 THEN 'Platinum'
            WHEN SUM(l.line_total) >= 10000 THEN 'Gold'
            ELSE 'Silver' END AS tier
FROM customers c JOIN orders o ON o.customer_id = c.customer_id
JOIN v_order_lines l ON l.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.first_name ORDER BY total_spent DESC;

-- D9. Cancellation rate %
SELECT ROUND(100 * SUM(order_status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_pct FROM orders;

-- D10. Products sold in more than one order (HAVING)
SELECT p.product_name, COUNT(DISTINCT l.order_id) AS in_orders
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
GROUP BY p.product_id, p.product_name HAVING COUNT(DISTINCT l.order_id) > 1
ORDER BY in_orders DESC;

-- D11. Monthly revenue + total discount given
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
       SUM(l.line_total) AS revenue,
       SUM(l.quantity * l.unit_price - l.line_total) AS discount_given
FROM orders o JOIN v_order_lines l ON l.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') ORDER BY month;

-- ---------- SECTION E: Subqueries, CTEs, Window functions ----------
-- E1. Products priced above average
SELECT product_name, price FROM products WHERE price > (SELECT AVG(price) FROM products);

-- E2. Customers with above-average order count
SELECT customer_id, COUNT(*) AS n FROM orders GROUP BY customer_id
HAVING COUNT(*) > (SELECT AVG(cnt) FROM (SELECT COUNT(*) cnt FROM orders GROUP BY customer_id) x);

-- E3. Price rank inside each category (DENSE_RANK)
SELECT category, product_name, price,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM products WHERE category IS NOT NULL;

-- E4. Running total of daily revenue (CTE + window)
WITH daily AS (
    SELECT o.order_date, SUM(l.line_total) AS revenue
    FROM orders o JOIN v_order_lines l ON l.order_id = o.order_id
    WHERE o.order_status = 'Completed' GROUP BY o.order_date)
SELECT order_date, revenue, SUM(revenue) OVER (ORDER BY order_date) AS running_revenue FROM daily;

-- E5. Top spender per country (CTE + ROW_NUMBER)
WITH spend AS (
    SELECT c.country, CONCAT(c.first_name,' ',c.last_name) AS customer, SUM(l.line_total) AS total_spent
    FROM customers c JOIN orders o ON o.customer_id = c.customer_id
    JOIN v_order_lines l ON l.order_id = o.order_id
    WHERE o.order_status = 'Completed' GROUP BY c.country, c.customer_id, customer),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rn FROM spend)
SELECT country, customer, total_spent FROM ranked WHERE rn = 1;

-- E6. Month-over-month revenue growth (LAG)
WITH m AS (
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month, SUM(l.line_total) AS revenue
    FROM orders o JOIN v_order_lines l ON l.order_id = o.order_id
    WHERE o.order_status = 'Completed' GROUP BY DATE_FORMAT(o.order_date,'%Y-%m'))
SELECT month, revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month), 2) AS mom_growth_pct
FROM m;

-- E7. Repeat customers (2+ completed orders) with days between first and last order
SELECT customer_id, COUNT(*) AS orders, MIN(order_date) AS first_order, MAX(order_date) AS last_order,
       DATEDIFF(MAX(order_date), MIN(order_date)) AS days_span
FROM orders WHERE order_status = 'Completed'
GROUP BY customer_id HAVING COUNT(*) >= 2;

-- E8. Restock alert: out-of-stock or low-stock products that actually sell
SELECT p.product_name, p.stock_quantity, SUM(l.quantity) AS units_sold
FROM products p JOIN v_order_lines l ON l.product_id = p.product_id
WHERE p.stock_quantity < 10 GROUP BY p.product_id, p.product_name, p.stock_quantity
ORDER BY units_sold DESC;
