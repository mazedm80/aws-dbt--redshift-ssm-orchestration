-- Test if review timestamps are valid
SELECT order_id
FROM {{ ref('stg_ecommerce__order_reviews') }}
WHERE review_creation_date > review_answer_timestamp
