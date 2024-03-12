provider "aws" {
  region = "ap-northeast-2"
}

locals {
  instance_name = "load-test-instance"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Create a new VPC
resource "aws_vpc" "load_test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "load-test-vpc"
  }
}

# Create IGW
resource "aws_internet_gateway" "load_test_igw" {
  vpc_id = aws_vpc.load_test_vpc.id

  tags = {
    Name = "load-test-igw"
  }
}

# Create route table for IGW

resource "aws_route_table" "load_test_rt" {
  vpc_id = aws_vpc.load_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.load_test_igw.id
  }

  tags = {
    Name = "load-test-rt"
  }
}

resource "aws_route_table_association" "load_test_rta" {
  subnet_id      = aws_subnet.load_test_subnet.id
  route_table_id = aws_route_table.load_test_rt.id
}

# Create a new subnet within the VPC
resource "aws_subnet" "load_test_subnet" {
  vpc_id     = aws_vpc.load_test_vpc.id
  cidr_block = "10.0.1.0/24"
  /* map_public_ip_on_launch = true  # did not work. could not ssh -i ubuntu@${map_public_ip_on_launch} */

  tags = {
    Name = "load-test-subnet"
  }
}

resource "aws_instance" "load_test_instance" {
  //option1)
  //aws ec2 describe-images --owners self amazon --filters "Name=architecture,Values=arm64" "Name=root-device-type,Values=ebs" --query 'Images[*].[ImageId,Name]' --output table
  //option2)
  //https://aws.amazon.com/marketplace/pp/prodview-iftkyuwv2sjxi
  ami           = data.aws_ami.ubuntu.id
  instance_type = "c7i.xlarge"
  subnet_id     = aws_subnet.load_test_subnet.id
  key_name      = "example1"  # Add this line with the name of your key pair

  iam_instance_profile    = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = local.instance_name
  }

  # depends_on = [aws_eip_association.eip_assoc] # cyclinic dependecy error

  provisioner "local-exec" {
	  command = <<EOF
	  # sleep 120
	  echo "Using IP: ${aws_eip.load_test_eip.public_ip}"
	  echo "corrected launched!"

	  # echo Pinging ${aws_eip.load_test_eip.public_ip} && ping -c 4 ${aws_eip.load_test_eip.public_ip}
	  # ansible-playbook -i '${aws_eip.load_test_eip.public_ip},' -u ubuntu --private-key ~/.ssh/example1.pem ansible/playbook.yml -vvv #error! <-- 이 코드 실행시키면, eip가 ec2 instance에 안붙음. 이 코드 실행 한시키면 정상적으로 ec2+eip 붙음.

	  EOF
	  environment = {
		  ANSIBLE_TIMEOUT = "300"
		  ANSIBLE_HOST_KEY_CHECKING = "False"
	  }
	}
}

# Security group for the EC2 instance
resource "aws_security_group" "load_test_sg" {
  name_prefix = "load-test-sg"
  vpc_id      = aws_vpc.load_test_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Associate the security group with the EC2 instance
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.load_test_sg.id
  network_interface_id = aws_instance.load_test_instance.primary_network_interface_id
}

# elastic ip
# circular dependecy error 때문에 아래 코드로 우회해서 붙인다.
/* resource "aws_eip" "load_test_eip" { */
/*   instance = aws_instance.load_test_instance.id */

/*   tags = { */
/*     Name = "${local.instance_name}-eip" */
/*   } */
/* } */


resource "aws_eip" "load_test_eip" {
  vpc = true

  tags = {
    Name = "${local.instance_name}-eip"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.load_test_instance.id
  allocation_id = aws_eip.load_test_eip.id
}

output "eip_address" {
  value = aws_eip.load_test_eip.public_ip
}


# iam role for session manager

resource "aws_iam_role" "ssm_instance_role" {
  name = "SSMInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_instance_role.name
}


