--1. Total Unique Customers
SELECT 
	COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers; 




--2. Repeat Customer Rate
SELECT 
	COUNT(*) AS total_customers, 
	SUM(is_repeat_customer) AS repeat_customers, 
	ROUND(
		100.0 * SUM(is_repeat_customer) / COUNT(*), 
		2
	) AS repeat_customer_rate_percent
FROM vw_customer_retention; 




--3. One-Time vs Repeat Customers
SELECT 
	CASE 
		WHEN is_repeat_customer =  1 THEN 'Repeat Customer'
		ELSE 'One-Time Customer'
	END AS customer_type, 
	COUNT(*) AS customer_count, 
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 
		2 
	) AS customer_share_percent
FROM vw_customer_retention
GROUP BY customer_type 
ORDER BY customer_count DESC; 




--4. Revenue from First-Time vs Repeat Customer 
WITH customer_order_numbers AS (
	SELECT 
		c.customer_unique_id, 
		o.order_id, 
		ROW_NUMBER() OVER (
			PARTITION BY c.customer_unique_id 
			ORDER BY o.order_purchase_timestamp
		) AS order_number
	FROM orders o  
	JOIN customers c    
		ON o.customer_id = c.customer_id 
	WHERE o.order_status = 'delivered'
) 

SELECT 
	CASE
		WHEN con.order_number = 1 THEN 'First-Time Purchase'
		ELSE 'Repeat Purchase'
	END AS purchase_type, 
	COUNT(DISTINCT vom.order_id) AS totat_orders, 
	ROUND(SUM(vom.total_order_value), 2) AS revenue, 
	ROUND(AVG(vom.total_order_value), 2) AS average_order_value
FROM vw_order_metrics vom 
JOIN customer_order_numbers con    
	ON vom.order_id = con.order_id 
GROUP BY purchase_type 
ORDER BY revenue DESC; 




--5. Orders Per Customer Distribution
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




--6. Customers by State
SELECT 
	customer_state, 
	COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY customer_state
ORDER BY unique_customers DESC; 




--7. Repeat Customer Rate By State
WITH customer_state_orders AS (
	SELECT 
		c.customer_unique_id, 
		c.customer_state, 
		COUNT(DISTINCT o.order_id) AS total_orders
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	WHERE o.order_status = 'delivered'
	GROUP BY 
		c.customer_unique_id, 
		c.customer_state
)

SELECT 
	customer_state, 
	COUNT(*) AS total_customers, 
	SUM(
		CASE WHEN total_orders > 1 THEN 1
		ELSE 0 
		END
	) AS repeat_cusstomer_rate_percent
FROM customer_state_orders
GROUP BY customer_state
ORDER BY
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) DESC;




--8, Highest-Value Customers
SELECT 
	customer_unique_id, 
	COUNT(DISTINCT order_id) AS total_orders, 
	ROUND(SUM(total_order_value), 2) AS customer_revenue, 
	ROUND(AVG(total_order_value), 2) AS average_order_value, 
	MIN(order_purchase_timestamp) AS first_order_date,
	MAX(order_purchase_timestamp) AS last_order_date
FROM vw_order_metrics
GROUP BY customer_unique_id
ORDER BY customer_revenue DESC
LIMIT 20; 



--9. First Purchase Month Trend
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




--10. Cohort Retention Counts
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
	
)

SELECT 
	cohort_month, 
	months_since_first_purchase, 
	COUNT(DISTINCT customer_unique_id) AS active_customers
FROM cohort_activity
GROUP BY 
	cohort_month, 
	months_since_first_purchase
ORDER BY 
	cohort_month, 
	months_since_first_purchase; 


--11. Best Categories By Revenue and Review Score
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
	GROUP BY 
		cohort_month,
		months_since_first_purchase
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



--12. Product Count by Category 
SELECT
	CASE 
		WHEN total_orders = 1 THEN 'One-Time Customer'
		WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional Repeat Customer'
		ELSE 'Frequent Repeat Customer'
	END AS customer_segment, 
	COUNT(*) AS customer_count, 
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 
		2
	) AS customer_share_percent
FROM vw_customer_retention
GROUP BY customer_segment 
ORDER BY customer_count DESC; 