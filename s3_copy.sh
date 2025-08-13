#!/bin/bash

LOCAL_FILE=./data/ecommerce.7z
S3_TARGET_PATH=s3://dbt-redshift-ssm-demo-dev-bucket-8cd4154f/data/

# Check if file exists
if [ ! -f "$LOCAL_FILE" ]; then
  echo "Error: File '$LOCAL_FILE' does not exist."
  exit 1
fi

# Unzip the file
if [ ! -d "./data/extracted" ]; then
  echo "Extracting files..."
  7z x "$LOCAL_FILE" -o./data/extracted
fi

echo "Performing dry run..."
aws s3 sync ./data/extracted "$S3_TARGET_PATH" --dryrun

echo
read -p "Dry run complete. Proceed with actual upload? (Y/y to confirm): " CONFIRM

if [[ "$CONFIRM" == "Y" || "$CONFIRM" == "y" ]]; then
  echo "Uploading file..."
  aws s3 sync ./data/extracted "$S3_TARGET_PATH"
  echo "Upload completed."
else
  echo "Upload canceled."
fi