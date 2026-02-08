# Define the VPC
resource "aws_vpc" "ec2_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = var.tags
}

resource "random_shuffle" "random_zone_selector" {
  input = var.azs
}

# Create Subnet
resource "aws_subnet" "ec2_subnet" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.ec2_vpc.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = random_shuffle.random_zone_selector.result[count.index] # randomn zone from list

  tags = var.tags
}

#  Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Route Table & Association
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ec2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.tags
}

resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.ec2_subnet[0].id
  route_table_id = aws_route_table.public_rt.id
}

# Network ACL (NACL)
resource "aws_network_acl" "ec2_subnet_nacl" {
  vpc_id     = aws_vpc.ec2_vpc.id
  subnet_ids = [aws_subnet.ec2_subnet[0].id]

  tags = var.tags
}

# NACL Rules
# Allow Inbound SSH (Port 22)
resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.ec2_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Consider restricting to your IP
  from_port      = 22
  to_port        = 22
}

# Open Inbound SSH ephemeral port range
resource "aws_network_acl_rule" "allow_ephemeral_inbound" {
  network_acl_id = aws_network_acl.ec2_subnet_nacl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Consider restricting to your IP
  from_port      = 1024
  to_port        = 65535
}

# Allow all outbound traffic
resource "aws_network_acl_rule" "allow_ipv4_outbound" {
  network_acl_id = aws_network_acl.ec2_subnet_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "allow_ipv6_outbound" {
  network_acl_id  = aws_network_acl.ec2_subnet_nacl.id
  rule_number     = 200
  egress          = true
  protocol        = "-1"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
}

# Create the Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.ec2_vpc.id

  # Inbound Rule
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change to your IP for better security
  }

  # Outbound Rule (Allow all traffic by default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}