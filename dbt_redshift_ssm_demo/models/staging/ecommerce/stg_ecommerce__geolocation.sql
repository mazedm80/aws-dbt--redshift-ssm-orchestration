WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'geolocation') }}
),

cleaned AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        TRIM(INITCAP(geolocation_city)) AS geolocation_city,
        UPPER(TRIM(geolocation_state)) AS geolocation_state,

        CASE 
            WHEN geolocation_city IS NULL OR geolocation_city = '' THEN TRUE 
            ELSE FALSE 
        END AS is_city_missing,

        CASE 
            WHEN geolocation_state IS NULL OR geolocation_state = '' THEN TRUE 
            ELSE FALSE 
        END AS is_state_missing
        
    FROM source
    WHERE geolocation_zip_code_prefix IS NOT NULL
)

SELECT * FROM cleaned