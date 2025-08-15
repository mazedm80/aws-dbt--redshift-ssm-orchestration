WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2018-12-31' as date)"
    ) }}
),

date_dimension AS (
    SELECT 
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS date_key,
        
        -- Natural key
        date_day,
        
        -- Date parts
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(MONTH FROM date_day) AS month,
        EXTRACT(DAY FROM date_day) AS day,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        EXTRACT(DOW FROM date_day) AS day_of_week,
        EXTRACT(DOY FROM date_day) AS day_of_year,
        
        -- Formatted dates
        TO_CHAR(date_day, 'YYYY-MM') AS year_month,
        TO_CHAR(date_day, 'YYYY-Q') AS year_quarter,
        TO_CHAR(date_day, 'Day') AS day_name,
        TO_CHAR(date_day, 'Month') AS month_name,
        
        -- Business logic
        CASE 
            WHEN EXTRACT(DOW FROM date_day) IN (0, 6) THEN FALSE 
            ELSE TRUE
        END AS is_weekday,
        
        CASE 
            WHEN EXTRACT(MONTH FROM date_day) IN (12, 1, 2) THEN 'Q4-Q1 Peak'
            WHEN EXTRACT(MONTH FROM date_day) IN (6, 7) THEN 'Mid-Year'
            ELSE 'Regular'
        END AS season
        
    FROM date_spine
)

SELECT * FROM date_dimension