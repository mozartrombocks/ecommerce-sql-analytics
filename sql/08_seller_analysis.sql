--1. Total Active Sellers
SELECT 
	COUNT(DISTINCT seller_id) AS total_active_sellers
FROM order_items; 

--2. Top Sellers by Revenue
SELECT
	oi.seller_id,
	s.seller_state,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	COUNT(oi.order_item_id) AS total_items_sold,
	ROUND(SUM(oi.price), 2) AS seller_revenue,
	ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi  
JOIN sellers s   
	ON oi.seller_id = s.seller_id 
JOIN orders o 
	ON oi.order_id = o.order_id 
WHERE o.order_status = 'delivered'
GROUP BY 
	oi.seller_id,
	s.seller_state
ORDER BY seller_revenue DESC
LIMIT 20; 

--3. Top Sellers by Order Volume
SELECT 
	oi.seller_id,
	s.seller_state,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	COUNT(oi.order_item_id) AS total_items_sold,
	ROUND(SUM(oi.price), 2) AS seller_revenue
FROM order_items oi  
JOIN sellers s   
	ON oi.seller_id = s.seller_id 
JOIN orders o   
	ON oi.order_id = o.order_id 
WHERE o.order_status = 'delivered'
GROUP BY 
	oi.seller_id,
	s.seller_state
ORDER BY total_orders DESC 
LIMIT 20; 

--4. Seller Revenue by Seller State
SELECT 
	s.seller_state,
	COUNT(DISTINCT s.seller_id) AS total_sellers,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	ROUND(SUM(oi.price), 2) AS seller_revenue,
	ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi  
JOIN sellers s  
	ON oi.seller_id = s.seller_id 
JOIN orders o   
	ON oi.order_id = o.order_id 
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY seller_revenue DESC;  

--5. Seller Revenue Share
SELECT 
	oi.seller_id, 
	s.seller_state,
	ROUND(SUM(oi.price), 2) AS seller_revenue,
	ROUND(
		100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (),
		2
	) AS revenue_share_percent
FROM order_items oi  
JOIN sellers s  
	ON oi.seller_id = s.seller_id
JOIN orders o  
	ON oi.order_id = o.order_id 
WHERE o.order_status = 'delivered'
GROUP BY 
	oi.seller_id, 
	s.seller_state
ORDER BY seller_revenue DESC
LIMIT 20; 

--6. Seller Revenue Concentration
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
		WHEN revenue_rank <= 50 THEN 'Top 10-50 Sellers'
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

--7. Seller Average Review Score
SELECT 
	oi.seller_id,
	s.seller_state,
	COUNT(DISTINCT oi.order_id) AS reviewed_orders,
	ROUND(AVG(r.review_score), 2) AS avg_review_score,
	ROUND(SUM(oi.price), 2) AS seller_revenue
FROM order_items oi
JOIN sellers s  
	ON oi.seller_id = s.seller_id 
JOIN orders o  
	ON oi.order_id = o.order_id 

JOIN order_reviews r     
	ON oi.order_id = r.order_id 

WHERE o.order_status = 'delivered'
GROUP BY 
	oi.seller_id,
	s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY avg_review_score DESC
LIMIT 20; 

--8. Worst Reveiwed Sellers
SELECT 
	oi.seller_id,
	s.seller_state,
	COUNT(DISTINCT oi.order_id) AS reviewed_orders,
	ROUND(AVG(r.review_score), 2) AS avg_review_score, 
	ROUND(SUM(oi.price), 2) AS seller_revenue
FROM order_items oi    
JOIN sellers s  
	ON oi.seller_id = s.seller_id 

JOIN orders o   
	ON oi.order_id = o.order_id 
JOIN order_reviews r 
	ON oi.order_id = r.order_id

WHERE o.order_status = 'delivered'
GROUP BY 
	oi.seller_id, 
	s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY avg_review_score ASC 
LIMIT 20; 

--9. Seller Late Delivery Rate
SELECT 
	oi.seller_id,
	s.seller_state,
	COUNT(DISTINCT vom.order_id) AS delivered_orders,
	SUM(vom.is_late_delivery) AS late_deliveries,
	ROUND(
		100.0 * SUM(vom.is_late_delivery) / COUNT(DISTINCT vom.order_id), 
		2
	) AS late_delivery_rate_percent,
	ROUND(SUM(oi.price), 2) AS seller_revenue
FROM order_items oi   
JOIN sellers s   
	ON oi.seller_id = s.seller_id 

