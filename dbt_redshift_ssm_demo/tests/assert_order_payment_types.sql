-- Test if order payment types are valid
SELECT order_id
FROM {{ ref('stg_ecommerce__order_payments') }}
WHERE payment_type NOT IN ('credit_card', 'debit_card', 'boleto', 'voucher', 'not_defined')
