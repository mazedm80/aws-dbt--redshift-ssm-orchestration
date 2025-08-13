resource "aws_vpc" "dbt-redshift-ssm-demo-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "DBT-Redshift-SSM-Demo-VPC"
    Environment = var.env
  }
}

resource "aws_subnet" "dbt-redshift-ssm-demo-subnet-az1" {
  vpc_id     = aws_vpc.dbt-redshift-ssm-demo-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "DBT-Redshift-SSM-Demo-Subnet-AZ1"
    Environment = var.env
  }
}

resource "aws_subnet" "dbt-redshift-ssm-demo-subnet-az2" {
  vpc_id     = aws_vpc.dbt-redshift-ssm-demo-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "DBT-Redshift-SSM-Demo-Subnet-AZ2"
    Environment = var.env
  }
}

resource "aws_subnet" "dbt-redshift-ssm-demo-subnet-az3" {
  vpc_id     = aws_vpc.dbt-redshift-ssm-demo-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "DBT-Redshift-SSM-Demo-Subnet-AZ3"
    Environment = var.env
  }
}

resource "aws_security_group" "dbt-redshift-ssm-demo-sg" {
  depends_on = [ aws_vpc.dbt-redshift-ssm-demo-vpc ]

  name        = "DBT-Redshift-SSM-Demo-SG"
  description = "Security group for DBT Redshift SSM Demo"
  vpc_id     = aws_vpc.dbt-redshift-ssm-demo-vpc.id

  tags = {
    Name        = "DBT-Redshift-SSM-Demo-SG"
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "dbt-redshift-ssm-demo-ingress" {
  security_group_id = aws_security_group.dbt-redshift-ssm-demo-sg.id
  ip_protocol       = "tcp"
  from_port         = 5439
  to_port           = 5439
  cidr_ipv4         = "10.0.0.0/16"
  description       = "Allow Redshift access"
}

variable "env" {
    description = "Deployment environment"
    type = string
}

output "subnet_ids" {
  value = [
    aws_subnet.dbt-redshift-ssm-demo-subnet-az1.id,
    aws_subnet.dbt-redshift-ssm-demo-subnet-az2.id,
    aws_subnet.dbt-redshift-ssm-demo-subnet-az3.id
  ]
}

output "security_group_id" {
  value = aws_security_group.dbt-redshift-ssm-demo-sg.id  
}