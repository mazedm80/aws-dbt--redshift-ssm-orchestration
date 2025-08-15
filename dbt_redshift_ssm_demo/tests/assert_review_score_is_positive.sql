-- Test if review scores are positive
SELECT order_id
FROM {{ ref('stg_ecommerce__order_reviews') }}
WHERE review_score < 0