--1. Row Counts for all Tables
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL

SELECT 'orders', COUNT(*) FROM orders
UNION ALL

SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL 

SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL

SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL

SELECT 'products', COUNT(*) FROM products
UNION ALL 

SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL

SELECT 'product_category_translation', COUNT(*) FROM product_category_translation;

--2. Verify Orders Match Customers

SELECT COUNT(*) AS matching_orders_customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

--3. Order Status Distribution
SELECT order_status, COUNT(*) AS order_count, 
ROUND (100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC; 

--4. Missing delivery dates
SELECT COUNT(*) AS total_orders, 
COUNT(order_delivered_customer_date) AS delivered_orders, 
COUNT(*)  - COUNT(order_delivered_customer_date) AS missing_delivery_dates
FROM orders;

--5. Missing Estimated Delivery Dates
SELECT COUNT(*) AS total_orders, 
COUNT(order_estimated_delivery_date) AS estimated_delivery_dates_present, 
COUNT(*) - COUNT(order_estimated_delivery_date) AS missing_estimated_delivery_dates
FROM orders;

--6. Review Score Distribution
SELECT review_score, COUNT(*) AS review_count, 
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score; 

--7. Duplicate Customer Unique IDs
SELECT customer_unique_id, COUNT(*) AS occurrences
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;  

--8. Product Categoriess with Missing Names
SELECT COUNT(*) AS missing_category_names
FROM products
WHERE product_category_name IS NULL;

--9 Orders Missing Customer Records
SELECT COUNT(*) AS orders_without_customer
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--10 Order items Missing Product Records
SELECT COUNT(*) AS order_items_without_product
FROM order_items oi 
LEFT JOIN products p 
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 11. Order items Missing Seller Records
SELECT COUNT(*) AS order_items_without_seller
FROM order_items oi
LEFT JOIN sellers s 
ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 12. Earliest and Latest Order Dates
SELECT MIN(order_purchase_timestamp) AS earliest_order_date, 
MAX(order_purchase_timestamp) AS latest_order_date
FROM orders; 

-- 13. Earliest and Latest Review Dates
SELECT MIN(review_creation_date) AS earliest_review_date, 
MAX(review_creation_date) AS latest_review_date
FROM order_reviews;

-- 14. Average Review Score
SELECT ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews;

-- 15. Payment Method Distribution
SELECT payment_type, COUNT(*) AS payment_count, 
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_payments
FROM order_payments
GROUP BY payment_type
ORDER BY COUNT(*) DESC; 









