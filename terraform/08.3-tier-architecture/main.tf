
####################
##### provider #####
####################

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

################
##### VPC  #####
################


resource "aws_vpc" "vpc_01" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default" # they will be launched as shared (multi-tenant) hardware by default
  enable_dns_hostnames = true # allows instances in the VPC to receive a DNS hostname

  tags = {
    Name = "central-network"
  }
}


######################
## Public Subnet- 1 ##
#####################

resource "aws_subnet" "public-web-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.public-web-subnet-1-cidr # variables.tf에 명시되어있음. vpc에 cidr 네트워크 주소 나눈게 적혀있음
  availability_zone       = "us-east-1a" # HA를 위해 AZ를 2군데 다른 곳으로 둔다.
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

######################
## Public Subnet- 2 ##
#####################

resource "aws_subnet" "public-web-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.public-web-subnet-2-cidr # variables.tf에 명시되어있음. vpc에 cidr 네트워크 주소 나눈게 적혀있음
  availability_zone       = "us-east-1b" # HA를 위해 AZ를 2군데 다른 곳으로 둔다.
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

##########################
###    Private Subnet-1  ##
##########################

resource "aws_subnet" "private-app-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-app-subnet-1-cidr  # variables.tf에 명시되어있음. vpc에 cidr 네트워크 주소 나눈게 적혀있음
  availability_zone       = "us-east-1a" # HA를 위해 AZ를 2군데 다른 곳으로 둔다.
  map_public_ip_on_launch = false # private subnet이니까 public ip 부여하지 않는다.

  tags = {
    Name = "Private Subnet 1 | App Tier"
  }
}

##########################
###    Private Subnet-2  ##
##########################

resource "aws_subnet" "private-app-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-app-subnet-2-cidr # variables.tf에 명시되어있음. vpc에 cidr 네트워크 주소 나눈게 적혀있음
  availability_zone       = "us-east-1b" # HA를 위해 AZ를 2군데 다른 곳으로 둔다.
  map_public_ip_on_launch = false # private subnet이니까 public ip 부여하지 않는다.

  tags = {
    Name = "Private Subnet 2 | App Tier"
  }
}

##########################
###    Private Subnet-db 1 ##
##########################

resource "aws_subnet" "private-db-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-db-subnet-1-cidr # variables.tf에 명시되어있음. vpc에 cidr 네트워크 주소 나눈게 적혀있음
  availability_zone       = "us-east-1a" # HA를 위해 AZ를 2군데 다른 곳으로 둔다.
  map_public_ip_on_launch = false # private subnet이니까 public ip 부여하지 않는다.

  tags = {
    Name = "Private Subnet 1 | Db Tier"
  }
}

##########################
###    Private Subnet-db 2  ##
##########################

resource "aws_subnet" "private-db-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-db-subnet-2-cidr # variables.tf에 명시되어있음. vpc에 cidr 네트워크 주소 나눈게 적혀있음
  availability_zone       = "us-east-1b" # HA를 위해 AZ를 2군데 다른 곳으로 둔다.
  map_public_ip_on_launch = false # private subnet이니까 public ip 부여하지 않는다.

  tags = {
    Name = "Private Subnet 2 | Db Tier"
  }
}


################
##### IGW  #####
################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "Test IGW"
  }
}


############################
##   Web app load balancer ##
#############################
resource "aws_lb" "application-load-balancer" {
  name                       = "web-external-load-balancer"
  internal                   = false # true means load balancer is internet, false is internet-facing
  load_balancer_type         = "application" # application load balancer(L7) 인지 network load balancer(L4)인지
  security_groups            = [aws_security_group.alb-security-group.id]
  subnets                    = [aws_subnet.public-web-subnet-1.id, aws_subnet.public-web-subnet-2.id]
  enable_deletion_protection = false

  tags = {
    Name = "App load balancer"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "appbalancertg"
  port     = 80
  protocol = "HTTP" # http :80포트로 받는 애들을 받겠다~
  vpc_id   = aws_vpc.vpc_01.id
}

resource "aws_lb_target_group_attachment" "web-attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.PublicWebTemplate.id # http 80 port로 받은걸 ec2로 보내겠다~
  port             = 80
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



# create a listener on port 443 with forward action
/*resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}*/

/*resource "aws_lb_target_group_attachment" "web-attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.PublicWebTemplate.id
  port             = 80
  */

# depends_on = [
#   aws_instance.web-instance
# ]


/*resource "aws_lb_listener" "web-listener" {
#  load_balancer_arn = aws_lb.web-load-balancer.arn
#  port              = 80
#  protocol          = "http"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}*/


#####################
#   NAT Gateway #
#####################

resource "aws_eip" "eip_nat" { # eip = elastic ip address for dynamic cloud instances
  vpc = true

  tags = {
    Name = "eip1"
  }
}

# goal of NAT gateway
# A NAT Gateway enables instances in a private subnet to initiate outbound traffic to the internet (for updates, downloading packages, etc.) while preventing unsolicited inbound traffic from the internet

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.eip_nat.id # elastic ip address used for nat gateway in this example
  subnet_id     = aws_subnet.public-web-subnet-2.id # public subnet과 연결해놔야 inbound는 막으면서 outbound through igw 할 수 있음(ex. git clone같은거 할 때)

  tags = {
    "Name" = "nat1"
  }
}





##########################
###    Route Table  ##
##########################

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0" # public route table이니까 gateway의 ip인 0.0.0.0 으로 보냄
    gateway_id = aws_internet_gateway.igw.id # public route table은 internet geteway와 붙임
  }

  tags = {
    Name = "Public Route Table"
  }
}

