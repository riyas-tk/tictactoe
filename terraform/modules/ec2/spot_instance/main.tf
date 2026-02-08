locals {
  offset                = var.valid_until_hrs != "" ? var.valid_until_hrs : "2h"
  timestamp_with_offset = timeadd(timestamp(), local.offset)
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJxyHX4DTdzo78CqM27vURU/7uf1X1sTqJSNPeuSayarbZut+whc8Q8Ks3DIIP0eqmrcHOGjVW8ZOoB1seBCOTsRQhW9ki7og3Z0hnouBeBCfGbn+anfqT5QBxXT/MMj9EcrVoNfZjVlyawWYqT9z3zZon4zd1T8XDYEQkgGHDSVLg+BUUskUqx4zb5l7SdZUxpL50j0Tt/T8PcRsEKFqmCFdCxAWHR5ePbCSmgeWHa0RuW4aQMWZe5O8QK1BQDgmvsdEFYMiYlOurHdomcX8pJ19/pcT13u2CCKIQa2gG6xUnI9rkD4GJ0nRxlNhCg0Rt4GVsXKtEKmjLSqo3rvrB riyaztevar@Riyazs-MacBook-Air.local"
}

resource "aws_instance" "spot_ec2" {
  region                 = var.region
  availability_zone      = var.availability_zone
  ami                    = var.ami_id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_id
  key_name               = aws_key_pair.ssh_key.key_name
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = var.spot_type
      instance_interruption_behavior = var.persistent_spot_settings.enabled ? "stop" : "terminate"
    }
  }

  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = 30
  }
  instance_type = var.instance_type
  tags          = var.tags
}

resource "aws_eip" "ec2_pub_ip" {
  domain     = "vpc"
  instance   = aws_instance.spot_ec2.id
  depends_on = [var.ec2_ig]
}

