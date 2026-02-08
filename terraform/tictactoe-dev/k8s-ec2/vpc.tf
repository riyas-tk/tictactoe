module "ec2_vpc_infra" {
  source         = "../../modules/vpc_infra"
  vpc_cidr_block = "10.0.0.0/16"
  subnet_cidr_blocks = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}