--1. Top Product Categories by Revenue

SELECT 
	category, 
	total_orders,
	total_items_sold, 
	ROUND(revenue, 2) AS revenue, 
	ROUND(avg_item_price, 2) AS avg_item_price
FROM vw_category_revenue
ORDER BY revenue DESC
LIMIT 15; 

--2. Top Product Categories by Items Sold
SELECT 
	category, 
	total_orders,
	total_items_sold, 
	ROUND(revenue, 2) AS revenue, 
	ROUND(avg_item_price, 2) AS avg_item_price
FROM vw_category_revenue
ORDER BY total_items_sold DESC
LIMIT 15; 

--3. Highest Average Item Price by Category
SELECT 
	category, 
	total_items_sold, 
	ROUND(avg_item_price, 2) AS avg_item_price, 
	ROUND(revenue, 2) AS revenue
FROM vw_category_revenue
WHERE total_items_sold >= 50
ORDER BY avg_item_price DESC
LIMIT 15; 

--4.Freight Cost by Category
SELECT 
	category, 
	total_items_sold, 
	ROUND(freight_revenue, 2) AS total_freight_value, 
	ROUND(freight_revenue / NULLIF(total_items_sold, 0), 2) AS avg_freight_per_item, 
	ROUND(revenue, 2) AS product_revenue
FROM vw_category_revenue
ORDER BY total_freight_value DESC 
LIMIT 15;

--5. Revenue Share by Category
SELECT 
	category, 
	ROUND(revenue, 2) AS revenue, 
	ROUND(
		100.0 * revenue / SUM(revenue) OVER (), 
		2
	) AS revenue_share_percent 
FROM vw_category_revenue
ORDER BY revenue DESC
LIMIT 20; 

--6. Product Category Concentration
WITH ranked_categories AS (
	SELECT 
		category, 
		revenue, 
		RANK() OVER (
			ORDER BY revenue DESC 
		) AS revenue_rank
	FROM vw_category_revenue
)

SELECT 
	CASE
		WHEN revenue_rank <= 5 THEN 'Top 5 Categories'
		WHEN revenue_rank <= 10 THEN 'Top 6-10 Categories'
		ELSE 'All other Categories'
	END AS category_group, 
	ROUND(SUM(revenue), 2) AS revenue, 
	ROUND(
		100.0 * SUM(revenue) /
		SUM(SUM(revenue)) OVER (), 
		2
	) AS revenue_share_percent
FROM ranked_categories
GROUP BY category_group 
ORDER BY revenue DESC; 

--7. Product Categories with Low Revenue
SELECT 
	category, 
	total_orders, 
	total_items_sold, 
	ROUND(revenue, 2) AS revenue, 
	ROUND(avg_item_price, 2) AS avg_item_price
FROM vw_category_revenue
WHERE total_items_sold >= 10
ORDER BY revenue ASC
LIMIT 15;

--8. Freight-to-Revenue Ratio by Category
SELECT 
	category, 
	ROUND(revenue, 2) AS product_revenue, 
	ROUND(freight_revenue, 2) AS freight_revenue, 
	ROUND(
		100.0 * freight_revenue / NULLIF(revenue, 0), 
		2 
	) AS freight_to_revenue_percent
FROM vw_category_revenue
WHERE revenue > 0
ORDER BY freight_to_revenue_percent DESC
LIMIT 15; 


--9. Product Size and Weight By Category
SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS product_count,
    ROUND(AVG(p.product_weight_g)::numeric, 2) AS avg_weight_g,
    ROUND(AVG(p.product_length_cm)::numeric, 2) AS avg_length_cm,
    ROUND(AVG(p.product_height_cm)::numeric, 2) AS avg_height_cm,
    ROUND(AVG(p.product_width_cm)::numeric, 2) AS avg_width_cm
FROM products p
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    )
ORDER BY avg_weight_g DESC
LIMIT 15;


--10. Category Revenue and Review Score
SELECT
	COALESCE (
		t.product_category_name_english, 
		p.product_category_name
	) AS category, 
	COUNT(DISTINCT oi.order_id) AS total_orders,
	ROUND(SUM(oi.price), 2) AS revenue, 
	ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi      
JOIN products p   
	ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t 
	ON p.product_category_name = t.product_category_name 
JOIN orders o 
	ON oi.order_id = o.order_id
JOIN order_reviews r  
	ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY 
	COALESCE (
		t.product_category_name_english, 
		p.product_category_name
	)
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY revenue DESC 
LIMIT 20; 


--11. Best Categories By Revenue and Review Score
WITH category_reviews AS (
	SELECT 
		COALESCE(
			t.product_category_name_english, 
			p.product_category_name
		) AS category,  
		COUNT(DISTINCT oi.order_id) AS total_orders, 
		SUM(oi.price) AS revenue, 
		AVG(r.review_score) AS avg_review_score
	FROM order_items oi            
	JOIN products p 
		ON oi.product_id = p.product_id 
	LEFT JOIN product_category_translation t 
		ON p.product_category_name = t.product_category_name
	JOIN orders o  
		ON oi.order_id = o.order_id
	JOIN order_reviews r     
		ON oi.order_id = r.order_id  
	WHERE o.order_status = 'delivered'
	GROUP BY 
		COALESCE(
			t.product_category_name_english, 
			p.product_category_name
		)
)

SELECT 
	category, 
	total_orders, 
	ROUND(revenue, 2) AS revenue, 
	ROUND(avg_review_score, 2) AS avg_review_score
FROM category_reviews
WHERE total_orders >= 100
ORDER BY revenue DESC, avg_review_score DESC
LIMIT 15; 


--12, Product Count by Category
SELECT 
	COALESCE(
		t.product_category_name_english,
		p.product_category_name
	) AS category, 
	COUNT(DISTINCT p.product_id) AS product_count
FROM products p

LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY 
	COALESCE (
		t.product_category_name_english, 
		p.product_category_name
	)
ORDER BY product_count DESC
LIMIT 20; 