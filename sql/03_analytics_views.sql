-- 1. Order Metrics View

CREATE OR REPLACE VIEW vw_order_metrics AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    SUM(oi.price) AS product_revenue,
    SUM(oi.freight_value) AS freight_revenue,
    SUM(oi.price + oi.freight_value) AS total_order_value,
    COUNT(oi.order_item_id) AS number_of_items,

    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1
        ELSE 0
    END AS is_late_delivery,

    EXTRACT(DAY FROM o.order_delivered_customer_date - o.order_purchase_timestamp) AS delivery_days

FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date;


-- 2. Product Category Revenue View

CREATE OR REPLACE VIEW vw_category_revenue AS
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    SUM(oi.price) AS revenue,
    SUM(oi.freight_value) AS freight_revenue,
    AVG(oi.price) AS avg_item_price

FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(t.product_category_name_english, p.product_category_name);


-- 3. Customer Retention View

CREATE OR REPLACE VIEW vw_customer_retention AS
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
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
    customer_unique_id,
    COUNT(order_id) AS total_orders,
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date,
    CASE
        WHEN COUNT(order_id) > 1 THEN 1
        ELSE 0
    END AS is_repeat_customer
FROM customer_orders
GROUP BY customer_unique_id;