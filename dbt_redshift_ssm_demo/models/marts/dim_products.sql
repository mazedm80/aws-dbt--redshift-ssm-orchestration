WITH products AS (
    SELECT * FROM {{ ref('snap_products') }}
),

categories AS (
    SELECT * FROM {{ ref('stg_ecommerce__product_category_name_translation') }}
),

product_dimension AS (
    SELECT 
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['product_id', 'dbt_valid_from']) }} AS product_key,
        
        -- Natural key
        product_id,
        
        -- Product attributes
        p.product_category_name,
        COALESCE(cat.product_category_name_english, 'Unknown') AS product_category_english,
        
        -- Physical attributes
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        
        -- Calculated dimensions
        (product_length_cm * product_height_cm * product_width_cm) AS product_volume_cm3,
        
        -- Size categories
        CASE 
            WHEN product_weight_g < 100 THEN 'Light'
            WHEN product_weight_g < 1000 THEN 'Medium'
            WHEN product_weight_g < 5000 THEN 'Heavy'
            ELSE 'Extra Heavy'
        END AS weight_category,
        
        CASE 
            WHEN (product_length_cm * product_height_cm * product_width_cm) < 1000 THEN 'Small'
            WHEN (product_length_cm * product_height_cm * product_width_cm) < 10000 THEN 'Medium'
            WHEN (product_length_cm * product_height_cm * product_width_cm) < 50000 THEN 'Large'
            ELSE 'Extra Large'
        END AS size_category,
        
        -- Data quality flags
        is_category_missing,
        is_weight_invalid,
        is_length_invalid,
        is_height_invalid,
        is_width_invalid,
        
        -- SCD Type 2 fields from snapshot
        dbt_valid_from AS effective_date,
        dbt_valid_to AS end_date,
        CASE 
            WHEN dbt_valid_to IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_current
        
    FROM products p
    LEFT JOIN categories cat ON p.product_category_name = cat.product_category_name
)

SELECT * FROM product_dimension