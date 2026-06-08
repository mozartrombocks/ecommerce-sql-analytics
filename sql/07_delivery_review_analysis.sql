--1. Overall Delivery Performance
SELECT
	COUNT(*) AS delivered_orders, 
	ROUND(AVG(delivery_days), 2) AS avg_delivery_days, 
	MIN(delivery_days) AS fastest_delivery_days, 
	MAX(delivery_days) AS slowest_delivery_days
FROM vw_order_metrics
WHERE delivery_days IS NOT NULL;   

--2. Overall Late Delivery Rate
SELECT
	COUNT(*) AS delivered_orders, 
	SUM(is_late_delivery) AS late_deliveries,
	ROUND(
		100.0 * SUM(is_late_delivery) / COUNT(*), 
		2
	) AS late_delivery_rate_percent
FROM vw_order_metrics; 

--3. Delivery Performance By Customer State
SELECT 
	customer_state, 
	COUNT(*) AS delivered_orders, 
	ROUND(AVG(delivery_days), 2) AS avg_delivery_days, 
	SUM(is_late_delivery) AS late_deliveries, 
	ROUND(
		100.0 * SUM(is_late_delivery) / COUNT(*), 
		2
	) AS late_delivery_rate_percent
FROM vw_order_metrics
WHERE delivery_days IS NOT NULL
GROUP BY customer_state
ORDER BY avg_delivery_days DESC; 

--4. Review Score Distribution
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

--5. Overall Average Review Score
SELECT 
	ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews; 

--6. Late Delivery vs Review Score
SELECT 
	CASE 
		WHEN vom.is_late_delivery = 1 THEN 'Late Delivery'
		ELSE 'On-Time Delivery'
	END AS delivery_status, 
	COUNT(DISTINCT vom.order_id) AS total_orders, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom
JOIN order_reviews r   
	ON vom.order_id = r.order_id
GROUP BY delivery_status 
ORDER BY avg_review_score DESC; 

--7. Delivery Speed Groupss 
SELECT	
	CASE 
		WHEN delivery_days <= 3 THEN '0-3 Days'	
		WHEN delivery_days BETWEEN 4 and 7 THEN '4-7 Days'
		WHEN delivery_days BETWEEN 8 and 14 THEN '8-14 Days'
		WHEN delivery_days BETWEEN 15 and 30 THEN '15-30 Days'
		ELSE '31+ Days'
	END AS delivery_speed_group,
	COUNT(*) AS total_orders, 
	ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM vw_order_metrics
WHERE delivery_days IS NOT NULL
GROUP BY delivery_speed_group
ORDER BY 
	MIN(delivery_days); 

