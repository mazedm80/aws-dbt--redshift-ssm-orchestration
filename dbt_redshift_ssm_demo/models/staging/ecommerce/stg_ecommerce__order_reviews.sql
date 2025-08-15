WITH source AS (
    SELECT * FROM {{ source('ecommerce', 'order_reviews') }}
),

cleaned AS (
    SELECT
        review_id,
        order_id,
        CAST(review_score AS INT) AS review_score,
        TRIM(review_comment_title) AS review_comment_title,
        TRIM(review_comment_message) AS review_comment_message,
        review_creation_date,
        review_answer_timestamp,

        CASE 
            WHEN review_comment_title IS NULL OR review_comment_title = '' THEN TRUE 
            ELSE FALSE 
        END AS is_review_title_missing,

        CASE 
            WHEN review_comment_message IS NULL OR review_comment_message = '' THEN TRUE 
            ELSE FALSE 
        END AS is_review_message_missing

    FROM source
    WHERE review_id IS NOT NULL
)

SELECT * FROM cleaned