-- Test if freight values are positive
SELECT order_id
FROM {{ ref('stg_ecommerce__order_items') }}
WHERE freight_value < 0