terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = local.region
}


module "k8s_dev_spot_instance" {
  source = "../../modules/ec2/spot_instance"

  region            = local.region
  availability_zone = local.availability_zone
  ami_id            = "ami-024ee5112d03921e2"
  spot_type         = "one-time"
  instance_type     = "t2.micro"
  valid_until_hrs   = var.valid_until_hrs
  subnet_id         = module.ec2_vpc_infra.subnet_id
  ec2_ig            = module.ec2_vpc_infra.ig_id
  sg_id = [
    module.ec2_vpc_infra.sg_id
  ]
}
