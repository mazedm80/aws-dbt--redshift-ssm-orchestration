-- Create customer table
CREATE TABLE IF NOT EXISTS public.customers 
(
    customer_id VARCHAR(256) NOT NULL,
    customer_unique_id VARCHAR(256),
    customer_zip_code_prefix BIGINT,
    customer_city VARCHAR(256),
    customer_state VARCHAR(256),
    PRIMARY KEY (customer_id)
)
DISTSTYLE KEY
DISTKEY (customer_id);
-- Create the customer COPY JOB
COPY public.customers
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/customers.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_customers_job
AUTO ON;

-- Create geolocation table
CREATE TABLE IF NOT EXISTS public.geolocation
(
    geolocation_zip_code_prefix BIGINT NOT NULL,
    geolocation_lat REAL,
    geolocation_lng REAL,
    geolocation_city VARCHAR(256),
    geolocation_state VARCHAR(256),
    PRIMARY KEY (geolocation_zip_code_prefix)
)
DISTSTYLE KEY
DISTKEY (geolocation_zip_code_prefix);
-- Create the geolocation COPY JOB
COPY public.geolocation
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/geolocation.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_geolocation_job
AUTO ON;

-- Create orders table
CREATE TABLE IF NOT EXISTS public.orders
(
    order_id VARCHAR(256) NOT NULL,
    customer_id VARCHAR(256),
    order_status VARCHAR(256),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES public.customers (customer_id)
)
DISTSTYLE KEY
DISTKEY (order_id);
-- Create the orders COPY JOB
COPY public.orders
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/orders.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_orders_job
AUTO ON;

-- Create order_payments table
CREATE TABLE IF NOT EXISTS public.order_payments
(
    order_id VARCHAR(256) NOT NULL,
    payment_sequential BIGINT,
    payment_type VARCHAR(256),
    payment_installments BIGINT,
    payment_value REAL,
    FOREIGN KEY (order_id) REFERENCES public.orders (order_id)
)
DISTSTYLE KEY
DISTKEY (order_id);
-- Create the order_payments COPY JOB
COPY public.order_payments
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/order_payments.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_order_payments_job
AUTO ON;

-- Create order_reviews table
CREATE TABLE IF NOT EXISTS public.order_reviews
(
    review_id VARCHAR(256) NOT NULL,
    order_id VARCHAR(256),
    review_score BIGINT,
    review_comment_title VARCHAR(256),
    review_comment_message VARCHAR(256),
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    PRIMARY KEY (review_id),
    FOREIGN KEY (order_id) REFERENCES public.orders (order_id)
)
DISTSTYLE KEY
DISTKEY (order_id);
-- Create the order_reviews COPY JOB
COPY public.order_reviews
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/order_reviews.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_order_reviews_job
AUTO ON;

-- Create product_category_name_translation table
CREATE TABLE IF NOT EXISTS public.product_category_name_translation
(
    product_category_name VARCHAR(256) NOT NULL,
    product_category_name_english VARCHAR(256),
    CONSTRAINT product_category_name_translation_pkey PRIMARY KEY (product_category_name)
)
DISTSTYLE KEY
DISTKEY (product_category_name);
-- Create the product_category_name_translation COPY JOB
COPY public.product_category_name_translation
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/product_category_name_translation.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_product_category_name_translation_job
AUTO ON;

-- Create products table
CREATE TABLE IF NOT EXISTS public.products
(
    product_id VARCHAR(256) NOT NULL,
    product_category_name VARCHAR(256),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    PRIMARY KEY (product_id),
    FOREIGN KEY (product_category_name) REFERENCES public.product_category_name_translation (product_category_name)
)
DISTSTYLE KEY
DISTKEY (product_id);
-- Create the products COPY JOB
COPY public.products
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/products.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_products_job
AUTO ON;

-- Create sellers table
CREATE TABLE IF NOT EXISTS public.sellers
(
    seller_id VARCHAR(256) NOT NULL,
    seller_zip_code_prefix BIGINT,
    seller_city VARCHAR(256),
    seller_state VARCHAR(256),
    PRIMARY KEY (seller_id)
)
DISTSTYLE KEY
DISTKEY (seller_id);
-- Create the sellers COPY JOB
COPY public.sellers
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/sellers.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_sellers_job
AUTO ON;

-- Create order_item table
CREATE TABLE IF NOT EXISTS public.order_items
(
    order_id VARCHAR(256) NOT NULL,
    order_item_id BIGINT,
    product_id VARCHAR(256),
    seller_id VARCHAR(256),
    shipping_limit_date TIMESTAMP,
    price REAL,
    freight_value REAL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES public.orders (order_id),
    FOREIGN KEY (product_id) REFERENCES public.products (product_id),
    FOREIGN KEY (seller_id) REFERENCES public.sellers (seller_id)
)
DISTSTYLE KEY
DISTKEY (order_id);
-- Create the order_items COPY JOB
COPY public.order_items
FROM 's3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/data/order_items.csv'
region 'eu-central-1'
IAM_ROLE 'arn:aws:iam::233999162391:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
removequotes
JOB CREATE copy_order_items_job
AUTO ON;