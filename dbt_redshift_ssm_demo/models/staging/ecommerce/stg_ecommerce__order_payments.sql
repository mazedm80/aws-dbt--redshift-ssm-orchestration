WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'order_payments') }}
),

cleaned AS (
    SELECT
        order_id,
        CAST(payment_sequential AS INT) AS payment_sequential,
        LOWER(TRIM(payment_type)) AS payment_type,
        CAST(payment_installments AS INT) AS payment_installments,
        ROUND(CAST(payment_value AS NUMERIC), 2) AS payment_value,
        
        CASE 
            WHEN payment_type IS NULL OR payment_type = '' THEN TRUE 
            ELSE FALSE 
        END AS is_payment_type_missing,

        CASE 
            WHEN payment_value IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_payment_value_missing


    FROM source
    WHERE order_id IS NOT NULL
)

SELECT * FROM cleaned