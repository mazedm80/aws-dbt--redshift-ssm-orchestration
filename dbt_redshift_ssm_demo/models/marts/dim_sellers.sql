WITH sellers AS (
    SELECT * FROM {{ ref('snap_sellers') }}
),

seller_dimension AS (
    SELECT 
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['seller_id', 'dbt_valid_from']) }} AS seller_key,
        
        -- Natural key
        seller_id,
        
        -- Geographic attributes
        seller_city,
        seller_state,
        seller_zip_code_prefix,
        
        -- Data quality flags
        is_city_missing,
        is_state_missing,
        is_zip_missing,
        
        -- SCD Type 2 fields from snapshot
        dbt_valid_from AS effective_date,
        dbt_valid_to AS end_date,
        CASE 
            WHEN dbt_valid_to IS NULL THEN TRUE 
            ELSE FALSE 
        END AS is_current
        
    FROM sellers
)

SELECT * FROM seller_dimension