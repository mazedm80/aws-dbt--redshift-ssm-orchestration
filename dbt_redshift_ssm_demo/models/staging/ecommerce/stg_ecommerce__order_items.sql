WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'order_items') }}
),

cleaned AS (
    SELECT
        order_id,
        CAST(order_item_id AS INT) AS order_item_id,
        product_id,
        seller_id,
        CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
        ROUND(CAST(price AS NUMERIC), 2) AS price,
        ROUND(CAST(freight_value AS NUMERIC), 2) AS freight_value

    FROM source
    WHERE order_id IS NOT NULL
      AND product_id IS NOT NULL
      AND seller_id IS NOT NULL
)

SELECT * FROM cleaned