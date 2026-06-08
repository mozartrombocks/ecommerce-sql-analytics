--1. Executive Overview KPI View
CREATE OR REPLACE VIEW dashboard_executive_kpis AS 
WITH revenue_metrics AS (
	SELECT 
		COUNT(DISTINCT order_id) AS delivered_orders, 
		SUM(total_order_value) AS total_revenue, 
		AVG(total_order_value) AS avg_order_value, 
		AVG(delivery_days) AS avg_delivery_days, 
		SUM(is_late_delivery) AS late_deliveries
	FROM vw_order_metrics
), 

review_metrics AS (
	SELECT 
		AVG(review_score) AS avg_review_score
	FROM order_reviews
), 

retention_metrics AS (
	SELECT 
		COUNT(*) AS total_customers, 
		SUM(is_repeat_customer) AS repeat_customers
	FROM vw_customer_retention
)

SELECT 
	ROUND(rm.total_revenue, 2) AS total_revenue, 
	rm.delivered_orders, 
	ROUND(rm.avg_order_value, 2) AS avg_order_value, 
	ROUND(rm.avg_delivery_days, 2) AS avg_delivery_days, 
	rm.late_deliveries, 
	ROUND(
		100.0 * rm.late_deliveries / rm.delivered_orders, 
		2
	) AS late_delivery_rate_percent, 
	ROUND(rv.avg_review_score, 2) AS avg_review_score, 
	rt.total_customers, 
	rt.repeat_customers, 
	ROUND(
		100.0 * rt.repeat_customers / rt.total_customers, 
		2
	) AS repeat_customers_rate_percent
FROM revenue_metrics rm 
CROSS JOIN review_metrics rv
CROSS JOIN retention_metrics rt; 

--2. Revenue Trend Dashboard View
CREATE OR REPLACE VIEW dashboard_revenue_trend AS 
SELECT 
	order_month, 
	ROUND(SUM(total_order_value), 2) AS monthly_revenue, 
	COUNT(DISTINCT order_id) AS monthly_orders, 
	ROUND(AVG(total_order_value), 2) AS avg_order_value
FROM vw_order_metrics
GROUP BY order_month
ORDER BY order_month; 

--3. Revenue by State Dashboard View
CREATE OR REPLACE VIEW dashboard_revenue_by_state AS 
SELECT 
	customer_state, 
	COUNT(DISTINCT order_id) AS total_orders, 
	ROUND(SUM(total_order_value), 2) AS revenue, 
	ROUND(AVG(total_order_value), 2) AS avg_order_value, 
	ROUND(
		100.0 * SUM(total_order_value) / 
		SUM(SUM(total_order_value)) OVER (),
		2
	) AS revenue_share_percent 
FROM vw_order_metrics
GROUP BY customer_state
ORDER BY revenue DESC; 

--4. Product Category Dashboard View
CREATE OR REPLACE VIEW dashboard_product_categories AS 
SELECT 
	category, 
	total_orders, 
	total_items_sold, 
	ROUND(revenue, 2) AS revenue, 
	ROUND(freight_revenue, 2) AS freight_revenue, 
	ROUND(avg_item_price, 2) AS avg_item_price, 
	ROUND(
		100.0 * revenue / SUM(revenue) OVER (), 
		2
	) AS revenue_share_percent, 
	ROUND(
		100.0 * freight_revenue / NULLIF(revenue, 0), 
		2
	) AS freight_to_revenue_percent
FROM vw_category_revenue
ORDER BY revenue DESC; 

--5. Customer Retention Dashboard View
CREATE OR REPLACE VIEW dashboard_customer_retention AS
SELECT 
	CASE
		WHEN is_repeat_customer = 1 THEN 'Repeat Customer'
		ELSE 'One-Time Customer'
	END AS customer_type, 
	COUNT(*) AS customer_count, 
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 
		2
	) AS customer_share_percent
FROM vw_customer_retention
GROUP BY customer_type; 

--6. Orders Per Customer Dashboard View

