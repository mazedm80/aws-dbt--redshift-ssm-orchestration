data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ssm_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:automation-execution/*"]
    }
  }
}
# Role for SSM
resource "aws_iam_role" "ssm_role" {
  name               = "DBT-Redshift-SSM-AutomationServiceRole"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
  tags = {
    Name        = "DBT-Redshift-SSM-AutomationServiceRole"
    Environment = var.env
  }
}

data "aws_iam_policy" "ssm_automation_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_role_policy_attachment" "ssm_automation_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = data.aws_iam_policy.ssm_automation_policy.arn
}

resource "aws_iam_role_policy" "ssm_passrole_policy" {
  name   = "DBT-Redshift-SSM-AutomationServiceRole-PassRole"
  role   = aws_iam_role.ssm_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

# Role for the EC2 instance
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Role for the EC2 instance
resource "aws_iam_role" "ec2_instance_role" {
  name               = "DBT-Redshift-SSM-EC2-Instance-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name        = "DBT-Redshift-SSM-EC2-Instance-Role"
    Environment = var.env
  }
}

data "aws_iam_policy" "ssm_instance_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch_agent_service" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_instance_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = data.aws_iam_policy.ssm_instance_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_service_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_service.arn
}

# Policy for the EC2 instance to access S3
resource "aws_iam_role_policy" "ec2_instance_policy" {
  name   = "DBT-Redshift-SSM-EC2-Instance-S3-Policy"
  role   = aws_iam_role.ec2_instance_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
        Effect = "Allow",
        Action = [
            "s3:ListBucket"
        ],
        Resource = [
            "${var.bucket_arn}"
        ],
        Condition = {
            StringLike = {
            "s3:prefix" = [
                "tools/*"
            ]
            }
        }
        },
        {
        Effect = "Allow",
        Action = [
            "s3:GetObject",
            "s3:PutObject"
        ],
        Resource = [
            "${var.bucket_arn}/tools/*"
        ]
        }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "DBT-Redshift-SSM-EC2-Instance-Profile"
  role = aws_iam_role.ec2_instance_role.id
}