provider "aws" {
  region = "ap-northeast-2"
}

# Create a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "CustomVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "CustomIGW"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "custom_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "CustomSubnet"
  }
}

# Create a route table for the VPC to allow internet access
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "CustomRouteTable"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.custom_subnet.id
  route_table_id = aws_route_table.rt.id
}

# (Optional) Create a security group that allows SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSH"
  }
}


output "custom_subnet_id" {
  value = aws_subnet.custom_subnet.id
}
