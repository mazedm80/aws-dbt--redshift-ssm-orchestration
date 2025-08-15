WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'product_category_name_translation') }}
),

cleaned AS (
    SELECT
        product_category_name,
        LOWER(TRIM(product_category_name_english)) AS product_category_name_english,

        CASE 
            WHEN product_category_name_english IS NULL OR product_category_name_english = '' THEN TRUE 
            ELSE FALSE 
        END AS is_category_name_english_missing
    
    FROM source
    WHERE product_category_name IS NOT NULL
)

SELECT * FROM cleaned