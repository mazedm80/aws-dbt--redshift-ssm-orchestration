WITH customers AS (
    SELECT * FROM {{ ref('snap_customers') }}
),

customer_dimension AS (
    SELECT 
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'dbt_valid_from']) }} AS customer_key,
        
        -- Natural key
        customer_id,
        customer_unique_id,
        
        -- Geographic attributes
        customer_city,
        customer_state,
        customer_zip_code_prefix,
        
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
        
    FROM customers
)

SELECT * FROM customer_dimension