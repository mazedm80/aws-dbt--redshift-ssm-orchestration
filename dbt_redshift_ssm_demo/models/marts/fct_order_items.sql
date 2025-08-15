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

fact_order_items AS (
    SELECT 
        -- Surrogate key for fact
        {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.order_item_id']) }} AS order_item_key,
        
        -- Foreign keys to dimensions
        c.customer_key,
        p.product_key,
        d.date_key AS order_date_key,
        
        -- Degenerate dimensions (kept in fact)
        oi.order_id,
        oi.order_item_id,
        oi.seller_id,
        
        -- Additive facts
        oi.shipping_limit_date,
        oi.price AS item_price,
        oi.freight_value,
        oi.price + oi.freight_value AS total_item_cost,
        1 AS quantity, -- Each row represents one item
        
        -- Semi-additive facts
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        
        -- Non-additive facts (ratios, etc.)
        CASE 
            WHEN oi.price > 0 THEN oi.freight_value / oi.price 
            ELSE 0 
        END AS freight_to_price_ratio
        
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN dates d ON DATE(o.order_purchase_timestamp) = d.date_day
    
    WHERE o.order_status NOT IN ('cancelled', 'unavailable')
    
    {% if is_incremental() %}
        AND o.order_purchase_timestamp > (SELECT MAX(order_purchase_timestamp) FROM {{ this }})
    {% endif %}
)

SELECT * FROM fact_order_items