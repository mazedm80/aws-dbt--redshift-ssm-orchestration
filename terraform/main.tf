terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source = "./modules/s3"
  env    = var.env
}

module "redshift" {
  source      = "./modules/redshift"
  env         = var.env
  bucket_name = module.s3.bucket_name
  redshift_username = var.redshift_username
  redshift_password = var.redshift_password
  security_group_id = module.vpc.security_group_id
  subnet_ids       = module.vpc.subnet_ids
}

module "vpc" {
  source = "./modules/vpc"
  env    = var.env
}