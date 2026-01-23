
provider "aws" {
  region = "us-east-1" # Use your desired region
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "${var.region}-${var.backend_s3_bucket}"

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.terraform_state_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.backend_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


data "aws_iam_policy_document" "terraform_state_bucket_policy" {
  statement {
    sid    = "AllowDeploymentRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GhaAssumeRoleWithAction"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_state_bucket.arn,
      "${aws_s3_bucket.terraform_state_bucket.arn}/*",
    ]
  }

  statement {
    sid    = "AllowAccountFullAccess"
    effect = "Allow"

    principals {
      type = "AWS"
      # This ARN represents the account itself and grants access to all IAM users/roles in it
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.terraform_state_bucket.arn,
      "${aws_s3_bucket.terraform_state_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "attach_policy" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  policy = data.aws_iam_policy_document.terraform_state_bucket_policy.json
}