resource "aws_ssm_document" "dbt_redshift_ssm_automation" {
  depends_on = [var.ssm_depends_on]
  name          = "BDT_Redshift_SSM_Automation"
  document_type = "Automation"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '0.3'
description: '*Run an EC2 Instance and run dbt jobs.*'
assumeRole: ${aws_iam_role.ssm_role.arn}
parameters:
  DbtHostName:
    type: String
    description: 'Provide the url like: workgroup.account.region.redshift-serverless.amazonaws.com'
  DbtUserName:
    type: String
    description: The Redshift Serverless username.
  DbtPassword:
    type: String
    description: The Redshift Serverless user password.
  BucketName:
    type: String
    description: The S3 bucket name.
mainSteps:
  - name: DbtRedshiftSSMInstance
    action: aws:runInstances
    nextStep: PrepareInstance
    isEnd: false
    onFailure: step:TerminateInstances
    inputs:
      ImageId: ami-041e03d9b29509e94
      InstanceType: t4g.small
      SubnetId: ${var.subnet_ids[0]}
      SecurityGroupIds:
        - ${var.security_group_id}
      BlockDeviceMappings:
        - DeviceName: /dev/xvda
          Ebs:
            Encrypted: false
            DeleteOnTermination: true
            Iops: 3000
            VolumeSize: 20
            VolumeType: gp3
            Throughput: 125
      IamInstanceProfileName: DBT-Redshift-SSM-EC2-Instance-Profile
  - name: PrepareInstance
    action: aws:runCommand
    nextStep: PrepareEnvironment
    isEnd: false
    onFailure: step:TerminateInstances
    inputs:
      DocumentName: AWS-RunShellScript
      Parameters:
        commands:
          - '#!/bin/bash'
          - set -e
          - ''
          - sudo yum -y update
          - ''
          - sudo mkdir /dbt
          - aws s3 sync s3://{{ BucketName }}/tools/dbt/ /dbt
        workingDirectory: /
      InstanceIds: '{{ DbtRedshiftSSMInstance.InstanceIds }}'
      CloudWatchOutputConfig:
        CloudWatchOutputEnabled: true
  - name: PrepareEnvironment
    action: aws:runCommand
    nextStep: RunDBT
    isEnd: false
    onFailure: step:TerminateInstances
    inputs:
      DocumentName: AWS-RunShellScript
      Parameters:
        workingDirectory: /dbt
        commands:
          - '#!/bin/bash'
          - set -e
          - '# Install Python dependencies'
          - 'python3 -m ensurepip --upgrade'
          - 'python3 -m pip install --upgrade pip'
          - 'python3 -m pip install dbt-core'
          - 'pip install -r requirements.txt'
          - 'dbt deps'
      InstanceIds: '{{ DbtRedshiftSSMInstance.InstanceIds }}'
      CloudWatchOutputConfig:
        CloudWatchOutputEnabled: true
  - name: RunDBT
    action: aws:runCommand
    nextStep: RunDBTtests
    isEnd: false
    onFailure: step:TerminateInstances
    inputs:
      DocumentName: AWS-RunShellScript
      Parameters:
        workingDirectory: /dbt
        commands:
          - '#!/bin/bash'
          - set -e
          - '# Export environment variables'
          - export USER={{ DbtUserName }}
          - export PASSWORD={{ DbtPassword }}
          - export HOST={{ DbtHostName }}
          - '# Run dbt commands'
          - dbt run --profile ecommerce --target dev -s staging
          - dbt snapshot --profile ecommerce --target dev
          - dbt run --profile ecommerce --target dev -s marts
      InstanceIds: '{{ DbtRedshiftSSMInstance.InstanceIds }}'
      CloudWatchOutputConfig:
        CloudWatchOutputEnabled: true
  - name: RunDBTtests
    action: aws:runCommand
    nextStep: TerminateInstances
    isEnd: false
    onFailure: step:TerminateInstances
    inputs:
      DocumentName: AWS-RunShellScript
      Parameters:
        workingDirectory: /dbt
        commands:
          - '#!/bin/bash'
          - set -e
          - '# Export environment variables'
          - export USER={{ DbtUserName }}
          - export PASSWORD={{ DbtPassword }}
          - export HOST={{ DbtHostName }}
          - '# Run dbt tests'
          - dbt test --profile ecommerce --target dev
      InstanceIds: '{{ DbtRedshiftSSMInstance.InstanceIds }}'
      CloudWatchOutputConfig:
        CloudWatchOutputEnabled: true
  - name: TerminateInstances
    action: aws:executeAwsApi
    isEnd: true
    inputs:
      Service: ec2
      Api: TerminateInstances
      InstanceIds: '{{ DbtRedshiftSSMInstance.InstanceIds }}'

DOC

  tags = {
      Name        = "TestDocument"
      Environment = var.env
  }
}

variable "env" {
    description = "Deployment environment"
    type = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN used by Redshift"
  type        = string
}

variable "security_group_id" {
    description = "Security group ID for Redshift"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for Redshift"
    type        = list(string)
}

variable "ssm_depends_on" {
  description = "SSM dependencies"
  type        = any
}