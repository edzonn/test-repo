provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

resource "aws_s3_bucket" "da-mlops-test001-s3-bucket" {
    bucket = "da-mlops-test00981-s3-bucket"
    acl = "private"
    versioning {
        enabled = true
    }
    tags = {
        Name = "da-mlops-test001-s3-bucket"
    }
  lifecycle_rule {
    enabled = false
  }
}

# IAM policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy for accessing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::da-mlops-test00981-s3-bucket",
          "arn:aws:s3:::da-mlops-test00981-s3-bucket/*",
        ],
      },
    ],
  })
}

# IAM role to assume for S3 access
resource "aws_iam_role" "s3_access_role" {
  name = "S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::754550862715:root",
        },
        Action    = "sts:AssumeRole",
      },
    ],
  })
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.s3_access_role.name
}
