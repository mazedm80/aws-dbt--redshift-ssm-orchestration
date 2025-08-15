-- Test if item prices are positive
SELECT order_id
FROM {{ ref('stg_ecommerce__order_items') }}
WHERE price < 0