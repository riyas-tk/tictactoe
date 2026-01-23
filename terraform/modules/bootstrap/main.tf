terraform {
  # No backend block here initially; defaults to local state
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
