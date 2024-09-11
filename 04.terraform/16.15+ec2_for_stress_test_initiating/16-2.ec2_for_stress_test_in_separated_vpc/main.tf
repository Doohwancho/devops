terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# VPC Configuration
resource "aws_vpc" "stress_test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "stress-test-vpc"
  }
}

resource "aws_internet_gateway" "stress_test_igw" {
  vpc_id = aws_vpc.stress_test_vpc.id

  tags = {
    Name = "stress-test-igw"
  }
}

resource "aws_subnet" "stress_test_subnet" {
  vpc_id                  = aws_vpc.stress_test_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "stress-test-subnet"
  }
}

resource "aws_route_table" "stress_test_rt" {
  vpc_id = aws_vpc.stress_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stress_test_igw.id
  }

  tags = {
    Name = "stress-test-rt"
  }
}

resource "aws_route_table_association" "stress_test_rta" {
  subnet_id      = aws_subnet.stress_test_subnet.id
  route_table_id = aws_route_table.stress_test_rt.id
}

# Security Group
resource "aws_security_group" "stress_test_sg" {
  name        = "stress-test-sg"
  description = "Security group for stress test EC2 instance"
  vpc_id      = aws_vpc.stress_test_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "stress-test-sg"
  }
}

# IAM Role and Instance Profile
resource "aws_iam_role" "stress_test_role" {
  name = "stress-test-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "stress_test_profile" {
  name = "stress-test-profile"
  role = aws_iam_role.stress_test_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.stress_test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance
resource "aws_instance" "stress_test_instance" {
  ami = "ami-0419dc605b6dde61f"
  instance_type = "t3a.small" #AMD x86_64 architecture, 2-core 2-GiB RAM
#   ami           = "ami-0a5a6128e65676ebb"  # Amazon Linux 2 ARM64 AMI in Seoul region
#   instance_type = "t4g.small"
  subnet_id     = aws_subnet.stress_test_subnet.id

  vpc_security_group_ids      = [aws_security_group.stress_test_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.stress_test_profile.name
  associate_public_ip_address = true
  user_data = base64encode(file("./user_data.sh"))

  tags = {
    Name = "stress-test-instance"
  }
}

# Output
output "instance_id" {
  value = aws_instance.stress_test_instance.id
}

output "public_ip" {
  value = aws_instance.stress_test_instance.public_ip
}