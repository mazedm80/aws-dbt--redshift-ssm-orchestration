WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'sellers') }}
),

cleaned AS (
    SELECT
        seller_id, 
        CAST(seller_zip_code_prefix AS INT) AS seller_zip_code_prefix,
        TRIM(INITCAP(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state,

        CASE 
            WHEN seller_city IS NULL OR seller_city = '' THEN TRUE 
            ELSE FALSE 
        END AS is_city_missing,

        CASE 
            WHEN seller_state IS NULL OR seller_state = '' THEN TRUE 
            ELSE FALSE 
        END AS is_state_missing,

        CASE 
            WHEN seller_zip_code_prefix IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_zip_missing
    
    FROM source
    WHERE seller_id IS NOT NULL
)

SELECT * FROM cleaned