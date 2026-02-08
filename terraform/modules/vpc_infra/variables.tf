variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_blocks" {
  type = list(string)
}

variable "tags" {
  type = map(string)
  default = {
    "ManagedBy" : "Terraform"
  }
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}