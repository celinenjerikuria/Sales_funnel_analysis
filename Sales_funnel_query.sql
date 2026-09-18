SELECT * FROM user_events;

-- create stages    
WITH funnel_stages AS
(SELECT
COUNT(DISTINCT CASE WHEN event_type='page_view'THEN user_id END)AS stage_1_page_views,
COUNT(DISTINCT CASE WHEN event_type='add_to_cart'THEN user_id END)AS stage_2_cart,
COUNT(DISTINCT CASE WHEN event_type='checkout_start'THEN user_id END)AS stage_3_checkout,
COUNT(DISTINCT CASE WHEN event_type='payment_info'THEN user_id END)AS stage_4_payment,
COUNT(DISTINCT CASE WHEN event_type='purchase'THEN user_id END)AS stage_5_purchase
FROM user_events
)
SELECT * 
FROM funnel_stages;

-- conversion rates through  the stages
WITH funnel_stages AS
(SELECT
COUNT(DISTINCT CASE WHEN event_type='page_view'THEN user_id END)AS stage_1_page_views,
COUNT(DISTINCT CASE WHEN event_type='add_to_cart'THEN user_id END)AS stage_2_cart,
COUNT(DISTINCT CASE WHEN event_type='checkout_start'THEN user_id END)AS stage_3_checkout,
COUNT(DISTINCT CASE WHEN event_type='payment_info'THEN user_id END)AS stage_4_payment,
COUNT(DISTINCT CASE WHEN event_type='purchase'THEN user_id END)AS stage_5_purchase
FROM user_events
)
SELECT
ROUND(stage_2_cart*100.0/NULLIF(stage_1_page_views, 0), 2) AS views_to_cart_conversion_rate,
ROUND(stage_3_checkout*100.0/NULLIF(stage_2_cart, 0), 2) AS cart_to_checkout_conversion_rate,
ROUND(stage_4_payment*100.0/NULLIF(stage_3_checkout, 0), 2) AS checkout_to_payment_conversion_rate,
ROUND(stage_5_purchase*100.0/NULLIF(stage_4_payment, 0), 2) AS payment_to_purchase_conversion_rate,
ROUND(stage_5_purchase*100.0/NULLIF(stage_1_page_views, 0), 2) AS overall_conversion_rate
FROM 
funnel_stages;

-- funnel by traffic source
WITH source_funnel AS
(
SELECT
traffic_source,
COUNT(DISTINCT CASE WHEN event_type='page_view'THEN user_id END)AS views,
COUNT(DISTINCT CASE WHEN event_type='add_to_cart'THEN user_id END)AS cart,
COUNT(DISTINCT CASE WHEN event_type='purchase' THEN user_id END)AS purchases
FROM user_events
GROUP BY traffic_source
)
SELECT 
traffic_source,
views,
cart,
purchases,
ROUND(cart*100.0/NULLIF(views, 0), 2) AS views_to_cart_rate,
ROUND(purchases*100.0/NULLIF(cart, 0), 2) AS cart_to_purchases_rate,
ROUND(purchases*100.0/NULLIF(views, 0), 2) AS views_to_purchases_rate
FROM 
source_funnel
ORDER BY purchases;

-- time spent by users
WITH user_journey AS
(
SELECT
user_id,
MIN(CASE WHEN event_type='page_view'THEN event_date END) AS view_time,
MIN(CASE WHEN event_type='add_to_cart'THEN event_date END) AS cart_time,
MIN(CASE WHEN event_type='purchase' THEN event_date END) AS purchase_time
FROM user_events
GROUP BY user_id
HAVING MIN(CASE WHEN event_type='purchase' THEN event_date END) IS NOT NULL
)
SELECT
COUNT(*)AS converted_users,
ROUND(AVG(TIMESTAMPDIFF(MINUTE,view_time,cart_time)),2)AS avg_view_to_cart_time,
ROUND(AVG(TIMESTAMPDIFF(MINUTE,cart_time,purchase_time)),2)AS avg_cart_to_purchase_time,
ROUND(AVG(TIMESTAMPDIFF(MINUTE,view_time,purchase_time)),2)AS avg_total_journey
FROM user_journey;

-- Revenue funnel
WITH funnel_revenue AS
(SELECT
COUNT(DISTINCT CASE WHEN event_type='page_view'THEN user_id END)AS total_visitors,
COUNT(DISTINCT CASE WHEN event_type='purchase' THEN user_id END)AS total_buyers,
SUM(CASE WHEN event_type='purchase' THEN amount ELSE 0 END) AS total_revenue,
COUNT(DISTINCT CASE WHEN event_type='purchase' THEN user_id END) AS total_orders
FROM user_events
)
SELECT
total_visitors,
total_buyers,
total_orders,
ROUND(total_revenue),
ROUND(total_revenue/NULLIF(total_orders, 0), 2)AS avg_order_value,
ROUND(total_revenue/NULLIF(total_buyers, 0), 2) AS avg_revenue_per_buyer,
ROUND(total_revenue/NULLIF(total_visitors, 0), 2)AS avg_revenue_per_visitor
FROM funnel_revenue;