CREATE OR REPLACE VIEW dashboard_orders_per_customer AS
SELECT 
	total_orders,
	COUNT(*) AS customer_count, 
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 
		2
	) AS customer_share_percent
FROM vw_customer_retention
GROUP BY total_orders
ORDER BY total_orders; 

--7. New Customers by Month Dashboard View
CREATE OR REPLACE VIEW dashboard_new_customes_by_month AS 
WITH first_purchases AS (
	SELECT 
		customer_unique_id, 
		DATE_TRUNC('month', MIN(first_order_date)) AS first_purchase_month
	FROM vw_customer_retention
	GROUP BY customer_unique_id
)

SELECT 
	first_purchase_month, 
	COUNT(*) AS new_customers
FROM first_purchases
GROUP BY first_purchase_month
ORDER BY first_purchase_month;

--8. Cohort Retention Dashboard View
CREATE OR REPLACE VIEW dashboard_cohort_retention AS 
WITH customer_orders AS (
	SELECT 
		c.customer_unique_id, 
		DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
	FROM orders o   
	JOIN customers c  
		ON o.customer_id = c.customer_id 
	WHERE o.order_status = 'delivered'
), 

cohorts AS (
	SELECT 
		customer_unique_id, 
		MIN(order_month) AS cohort_month
	FROM customer_orders
	GROUP BY customer_unique_id
),

cohort_activity AS (
	SELECT 
		co.customer_unique_id, 
		c.cohort_month, 
		co.order_month, 
		(
			EXTRACT(YEAR FROM co.order_month) - 
			EXTRACT(YEAR FROM c.cohort_month)
		) * 12
		+
		(
			EXTRACT(MONTH FROM co.order_month) -
			EXTRACT(MONTH FROM c.cohort_month)
		) AS months_since_first_purchase
	FROM customer_orders co  
	JOIN cohorts c   
		ON co.customer_unique_id = c.customer_unique_id 
), 

cohort_counts AS (
	SELECT 
		cohort_month, 
		months_since_first_purchase,
		COUNT(DISTINCT customer_unique_id) AS active_customers
	FROM cohort_activity
	GROUP BY cohort_month, months_since_first_purchase
),

cohort_sizes AS (
	SELECT 
		cohort_month, 
		active_customers AS cohort_size
	FROM cohort_counts
	WHERE months_since_first_purchase = 0 
)

SELECT 
	cc.cohort_month, 
	cc.months_since_first_purchase, 
	cc.active_customers, 
	cs.cohort_size, 
	ROUND(
		100.0 * cc.active_customers / cs.cohort_size, 
		2
	) AS retention_percent
FROM cohort_counts cc    
JOIN cohort_sizes cs   
	ON cc.cohort_month = cs.cohort_month 
ORDER BY 
	cc.cohort_month, 
	cc.months_since_first_purchase; 


-- 9. Delivery Review Dashboard View
CREATE OR REPLACE VIEW dashboard_delivery_reviews AS 
SELECT 
	CASE 
		WHEN vom.is_late_delivery = 1 THEN 'Late Delivery'
		ELSE 'On-Time Delivery'
	END AS delivery_status, 
	COUNT(DISTINCT vom.order_id) AS total_orders, 
	ROUND(AVG(vom.delivery_days), 2) AS avg_delivery_days, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom
JOIN order_reviews r   
	ON vom.order_id = r.order_id
WHERE vom.delivery_days IS NOT NULL 
GROUP BY delivery_status; 


--10. Delivery Speed Dashboard View
CREATE OR REPLACE VIEW dashboard_delivery_speed_groups AS 
SELECT 
	CASE 
		WHEN vom.delivery_days <= 3 THEN '0-3 Days' 
		WHEN vom.delivery_days BETWEEN 4 AND 7 THEN '4-7 Days'
		WHEN vom.delivery_days BETWEEN 8 AND  14 THEN '8-14 Days'
		WHEN vom.delivery_days BETWEEN 15 AND 30 THEN '15-30 Days'
		ELSE '31+ Days'
	END AS delivery_speed_group, 
	COUNT(DISTINCT vom.order_id) AS total_orders, 
	ROUND(AVG(vom.delivery_days), 2) AS avg_delivery_days,
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom 
JOIN order_reviews r 
	ON vom.order_id = r.order_id 
