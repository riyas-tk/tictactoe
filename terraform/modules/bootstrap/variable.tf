variable "region" {
  type    = string
  default = "us-east-1"
}

variable "backend_s3_bucket" {
  type    = string
  default = "riyaz_test_backend_s3_bucket_2026"
}

variable "backend_dynamodb_table" {
  type    = string
  default = "my_backend_dynamodb_table"
}

variable "tags" {
  type = map(any)
  default = {
    Name        = "backend_resources"
    Environment = "dev"
  }
}

variable "github_repo" {
  description = "The GitHub repository in 'owner/repo' format"
  type        = string
  default     = "riyas-tk/tictactoe"
}