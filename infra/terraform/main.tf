resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-artifact-store-${random_string.suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Restrictive ingress rules for application"
  vpc_id      = aws_vpc.app.id

  ingress {
    description = "HTTPS from internal VPC only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "app" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-oidc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:my-org/my-repo:ref:refs/heads/main"
        }
      }
    }]
  })
}
