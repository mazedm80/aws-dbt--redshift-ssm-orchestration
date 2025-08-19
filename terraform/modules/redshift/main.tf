data "aws_caller_identity" "current" {}
# Create Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "dbt-redshift-ssm-demo" {
  depends_on = [ var.redshift_depends_on ]

  namespace_name = "dbt-redshift-ssm-demo-${var.env}"
  db_name = "ecommerce"
  admin_username = var.redshift_username
  admin_user_password = var.redshift_password
  iam_roles = [aws_iam_role.redshift_role.arn]

  tags = {
    Name        = "dbt-redshift-ssm-demo-${var.env}"
    Environment = var.env
  }
}
# Create Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "dbt-redshift-ssm-demo" {
  depends_on = [aws_redshiftserverless_namespace.dbt-redshift-ssm-demo]

  namespace_name = aws_redshiftserverless_namespace.dbt-redshift-ssm-demo.id
  workgroup_name = "dbt-redshift-ssm-demo-${var.env}"
  base_capacity  = 8

  security_group_ids = [ var.security_group_id ]
  subnet_ids = var.subnet_ids
  publicly_accessible = false

  tags = {
    Name        = "dbt-redshift-ssm-demo-${var.env}"
    Environment = var.env
  }
}
# Create Redshift Event Integration Resource Policy
resource "aws_redshift_resource_policy" "redshift_serverless_s3_event" {
  resource_arn = aws_redshiftserverless_namespace.dbt-redshift-ssm-demo.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = "redshift:AuthorizeInboundIntegration",
        Resource = aws_redshiftserverless_namespace.dbt-redshift-ssm-demo.arn,
        Condition = {
          StringEquals = {
            "aws:SourceArn" = var.bucket_arn
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        },
        Action = "redshift:CreateInboundIntegration",
        Resource = aws_redshiftserverless_namespace.dbt-redshift-ssm-demo.arn,
        Condition = {
          StringEquals = {
            "aws:SourceArn" = var.bucket_arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_redshiftserverless_workgroup.dbt-redshift-ssm-demo
  ]
}
# Create Redshift S3 Integration
resource "aws_redshift_integration" "s3_integration" {
  integration_name = "dbt-redshift-ssm-demo-${var.env}-s3-integration"
  source_arn = var.bucket_arn
  target_arn = aws_redshiftserverless_namespace.dbt-redshift-ssm-demo.arn
  tags = {
    Name        = "dbt-redshift-ssm-demo-${var.env}-s3-integration"
    Environment = var.env
  }

  depends_on = [
    aws_redshift_resource_policy.redshift_serverless_s3_event,
    var.redshift_integration_depends_on
  ]
}

variable "env" {
    description = "Deployment environment"
    type = string
}

variable "redshift_username" {
    description = "Redshift admin username"
    type        = string
}

variable "redshift_password" {
    description = "Redshift admin password"
    type        = string
    sensitive   = true
}

variable "security_group_id" {
    description = "Security group ID for Redshift"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for Redshift"
    type        = list(string)
}

variable "bucket_arn" {
  description = "S3 bucket ARN used by Redshift"
  type        = string
}

variable "redshift_depends_on" {
  description = "Redshift dependencies"
  type        = any
}

variable "redshift_integration_depends_on" {
  description = "Redshift integration dependencies"
  type        = any
}