##################################
###    Route table association  ##
#################################

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public-web-subnet-1.id # public route table과 public subnet과 붙임
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id      = aws_subnet.public-web-subnet-2.id # HA때문에 public subnet이 2개니까, 두번째 public subnet도 붙임
  route_table_id = aws_route_table.public-route-table.id
}


##########################
###    Route Table      ##
##########################

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id # private route table은 nat gateway와 붙인다. private ec2 inside private subnet will go thorugh private-route-table to nat gateway to igw for things like git clone. but nat gateway prevents inbound access.
  }

  tags = {
    Name = "Private Route Table"
  }
}

##############################
#  Route Assoc. for App tier #
##############################
resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_subnet.private-app-subnet-1.id # HA라 다른 AZ에 private subnet for WAS 2개라 각각 private route table에 붙임
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "nat_route_2" {
  subnet_id      = aws_subnet.private-app-subnet-2.id # HA라 다른 AZ에 private subnet for WAS 2개라 각각 private route table에 붙임
  route_table_id = aws_route_table.private-route-table.id
}

##############################
#  Route Assoc. for DB tier #
##############################

resource "aws_route_table_association" "nat_route_db_1" {
  subnet_id      = aws_subnet.private-db-subnet-1.id # HA라 다른 AZ에 private subnet for db 2개라 각각 private route table에 붙임
  route_table_id = aws_route_table.private-route-table.id
}


resource "aws_route_table_association" "nat_route_db_2" {
  subnet_id      = aws_subnet.private-db-subnet-2.id # HA라 다른 AZ에 private subnet for db 2개라 각각 private route table에 붙임
  route_table_id = aws_route_table.private-route-table.id
}



###################################
## SG Application Load Balancer ###
###################################
resource "aws_security_group" "alb-security-group" {
  name        = "ALB Security Group"
  description = "Enable http/https access on port 80/443"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
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
    Name = "ALB Security group"
  }
}


###################################
## SG Presentation Tier         ###
###################################
resource "aws_security_group" "webserver-security-group" {
  name        = "Web server Security Group"
  description = "Enable http/https access on port 80/443 via ALB and ssh via ssh sg"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-security-group.id}"]
  }

  ingress {
    description     = "https access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-security-group.id}"]
  }
  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web server Security group"
  }
}


##################################
## SG Application Tier (Bastion Host) ###
###################################

resource "aws_security_group" "ssh-security-group" {
  name        = "SSH Access"
  description = "Enable ssh access on port 22"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh-locate}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh Security group"
  }
}

###################################
## SG  Database Tier         ###
###################################

resource "aws_security_group" "database-security-group" {
  name        = "Database server Security Group"
  description = "Enable MYSQL access on port 3306"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "MYSQL access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webserver-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database Security group"
  }
}


##################################
#### ASG for Presentation Tier ###
##################################

resource "aws_launch_template" "auto-scaling-group" {
  name_prefix   = "auto-scaling-group"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = "source_key"
  network_interfaces {
    subnet_id       = aws_subnet.public-web-subnet-1.id
    security_groups = [aws_security_group.webserver-security-group.id]
  }
}

resource "aws_autoscaling_group" "asg-1" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.auto-scaling-group.id
    version = "$Latest"
  }
}

##################################
#### ASG for Application Tier ###
##################################

resource "aws_launch_template" "auto-scaling-group-private" {
  name_prefix   = "auto-scaling-group-private"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = "source_key"

  network_interfaces {
    subnet_id       = aws_subnet.private-app-subnet-1.id
    security_groups = [aws_security_group.ssh-security-group.id]
  }
}

resource "aws_autoscaling_group" "asg-2" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.auto-scaling-group-private.id
    version = "$Latest"
  }
}

########################
###    Data source   ###
########################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
#########################################
###    Ec2 Instance Presentation Tier ###
#########################################


resource "aws_instance" "PublicWebTemplate" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-web-subnet-1.id
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
  key_name               = "source_key" # aws에 ec2들어가서 네트워크/보안 탭에 create key 로 RSA 키 생성 후 여기 디렉토리에 .pem 파일 옮겨놓자.
  user_data              = file("install-apache.sh") # 여기에서 파일 빌드 가능

  tags = {
    Name = "web-asg"
  }
}



##############################
#### EC2 instance App Tier ###
##############################


resource "aws_instance" "private-app-template" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-app-subnet-1.id
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  key_name               = "source_key" # aws에 ec2들어가서 네트워크/보안 탭에 create key 로 RSA 키 생성 후 여기 디렉토리에 .pem 파일 옮겨놓자.
#  user_data              = file("install-apache.sh") # 여기에서 파일 빌드 가능

  tags = {
    Name = "app-asg"
  }
}


#################################
####  database subnet group #####
#################################
resource "aws_db_subnet_group" "database-subnet-group" {
  name        = "database subnets"
  subnet_ids  = [aws_subnet.private-db-subnet-1.id, aws_subnet.private-db-subnet-2.id]
  description = "Subnet group for database instance"

  tags = {
    Name = "Database Subnets"
  }
}
#################################
####  database instance      #####
#################################
resource "aws_db_instance" "database-instance" { # TODO - master/slave replication how?
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.28" # previously "5.7"
  instance_class         = var.database-instance-class
  name                   = "ecommerce"
  username               = "doohwancho"
  password               = "doohwancho"
  parameter_group_name   = "default.mysql8.0" # "default.mysql5.7"
  skip_final_snapshot    = true
  availability_zone      = "us-east-1b"
  db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.name
  multi_az               = var.multi-az-deployment
  vpc_security_group_ids = [aws_security_group.database-security-group.id]
}
