variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "instance_type" {
  type = string
}

variable "spot_type" {
  type    = string
  default = "one-time"
}

variable "persistent_spot_settings" {
  description = "persistent spot type instance settings"
  type        = map(any)
  default = {
    enabled = false
  }
}

variable "ami_id" {
  type    = string
  default = "ami-024ee5112d03921e2"
}

variable "subnet_id" {
  type = string
}

variable "ec2_ig" {
  type = string
}

variable "sg_id" {
  description = "Security group ID"
  type        = list(string)
}

variable "valid_until_hrs" {
  type    = string
  default = "2h" # Use 2 hr validity for spot request 
}

variable "tags" {
  type = map(string)
  default = {
    "ManagedBy" : "Terraform"
  }
}