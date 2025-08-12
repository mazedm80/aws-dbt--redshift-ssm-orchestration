data "aws_caller_identity" "current" {}

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

resource "aws_s3_bucket_policy" "redshift_integration_policy" {
  bucket = aws_s3_bucket.dbt-redshift-ssm-demo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Redshift-Serverless-Auto-Copy-Policy"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = [
          "s3:GetBucketNotification",
          "s3:PutBucketNotification",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.dbt-redshift-ssm-demo.arn
        Condition = {
          StringLike = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
            "aws:SourceArn" = "arn:aws:redshift:${var.aws_region}:${data.aws_caller_identity.current.account_id}:integration:*"
          }
        }
      }
    ]
  })
}

variable "env" {
    description = "Deployment environment"
    type = string
}

variable "aws_region" {
  description = "The default region."
  type        = string
}

output "bucket_arn" {
  value = aws_s3_bucket.dbt-redshift-ssm-demo.arn
}