JOIN vw_order_metrics vom 
	ON oi.order_id = vom.order_id 
GROUP BY 
	oi.seller_id,
	s.seller_state

HAVING COUNT(DISTINCT vom.order_id) >= 50 
ORDER BY late_delivery_rate_percent DESC 
LIMIT 20; 

--10. High Revenue and High Review Sellers
WITH seller_metrics AS (
	SELECT 
		oi.seller_id,
		s.seller_state,
		COUNT(DISTINCT oi.order_id) AS total_orders,
		SUM(oi.price) AS revenue,
		AVG(r.review_score) AS avg_review_score
	FROM order_items oi  
	JOIN sellers s   
		ON oi.seller_id = s.seller_id 
	JOIN orders o   
		ON oi.order_id = o.order_id 
	JOIN order_reviews r   
		ON oi.order_id = r.order_id  
	WHERE o.order_status = 'delivered'
	GROUP BY 
		oi.seller_id,
		s.seller_state
)

SELECT 
	seller_id,
	seller_state,
	total_orders,
	ROUND(revenue, 2) AS revenue, 
	ROUND(avg_review_score, 2) AS avg_review_score
FROM seller_metrics
WHERE total_orders >= 50 
ORDER BY revenue DESC, avg_review_score DESC 
LIMIT 20; 

--11. High Revenue but Low Review Sellers
WITH seller_metrics AS (
	SELECT 
		oi.seller_id, 
		s.seller_state, 
		COUNT(DISTINCT oi.order_id) AS total_orders,
		SUM(oi.price) AS revenue, 
		AVG(r.review_score) AS avg_review_score
	FROM order_items oi 
	JOIN sellers s    
		ON oi.seller_id = s.seller_id
	JOIN orders o   
		ON oi.order_id = o.order_id  
	JOIN order_reviews r    
		ON oi.order_id = r.order_id 
	WHERE o.order_status = 'delivered'
	GROUP BY
		oi.seller_id, 
		s.seller_state
)

SELECT 
	seller_id,
	seller_state,
	total_orders,
	ROUND(revenue, 2) AS revenue,
	ROUND(avg_review_score, 2) AS avg_review_score 
FROM seller_metrics
WHERE total_orders >= 50
ORDER BY revenue DESC, avg_review_score ASC
LIMIT 20;

--12. Seller State Review Performance
SELECT 
	s.seller_state,
	COUNT(DISTINCT s.seller_id) AS total_sellers,
	COUNT(DISTINCT oi.order_id) AS reviewed_orders,
	ROUND(AVG(r.review_score), 2) AS avg_review_score, 
	ROUND(SUM(oi.price), 2) AS seller_revenue
FROM order_items oi  
JOIN sellers s   
	ON oi.seller_id = s.seller_id 
JOIN orders o  
	ON oi.order_id = o.order_id 
JOIN order_reviews r    
	ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state 
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY avg_review_score DESC; 

--13. Seller State Late Delivery Performance 
SELECT 
	s.seller_state,
	COUNT(DISTINCT s.seller_id) AS total_sellers,
	COUNT(DISTINCT vom.order_id) AS delivered_orders, 
	SUM(vom.is_late_delivery) AS late_deliveries, 
	ROUND(
		100.0 * SUM(vom.is_late_delivery) / COUNT(DISTINCT vom.order_id),
		2
	) AS late_delivery_rate_percent
FROM order_items oi
JOIN sellers s  
	ON oi.seller_id = s.seller_id 
JOIN vw_order_metrics vom 
	ON oi.order_id = vom.order_id
GROUP BY s.seller_state 
HAVING COUNT(DISTINCT vom.order_id) >= 100
ORDER BY late_delivery_rate_percent DESC; 

--14. Seller Operational Summary
SELECT 
	COUNT(DISTINCT oi.seller_id) AS active_sellers, 
	COUNT(DISTINCT oi.order_id) AS delivered_orders,
	ROUND(SUM(oi.price), 2) AS total_seller_revenue,
	ROUND(AVG(oi.price), 2) AS avg_item_price, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score, 
	ROUND(
		100.0 * SUM(vom.is_late_delivery) / COUNT(DISTINCT vom.order_id), 
		2
	) AS late_delivery_rate_percent 
FROM order_items oi   
JOIN orders o   
	ON oi.order_id = o.order_id 
JOIN order_reviews r  
	ON oi.order_id = r.order_id 
JOIN vw_order_metrics vom 
	ON oi.order_id = vom.order_id 
WHERE o.order_status = 'delivered'; 