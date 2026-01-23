data "aws_caller_identity" "current" {}

resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/dev-backend-s3-encryption-key"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

resource "aws_kms_key" "s3_encryption_key" {
  description             = "S3 bucket encryption master key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::953909302469:role/GhaAssumeRoleWithAction"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}