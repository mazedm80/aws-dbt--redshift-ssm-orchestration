WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'products') }}
),

cleaned AS (
    SELECT
        product_id,
        LOWER(TRIM(product_category_name)) AS product_category_name,
        product_name_lenght AS product_name_length,
        product_description_lenght AS product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,

        CASE 
            WHEN product_category_name IS NULL OR product_category_name = '' THEN TRUE 
            ELSE FALSE 
        END AS is_category_missing,

        CASE 
            WHEN product_name_lenght IS NULL OR product_name_lenght <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_name_length_invalid,

        CASE 
            WHEN product_description_lenght IS NULL OR product_description_lenght <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_description_length_invalid,

        CASE 
            WHEN product_photos_qty IS NULL OR product_photos_qty <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_photos_qty_invalid,

        CASE 
            WHEN product_weight_g IS NULL OR product_weight_g <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_weight_invalid,

        CASE 
            WHEN product_length_cm IS NULL OR product_length_cm <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_length_invalid,

        CASE 
            WHEN product_height_cm IS NULL OR product_height_cm <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_height_invalid,

        CASE 
            WHEN product_width_cm IS NULL OR product_width_cm <= 0 THEN TRUE 
            ELSE FALSE 
        END AS is_width_invalid

    FROM source
    WHERE product_id IS NOT NULL
)

SELECT * FROM cleaned