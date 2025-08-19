#!/bin/bash

DBT_PATH=./dbt_redshift_ssm_demo
S3_TARGET_PATH=s3://dbt-redshift-ssm-demo-dev-bucket-dd5d9e78/tools/dbt/

# Check if directory exists
if [ ! -d "$DBT_PATH" ]; then
  echo "Error: Directory '$DBT_PATH' does not exist."
  exit 1
fi

echo "Performing dry run..."
aws s3 sync "$DBT_PATH" "$S3_TARGET_PATH" \
    --exclude "dbt_packages/*" \
    --exclude "target/*" \
    --dryrun

echo
read -p "Dry run complete. Proceed with actual upload? (Y/y to confirm): " CONFIRM

if [[ "$CONFIRM" == "Y" || "$CONFIRM" == "y" ]]; then
  echo "Uploading directory..."
  aws s3 sync "$DBT_PATH" "$S3_TARGET_PATH" \
      --exclude "dbt_packages/*" \
      --exclude "target/*"
  echo "Upload completed."
else
  echo "Upload canceled."
fi