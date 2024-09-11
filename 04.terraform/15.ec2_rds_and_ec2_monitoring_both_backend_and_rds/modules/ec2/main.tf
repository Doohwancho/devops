resource "aws_instance" "webserver" {
  instance_type = "t4g.medium" //arm64, 2core, 4 GiB RAM
  ami           = "ami-030be76ca6c8d557a" // Your custom AMI created using packer

  user_data = base64encode(templatefile("${path.module}/user_data.sh",
    {
      rds_endpoint = var.db_config.hostname,
      rds_username = var.db_config.user,
      rds_password = var.db_config.password,
      rds_port     = var.db_config.port,
      rds_database = var.db_config.database,
    }
  ))

  key_name               = var.ssh_keypair
  iam_instance_profile   = var.iam_instance_profile_name
  vpc_security_group_ids = [var.sg.websvr]
  subnet_id              = var.vpc.public_subnets[0]  // Using the first public subnet. 앞에 alb붙이는 경우, private_subnet[0]으로 수정하여 보안 강화하자.
  associate_public_ip_address = true  // This will assign a public IP

  tags = {
    Name = "${var.namespace}-webserver"
  }
}

resource "aws_eip" "webserver" {
  instance = aws_instance.webserver.id
  domain   = "vpc"
}

/**
  below code is for alb and auto-scaling group setting
*/
/*
resource "aws_launch_template" "webserver" {
  name_prefix   = var.namespace

  //step1) https://instances.vantage.sh/?region=ap-northeast-2&selected=m7g.medium,m7a.medium,c7a.medium,c7gn.medium 
  //step2) 내가 원하는 스펙의 ec2 instance 선택
  //      2-1. RPS별 적정 ec2 instance spec
  //           원래 이 스펙이어야 함)
              // 100 RPS:
              // EC2: t3.micro (1 vCPU, 1 GB RAM) 또는 t3.small (1 vCPU, 2 GB RAM)
              // RDS: db.t3.micro (1 vCPU, 1 GB RAM) 또는 db.t3.small (1 vCPU, 2 GB RAM)

              // 1,000 RPS:
              // EC2: t3.medium (2 vCPU, 4 GB RAM) 또는 c5.xlarge (4 vCPU, 8 GB RAM)
              // RDS: db.m5.large (2 vCPU, 8 GB RAM) 또는 db.m5.xlarge (4 vCPU, 16 GB RAM)

              // 3,000 RPS:
              // EC2: c5.2xlarge (8 vCPU, 16 GB RAM) 또는 c5.4xlarge (16 vCPU, 32 GB RAM)
              // RDS: db.m5.2xlarge (8 vCPU, 32 GB RAM) 또는 db.m5.4xlarge (16 vCPU, 64 GB RAM)

              // 10,000 RPS:
              // EC2: c5.9xlarge (36 vCPU, 72 GB RAM) 또는 클러스터 구성
              // RDS: db.m5.12xlarge (48 vCPU, 192 GB RAM) 또는 클러스터 구성
  //           내 실험 - 이상하게 성능 구림. 왜지?)
  //             300RPS: 2 core, 8GiB RAM, 12.5 Gbps 네트워크 대역폭이 300 RPS를 80% cpu usage, jvm에 heap에서 쓰는 RAM은 1GiB정도. 0% fail rate, 63ms latency (RAM을 4GiB로 줄여도 될 듯)
  //             1000RPS: 
  //                ec2) 8 core, 32GiB RAM, 15 Gbps 네트워크 대역폭이 1000 RPS를 70%의 cpu usage, jvm에 heap에서 쓰는 RAM은 3GiB정도, 0.01% fail rate, 평균 115.9ms latency (렘을 줄여도 되는데, aws ec2 인스턴스 들이 cpu core가 늘어나면 렘 스펙도 비례해서 늘어나는 선택지 밖에 없더라.) 
  // .              rds) db.t4g.medium (2core 4GiB RAM, 5GiB 네트워크 대역폭)
  //step3) 해당 인스턴스가 요구하는 CPU architecture(ex. arm64) 메모 
  instance_type = "m4g.medium" //arm64, 2core, 4 GiB RAM
  // instance_type = "m7g.2xlarge" //arm64, 8core, 32 GiB RAM 

  //step3) https://cloud-images.ubuntu.com/locator/ec2/ 에서 
  //step4) AZ(ex. ap-northeast-2)넣고 찾는다. (/ecomemrce/terraform/scalable-ecommerce/providers.tf 에서 region 확인 가능)
  //step5) ubuntu18.04를 찾는다.
  //step6) 내가 원하는 instance의 architecture와 맞는 이미지의 ami-id를 뽑아서 위에 image_id 변수에 넣는다. 
    #  ex) 
    #  image_id      = "ami-059e7332a087320a3" //arm64 architecture, aws-graviton processor compatible ubuntu 20.04 
    #  image_id      = "ami-0195178fef736f4ed"//arm64 architecture, ubuntu 18.04 
    #  image_id      = "ami-0419dc605b6dde61f" //amd64 architecture, ubuntu 18.04 
    #  image_id      = data.aws_ami.ubuntu.id 
  # image_id      = "ami-????" 

  //step7) 단, 미리 preconfig한 ec2 image by using packer가 있다면, 해당 커스텀 이미지의 ami을 적으면 된다. 
  image_id      = "ami-030be76ca6c8d557a" // Your custom AMI I created using packer

  #  associate_public_ip_address = true 

  //user_data     = data.cloudinit_config.config.rendered #B <----------- 여기서 git clone해서 프로젝트 실행함.
  user_data     = base64encode(templatefile("${path.module}/user_data.sh",
	  {
		  rds_endpoint = var.db_config.hostname,
		  rds_username = var.db_config.user,
		  rds_password = var.db_config.password,
		  rds_port     = var.db_config.port,
		  rds_database = var.db_config.database,
	  }
	)) #B <----------- 여기서 git clone해서 프로젝트 실행함.


  key_name      = var.ssh_keypair
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  vpc_security_group_ids = [var.sg.websvr]
}

data "aws_instances" "webserver" {
  instance_tags = {
    "aws:ec2:groupName" = aws_autoscaling_group.webserver.name
  }
}
*/

