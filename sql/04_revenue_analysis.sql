--1 Total Revenue
SELECT ROUND(SUM(total_order_value), 2) AS total_revenue
FROM vw_order_metrics; 

--2. Total Delivered Orders
SELECT COUNT(DISTINCT order_id) AS total_delivered_orders
FROM vw_order_metrics;

--3. Average Order Value
SELECT ROUND(AVG(total_order_value), 2) AS average_order_value
FROM vw_order_metrics; 

--4. Monthly Revenue Trend
SELECT
    order_month,
    ROUND(SUM(total_order_value), 2) AS monthly_revenue
    FROM vw_order_metrics
    GROUP BY order_month
    ORDER BY order_month;

--5. Monthly Order Volume
SELECT 
    order_month,
    COUNT(DISTINCT order_id) AS monthly_orders
FROM vw_order_metrics
GROUP BY order_month
ORDER BY order_month; 

--6. Monthly Average Order Value
SELECT 
    order_month,
    ROUND(AVG(total_order_value), 2) AS avg_order_value
    FROM vw_order_metrics
    GROUP BY order_month
    ORDER BY order_month;

--7. Revenue by State
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders, 
    ROUND(SUM(total_order_value), 2) AS revenue
FROM vw_order_metrics
GROUP BY customer_state
ORDER BY revenue DESC;

--8. Top 10 States by Revenue
SELECT
    customer_state,
    ROUND(SUM(total_order_value), 2) AS revenue
FROM vw_order_metrics
GROUP BY customer_state
ORDER BY revenue DESC
LIMIT 10;

--9. Month-over-Month Revenue Growth
WITH monthly_revenue AS (
	SELECT 
	    order_month,
    SUM(total_order_value) AS revenue
    FROM vw_order_metrics
    GROUP BY order_month
)

SELECT 
	order_month, 

	ROUND(revenue, 2) AS revenue, 

	ROUND(
		LAG(revenue) OVER (ORDER BY order_month), 2
	) AS previous_month_revenue,

	ROUND(
		100.0 * (revenue -LAG(revenue) OVER (ORDER BY order_month) ) / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0), 2) AS revenue_growth_percentage
FROM monthly_revenue
ORDER BY order_month;

--10. Revenue Contribution by State
SELECT 
	customer_state,
	ROUND(SUM(total_order_value), 2) AS revenue,
	ROUND(100.0 * SUM(total_order_value) / SUM(SUM(total_order_value)) OVER(), 2) AS revenue_contribution_percent
FROM vw_order_metrics
GROUP BY customer_state
ORDER BY revenue DESC;

--11. Top Revenue Months
SELECT 
	order_month,
	ROUND(SUM(total_order_value), 2) AS revenue, 
	COUNT(DISTINCT order_id) AS total_orders, 
	ROUND(AVG(total_order_value), 2) AS average_order_value
FROM vw_order_metrics
GROUP BY order_month
ORDER BY revenue DESC
LIMIT 10;

--12. Revenue, Orders, and AOV Combined by Month
SELECT 
	order_month,
	ROUND(SUM(total_order_value), 2) AS monthly_revenue,
	COUNT(DISTINCT order_id) AS monthly_orders, 
	ROUND(AVG(total_order_value), 2) AS average_order_value

FROM vw_order_metrics
GROUP BY order_month
ORDER BY order_month; 