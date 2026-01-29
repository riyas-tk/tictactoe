# Reference the existing OIDC Provider for GitHub 
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Create the Trust Policy Document
data "aws_iam_policy_document" "github_deploy_policy" {
  statement {
    sid     = "GithubOIDCAuth"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Create the IAM Role
resource "aws_iam_role" "github_deployment_role" {
  name               = "GhaAssumeRoleWithAction"
  assume_role_policy = data.aws_iam_policy_document.github_deploy_policy.json
}



# Define the Multi-Service Policy Document
data "aws_iam_policy_document" "deployment_policy_doc" {
  # S3 Permissions
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = ["*"] # Narrow this to specific buckets for better security
  }
  # IAM Permissions (Required if your TF creates roles/policies)
  statement {
    sid    = "IAMAccess"
    effect = "Allow"
    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:AttachRolePolicy"
    ]
    resources = ["*"]
  }
  # KMS Permissions (For encryption/decryption)
  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  # DynamoDB Permissions (Often used for Terraform state locking)
  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }
}

# Create the IAM Policy Resource
resource "aws_iam_policy" "deployment_policy" {
  name        = "CombinedDeploymentPolicy"
  description = "Permissions for S3, IAM, KMS, and DynamoDB"
  policy      = data.aws_iam_policy_document.deployment_policy_doc.json
}

# Attach the Policy to your GitHub Role
resource "aws_iam_role_policy_attachment" "attach_to_github_role" {
  role       = aws_iam_role.github_deployment_role.name # Uses the role we created earlier
  policy_arn = aws_iam_policy.deployment_policy.arn
}