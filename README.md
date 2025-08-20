# AWS Redshift SSM Orchestration Demo
This project demonstrates an event-driven data ingestion and cost-effective dbt orchestration solution on AWS, leveraging Infrastructure-as-Code (Terraform) and AWS Systems Manager Automation. I have used an open source e-commerce dataset for this demo. For data modeling, I followed the Kimball methodology to create a star schema. I have also implemented Slowly Changing Dimensions (SCD) type 2.

This project includes the following components:
- AWS VPC for network isolation
  - Two private subnets
  - One public subnet
  - AWS NAT Gateway for internet access to the private subnets
  - AWS Internet Gateway for public subnet access
  - Security Groups for controlling inbound and outbound traffic
- AWS Redshift Serverless for data warehousing
- AWS S3 for data storage
  - AWS S3 Event Notifications for Redshift Auto COPY Jobs
- dbt for data transformation
  - Implemented Kimball-style dimensional modeling
  - Follow best practices for dbt project structure and modularity
  - Implement dbt models, tests, and documentation
- AWS SSM Automation for orchestration
  - AWS CloudWatch for monitoring and logging dbt jobs

## Project Structure
```
├── LICENSE
├── README.md
├── data
│   ├── ecommerce.7z
│   └── extracted
│       ├── geolocation.csv
│       ├── order_items.csv
│       ├── order_payments.csv
│       ├── order_reviews.csv
│       ├── orders.csv
│       ├── product_category_name_translation.csv
│       ├── products.csv
│       └── sellers.csv
├── dbt_redshift_ssm_demo
│   ├── README.md
│   ├── analyses
│   ├── dbt_packages
│   ├── dbt_project.yml
│   ├── logs
│   │   └── dbt.log
│   ├── macros
│   ├── models
│   │   ├── marts
│   │   │   ├── _mart__models.yml
│   │   │   ├── dim_customers.sql
│   │   │   ├── dim_date.sql
│   │   │   ├── dim_products.sql
│   │   │   ├── dim_sellers.sql
│   │   │   ├── fct_daily_order_summary.sql
│   │   │   └── fct_order_items.sql
│   │   └── staging
│   │       └── ecommerce
│   │           ├── README.md
│   │           ├── _ecommerce__models.yml
│   │           ├── _ecommerce__sources.yml
│   │           ├── stg_ecommerce__customers.sql
│   │           ├── stg_ecommerce__geolocation.sql
│   │           ├── stg_ecommerce__order_items.sql
│   │           ├── stg_ecommerce__order_payments.sql
│   │           ├── stg_ecommerce__order_reviews.sql
│   │           ├── stg_ecommerce__orders.sql
│   │           ├── stg_ecommerce__product_category_name_translation.sql
│   │           ├── stg_ecommerce__products.sql
│   │           └── stg_ecommerce__sellers.sql
│   ├── packages.yml
│   ├── profiles.yml
│   ├── requirements.txt
│   ├── seeds
│   ├── snapshots
│   │   ├── snap_customers.yml
│   │   ├── snap_products.yml
│   │   └── snap_sellers.yml
│   ├── target
│   └── tests
│       ├── assert_freight_value_is_positive.sql
│       ├── assert_order_payment_types.sql
│       ├── assert_order_status_types.sql
│       ├── assert_price_is_positive.sql
│       ├── assert_review_score_is_positive.sql
│       └── assert_review_timestamp_order_is_correct.sql
├── logs
│   └── dbt.log
├── redshift_setup.sql
├── s3_copy_data.sh
├── s3_copy_dbt_project.sh
└── terraform
    ├── environments
    │   └── dev.tfvars
    ├── main.tf
    ├── modules
    │   ├── redshift
    │   │   ├── ima.tf
    │   │   └── main.tf
    │   ├── s3
    │   │   └── main.tf
    │   ├── ssm
    │   │   ├── iam.tf
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf
```
## Getting Started
### Prerequisites
- AWS Account
- 7-Zip installed
- Terraform installed
- AWS CLI installed and configured

### Setup Instructions
1. Clone the repository
   ```bash
   git clone https://github.com/your-username/aws-dbt-redshift-ssm-orchestration.git
   cd aws-dbt-redshift-ssm-orchestration
   ```

2. Update Terraform variables
   - Edit the `terraform/environments/dev.tfvars` file to configure your environment settings.
   - Set REGION, BUCKET_NAME, and AWS_ACCOUNT_ID in the `redshift_setup.sql` file and save it.

3. Deploy the infrastructure
   ```bash
   cd terraform
   terraform init
   terraform apply -var-file=environments/dev.tfvars
   ```

4. Setup redshift auto copy jobs
Open the redshift query editor v2 and run all the sql code from the `redshift_setup.sql` file to create the copy jobs.

5. Load the data and dbt files into S3
   ```bash
   ./s3_copy_data.sh
   ./s3_copy_dbt_project.sh
   ```

6. Run SSM Automation
Log in to the AWS Management Console, navigate to Systems Manager, and execute the Automation document created by Terraform. This will orchestrate the dbt job execution. Provide the Redshift serverless endpoint, s3 bucket name, database user name, and database password as needed. Then monitor the execution logs in CloudWatch.

## Querying the Data
Once the dbt transformations are complete, you can query the data in Redshift serverless using Redshift query editor v2.

## Cleaning Up
To clean up the resources created by this project, you can run the following command in the `terraform` directory:
```bash
terraform destroy -var-file=environments/dev.tfvars
```

## Data Sources
The Brazilian E-Commerce Public Dataset by Olist is used for this project. It contains data about orders, products, customers, and reviews from a Brazilian e-commerce platform. The dataset is available on Kaggle: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).