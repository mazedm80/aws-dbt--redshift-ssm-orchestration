variable "aws_region" {
  description = "The default region."
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
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