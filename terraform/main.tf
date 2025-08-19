terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source     = "./modules/s3"
  env        = var.env
  aws_region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  env    = var.env
}

module "redshift" {
  source                          = "./modules/redshift"
  env                             = var.env
  bucket_arn                      = module.s3.bucket_arn
  redshift_username               = var.redshift_username
  redshift_password               = var.redshift_password
  security_group_id               = module.vpc.security_group_id
  subnet_ids                      = module.vpc.subnet_ids
  redshift_depends_on             = [module.vpc]
  redshift_integration_depends_on = [module.s3]
}

module "ssm" {
  source            = "./modules/ssm"
  env               = var.env
  bucket_arn        = module.s3.bucket_arn
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
  ssm_depends_on    = [module.redshift]
}