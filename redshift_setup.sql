-- Create a user for dbt
CREATE USER dbt_user PASSWORD 'sha256|Dbt12345';
-- Create schemas for dbt
CREATE SCHEMA IF NOT EXISTS staging AUTHORIZATION dbt_user;
CREATE SCHEMA IF NOT EXISTS warehouse AUTHORIZATION dbt_user;
-- Grant necessary permissions to the dbt user
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dbt_user;
GRANT USAGE ON SCHEMA staging TO dbt_user;
GRANT USAGE ON SCHEMA warehouse TO dbt_user;

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
FROM 's3://BUCKET_NAME/data/customers/customers.csv'
region 'REGION'
IAM_ROLE 'arn:aws:iam::ACCOUNT_ID:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
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
FROM 's3://BUCKET_NAME/data/geolocation/geolocation.csv'
region 'REGION'
IAM_ROLE 'arn:aws:iam::ACCOUNT_ID:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
JOB CREATE copy_geolocation_job
AUTO ON;

-- Create orders table
CREATE TABLE IF NOT EXISTS public.orders
(
    order_id BIGINT NOT NULL,
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
FROM 's3://BUCKET_NAME/data/orders/orders.csv'
region 'REGION'
IAM_ROLE 'arn:aws:iam::ACCOUNT_ID:role/DBT-Redshift-SSM-Demo-Role'
delimiter ','
ignoreheader 1
acceptinvchars
JOB CREATE copy_orders_job
AUTO ON;
