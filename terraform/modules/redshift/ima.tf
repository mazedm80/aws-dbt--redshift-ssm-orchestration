data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "redshift_role" {
  name               = "DBT-Redshift-SSM-Demo-Role"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
  tags = {
    Name        = "DBT-Redshift-SSM-Demo-Role"
    Environment = var.env
  }
}

resource "aws_iam_role_policy" "redshift_s3_policy" {
  name   = "DBT-Redshift-SSM-Demo-S3-Policy"
  role   = aws_iam_role.redshift_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.bucket_arn}/data/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "${var.bucket_arn}"
        Condition = {
          StringLike = {
            "s3:prefix" = "data/*"
          }
        }
      }
    ]
  })
}

output "redshift_role_arn" {
  value = aws_iam_role.redshift_role.arn
}