--8. Delivery Speed Groups with Review Scores
SELECT 
	CASE
		WHEN vom.delivery_days <= 3 THEN '0-3 Days'
		WHEN vom.delivery_days BETWEEN 4 and 7 THEN '4-7 Days'
		WHEN vom.delivery_days BETWEEN 8 and 14 THEN '8-14 Days'
		WHEN vom.delivery_days BETWEEN 15 and 30 THEN '15-30 Days'
		ELSE '31+ Days'
	END AS delivery_speed_group, 
	COUNT(DISTINCT vom.order_id) AS total_orders, 
	ROUND(AVG(vom.delivery_days), 2) AS avg_delivery_days, 
	ROUnD(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom
JOIN order_reviews r     
	ON vom.order_id = r.order_id 
WHERE vom.delivery_days IS NOT NULL 
GROUP BY delivery_speed_group
ORDER BY 
	MIN(vom.delivery_days); 

--9. Slowest States by Average Delivery Time
SELECT 
	customer_state, 
	COUNT(*) AS delivered_orders, 
	ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM vw_order_metrics
WHERE delivery_days IS NOT NULL
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY avg_delivery_days DESC
LIMIT 10; 

--10. Highest Late Delivery Date By State
SELECT 
	customer_state, 
	COUNT(*) AS delivered_orders, 
	SUM(is_late_delivery) AS late_deliveries,
	ROUND( 
		100.0 * SUM(is_late_delivery) / COUNT(*), 
		2
	) AS late_delivery_rate_percent 
FROM vw_order_metrics
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY late_delivery_rate_percent DESC
LIMIT 10; 

--11. Review Score by Customer State
SELECT
	vom.customer_state,
	COUNT(DISTINCT vom.order_id) AS reviewed_orders,
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom
JOIN order_reviews r   
	ON vom.order_id = r.order_id
GROUP BY vom.customer_state
HAVING COUNT(DISTINCT vom.order_id) >= 100
ORDER BY avg_review_score ASC; 

--12. Delivery Time vs Review Score
SELECT 
	r.review_score,
	COUNT(DISTINCT vom.order_id) AS total_orders,
	ROUND(AVG(vom.delivery_days), 2) AS avg_delivery_days
FROM vw_order_metrics vom
JOIN order_reviews r   
	ON vom.order_id = r.order_id
WHERE vom.delivery_days IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score; 

--13. Late Delivery Review Distribution
SELECT 
	CASE
		WHEN vom.is_late_delivery = 1 THEN 'Late Delivery'
		ELSE 'On-Time Delivery'
	END AS delivery_status,
	r.review_score, 
	COUNT(*) AS review_count,
	ROUND(
		100.0 * COUNT(*) / 
		SUM(COUNT(*)) OVER (
			PARTITION BY 
				CASE 
					WHEN vom.is_late_delivery = 1 THEN 'Late Delivery'
					ELSE 'On-Time Delivery'
				END 
		),
		2
	) AS review_share_within_delivery_status 
FROM vw_order_metrics vom
JOIN order_reviews r   
	ON vom.order_id = r.order_id  
GROUP BY 
	delivery_status,
	r.review_score    
ORDER BY 
	delivery_status, 
	r.review_score; 

--14. Orders Delivered Before, On, or After Estimated Date
SELECT 
	CASE 
		WHEN order_delivered_customer_date < order_estimated_delivery_date
			THEN 'Delivered Early'
		WHEN order_delivered_customer_date = order_estimated_delivery_date
			THEN 'Delivered On Estimated Date'
		WHEN order_delivered_customer_date > order_estimated_delivery_date
			THEN 'Delivered Late'
		ELSE 'Unknown'
	END AS delivery_timing_status, 
	COUNT(*) AS total_orders,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 
		2 
	) AS order_share_percent 
FROM vw_order_metrics
GROUP BY delivery_timing_status 
ORDER BY total_orders DESC; 

--15. Delivery Timing Status with Review Score
SELECT 
	CASE 
		WHEN vom.order_delivered_customer_date < vom.order_estimated_delivery_date
			THEN 'Delivered Early'
		WHEN vom.order_delivered_customer_date = vom.order_estimated_delivery_date
			THEN 'Delivered On Estimated Date'
		WHEN vom.order_delivered_customer_date > vom.order_estimated_delivery_date
			THEN 'Delivered Late'
		ELSE 'Unknown'
	END AS delivery_timing_status,
	COUNT(DISTINCT vom.order_id) AS total_orders, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom 
JOIN order_reviews r   
	ON vom.order_id = r.order_id 
GROUP BY delivery_timing_status
ORDER BY avg_review_score DESC; 

--16. Operational Summary Matches
SELECT
	COUNT(DISTINCT vom.order_id) AS delivered_date,
	ROUND(AVG(vom.delivery_days), 2) AS avg_delivery_days,
	SUM(vom.is_late_delivery) AS late_deliveries,
	ROUND(
		100.0 * SUM(vom.is_late_delivery) / COUNT(*),
		2
	) AS late_delivery_rate_percent,
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM vw_order_metrics vom
JOIN order_reviews r  
	ON vom.order_id = r.order_id; 

