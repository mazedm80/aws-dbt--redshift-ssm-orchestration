WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'orders') }}
),

cleaned AS (
    SELECT
        order_id,
        customer_id,
        LOWER(TRIM(order_status)) AS order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        TRUNC(order_purchase_timestamp) AS order_purchase_date,

        CASE 
            WHEN order_approved_at IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_approval_missing,
        
        CASE 
            WHEN order_delivered_customer_date IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_delivery_missing

    FROM source
    WHERE order_id IS NOT NULL
)

SELECT * FROM cleaned