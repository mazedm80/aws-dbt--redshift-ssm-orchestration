resource "aws_redshiftserverless_namespace" "dbt-redshift-ssm-demo" {
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

resource "aws_redshiftserverless_workgroup" "serverless" {
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