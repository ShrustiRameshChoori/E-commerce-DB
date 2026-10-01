-- ============================================================
-- E-commerce DB | Sample data (includes deliberate NULLs / edge cases)
-- ============================================================
USE ecommerce_db;

INSERT INTO customers (first_name,last_name,email,phone,city,country,signup_date) VALUES
('Aarav','Sharma','aarav@mail.com','9800000001','Bengaluru','India','2025-06-01'),
('Meera','Iyer','meera@mail.com',NULL,'Chennai','India','2025-06-15'),
('Rohan','Verma','rohan@mail.com','9800000003','Delhi','India','2025-07-02'),
('Sneha','Kulkarni','sneha@mail.com','9800000004','Pune','India','2025-07-20'),
('Karan','Mehta','karan@mail.com',NULL,NULL,'India','2025-08-05'),
('Emma','Wilson','emma@mail.com','4400000006','London','UK','2025-08-18'),
('Liam','Carter','liam@mail.com','1200000007','Toronto','Canada','2025-09-01'),
('Priya','Nair','priya@mail.com','9800000008','Kochi','India','2025-09-12'),
('Noah','Brown','noah@mail.com',NULL,'New York','USA','2025-10-03'),
('Ishaan','Gupta','ishaan@mail.com','9800000010','Mumbai','India','2025-10-21'),
('Ananya','Reddy','ananya@mail.com','9800000011','Hyderabad','India','2025-11-09'),
('Zoya','Khan','zoya@mail.com',NULL,'Lucknow','India','2025-12-01');   -- never orders

INSERT INTO products (product_name,category,price,stock_quantity) VALUES
('Gaming Laptop','Electronics',85000.00,12),
('Smartphone Z','Electronics',32000.00,25),
('Bluetooth Earbuds','Electronics',3500.00,80),
('Smart Watch','Electronics',7500.00,5),
('Office Chair','Furniture',9500.00,18),
('Study Desk','Furniture',6800.00,0),
('Mixer Grinder','Appliances',4200.00,30),
('Air Fryer','Appliances',6500.00,9),
('Running Shoes','Apparel',3200.00,45),
('Denim Jacket','Apparel',2800.00,3),
('Yoga Mat','Sports',900.00,60),
('Cricket Bat','Sports',2400.00,14),
('Backpack','Accessories',1800.00,0),
('Mystery Box',NULL,500.00,100);   -- uncategorised, never ordered

INSERT INTO orders (customer_id,order_date,order_status,payment_method,shipping_city) VALUES
(1,'2025-10-05','Completed','Credit Card','Bengaluru'),
(2,'2025-10-12','Completed','UPI','Chennai'),
(3,'2025-10-20','Completed','Debit Card','Delhi'),
(1,'2025-11-02','Completed','UPI','Bengaluru'),
(4,'2025-11-08','Cancelled','Credit Card','Pune'),
(6,'2025-11-15','Completed','PayPal','London'),
(7,'2025-11-22','Shipped','Credit Card','Toronto'),
(8,'2025-12-01','Completed','UPI','Kochi'),
(10,'2025-12-05','Completed','Credit Card','Mumbai'),
(5,'2025-12-10','Pending',NULL,NULL),
(9,'2025-12-18','Completed','PayPal','New York'),
(3,'2026-01-04','Completed','UPI','Delhi'),
(11,'2026-01-11','Completed','Debit Card','Hyderabad'),
(1,'2026-01-19','Shipped','UPI','Bengaluru'),
(2,'2026-02-03','Cancelled','UPI','Chennai'),
(10,'2026-02-09','Completed','Credit Card','Mumbai'),
(6,'2026-02-17','Completed','PayPal','London'),
(8,'2026-02-25','Pending','UPI','Kochi'),
(4,'2026-03-06','Completed','Debit Card','Pune'),
(11,'2026-03-14','Completed',NULL,'Hyderabad');

INSERT INTO order_items (order_id,product_id,quantity,unit_price,discount_pct) VALUES
(1,1,1,85000.00,5.00),(1,3,2,3500.00,0.00),
(2,5,1,9500.00,10.00),(2,11,2,900.00,0.00),
(3,2,1,32000.00,8.00),
(4,4,1,7500.00,0.00),(4,9,1,3200.00,15.00),
(5,7,1,4200.00,0.00),
(6,2,1,32000.00,0.00),(6,3,1,3500.00,10.00),
(7,8,1,6500.00,0.00),(7,12,1,2400.00,5.00),
(8,7,2,4200.00,0.00),(8,11,3,900.00,5.00),
(9,1,1,85000.00,10.00),(9,4,1,7500.00,0.00),
(10,10,2,2800.00,0.00),
(11,5,2,9500.00,5.00),(11,9,1,3200.00,0.00),
(12,3,3,3500.00,12.00),
(13,8,1,6500.00,10.00),(13,11,2,900.00,0.00),
(14,2,1,32000.00,5.00),
(15,9,2,3200.00,0.00),
(16,3,1,3500.00,0.00),(16,12,2,2400.00,0.00),
(17,4,1,7500.00,5.00),
(18,7,1,4200.00,0.00),
(19,5,1,9500.00,0.00),(19,3,1,3500.00,0.00),
(20,1,1,85000.00,0.00),(20,9,2,3200.00,10.00);
