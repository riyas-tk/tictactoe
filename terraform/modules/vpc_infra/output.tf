output "vpc_id" {
  value = aws_vpc.ec2_vpc.id
}

output "subnet_id" {
  value = aws_subnet.ec2_subnet[*].id
}

output "sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "ig_id" {
  value = aws_internet_gateway.igw.id
}