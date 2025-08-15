WITH order_items AS (
    SELECT * FROM {{ ref('stg_ecommerce__order_items') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_ecommerce__orders') }}
),

customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
),

products AS (
    SELECT * FROM {{ ref('dim_products') }}
),

dates AS (
    SELECT * FROM {{ ref('dim_date') }}
),

daily_orders AS (
    SELECT 
        d.date_key,
        c.customer_key,
        -- Additive measures
        COUNT(DISTINCT oi.order_id) AS daily_order_count,
        COUNT(oi.order_item_id) AS daily_item_count,
        SUM(oi.price) AS daily_revenue,
        SUM(oi.freight_value) AS daily_freight,
        SUM(oi.price + oi.freight_value) AS daily_total_cost,
        
        -- Semi-additive measures
        COUNT(DISTINCT oi.seller_id) AS unique_sellers,
        COUNT(DISTINCT p.product_category_english) AS unique_categories,
        
        -- Non-additive measures
        AVG(oi.price) AS avg_item_price,
        AVG(oi.freight_value) AS avg_freight_price

    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN dates d ON DATE(o.order_purchase_timestamp) = d.date_day
    
    GROUP BY d.date_key, c.customer_key
)

SELECT * FROM daily_orders