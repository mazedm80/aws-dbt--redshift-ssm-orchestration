WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'customers') }}
),

cleaned AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        TRIM(INITCAP(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state,
        
        CASE 
            WHEN customer_city IS NULL OR customer_city = '' THEN TRUE 
            ELSE FALSE 
        END AS is_city_missing,
        
        CASE 
            WHEN customer_state IS NULL OR customer_state = '' THEN TRUE 
            ELSE FALSE 
        END AS is_state_missing,
        
        CASE 
            WHEN customer_zip_code_prefix IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_zip_missing

    FROM source
    WHERE customer_id IS NOT NULL
)

SELECT * FROM cleaned