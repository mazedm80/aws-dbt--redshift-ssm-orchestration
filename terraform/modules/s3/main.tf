resource "aws_s3_bucket" "dbt-redshift-ssm-demo" {
    bucket = "dbt-redshift-ssm-demo-${var.env}-bucket-${random_id.suffix.hex}"
    tags = {
        name = "DBT Redshift SSM Demo - ${var.env}"
        environment = var.env
    }
    force_destroy = true
}

resource "random_id" "suffix" {
    byte_length = 4
}

variable "env" {
    description = "Deployment environment"
    type = string
}

output "bucket_name" {
  value = aws_s3_bucket.dbt-redshift-ssm-demo.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.dbt-redshift-ssm-demo.arn
}