WHERE vom.delivery_days IS NOT NULL 
GROUP BY delivery_speed_group 
ORDER BY MIN(vom.delivery_days); 

--11. Delivery by State Dashboard View
CREATE OR REPLACE VIEW dashboard_delivery_by_state AS 
SELECT 
	customer_state, 
	COUNT(DISTINCT order_id) AS delivered_orders, 
	ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
	SUM(is_late_delivery) AS late_deliveries, 
	ROUND(
		100.0 * SUM(is_late_delivery) / COUNT(DISTINCT order_id), 
		2 
	) AS late_delivery_rate_percent 
	FROM vw_order_metrics
	WHERE delivery_days IS NOT NULL 
	GROUP BY customer_state
	ORDER BY avg_delivery_days DESC; 

--12. Review Score Distribution Dashboard View
CREATE OR REPLACE VIEW dashboard_review_distribution AS
SELECT 
	review_score, 
	COUNT(*) AS review_count, 
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 
		2 
	) AS review_share_percent 
FROM order_reviews
GROUP BY review_score
ORDER BY review_score; 

--13. Seller Performance Dashboard View
CREATE OR REPLACE VIEW dashboard_seller_performance AS
SELECT 
	oi.seller_id, 
	s.seller_state, 
	COUNT(DISTINCT oi.order_id) AS total_orders, 
	COUNT(oi.order_item_id) AS total_items_sold, 
	ROUND(SUM(oi.price), 2) AS seller_revenue, 
	ROUND(AVG(oi.price), 2) AS avg_item_price, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi   
JOIN sellers s   
	ON oi.seller_id = s.seller_id 
JOIN orders o  
	ON oi.order_id = o.order_id 
LEFT JOIN order_reviews r    
	ON oi.order_id = r.order_id 
WHERE o.order_status = 'delivered'
GROUP BY 
	oi.seller_id, 
	s.seller_state
ORDER BY seller_revenue DESC; 

--14. Seller State Dashboard View
CREATE OR REPLACE VIEW dashboard_seller_state AS
SELECT 
	s.seller_state, 
	COUNT(DISTINCT s.seller_id) AS total_sellers, 
	COUNT(DISTINCT oi.order_id) AS total_orders,
	ROUND(SUM(oi.price), 2) AS seller_revenue, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi  
JOIN sellers s   
	ON oi.seller_id = s.seller_id 
JOIN orders o  
	ON oi.order_id = o.order_id 
LEFT JOIN order_reviews r   
	ON oi.order_id = r.order_id  
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY seller_revenue DESC; 

--15. Seller Revenue Concentration Dashboard View
CREATE OR REPLACE VIEW dashboard_seller_concentration AS 
WITH seller_revenue AS (
	SELECT 
		oi.seller_id, 
		SUM(oi.price) AS revenue, 
		RANK() OVER (
			ORDER BY SUM(oi.price) DESC 
		) AS revenue_rank 
	FROM order_items oi    
	JOIN orders o     
		ON oi.order_id = o.order_id 
	WHERE o.order_status = 'delivered'
	GROUP BY oi.seller_id
)

SELECT 
	CASE 
		WHEN revenue_rank <= 10 THEN 'Top 10 Sellers'
		WHEN revenue_rank <= 50 THEN 'Top 11-50 Sellers'
		WHEN revenue_rank <= 100 THEN 'Top 51-100 Sellers'
		ELSE 'All Other Sellers'
	END AS seller_group, 
	COUNT(*) AS seller_count, 
	ROUND(SUM(revenue), 2) AS revenue, 
	ROUND(
		100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 
		2
	) AS revenue_share_percent
FROM seller_revenue
GROUP BY seller_group 
ORDER BY revenue DESC; 




