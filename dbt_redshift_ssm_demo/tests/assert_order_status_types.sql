-- Test if order status types are valid
SELECT order_id
FROM {{ ref('stg_ecommerce__orders') }}
WHERE order_status NOT IN ('approved', 'canceled', 'created', 'delivered', 'invoiced', 'processing', 'shipped', 'unavailable')