# data "aws_instances" "webserver" {
#   instance_tags = {
#     "aws:autoscaling:groupName" = aws_autoscaling_group.webserver.name
#   }
# }

# resource "aws_autoscaling_group" "webserver" {
#   name                = "${var.namespace}-asg"
#   min_size            = 1
#   max_size            = 1 // scale out 이후, git clone, build, run할 배포 스크립트가 없기 때문에 WAS 서버 수를 1로 고정
#   vpc_zone_identifier = var.vpc.private_subnets
#   target_group_arns   = module.alb.target_group_arns
#   launch_template {
#     id      = aws_launch_template.webserver.id
#     version = aws_launch_template.webserver.latest_version
#   }
# }

# module "alb" {
#   source             = "terraform-aws-modules/alb/aws"
#   version            = "~> 5.0"
#   name               = var.namespace
#   load_balancer_type = "network" # "network" = L4, application" = L7
#   vpc_id             = var.vpc.vpc_id
#   subnets            = var.vpc.public_subnets
#   security_groups    = [var.sg.lb]

#   http_tcp_listeners = [
#     {
#       port               = 80
#       protocol           = "TCP" //for nlb, it should be one of 4: TCP, UDP, TCP_UDP, TLS
#       target_group_index = 0
#     }
#   ]

#   target_groups = [
#     { name_prefix      = "websvr"
#       backend_protocol = "TCP" # "TCP" = L4, "HTTP" = L7
#       backend_port     = 8080
#       target_type      = "instance"
#     }
#   ]
# }