data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "prometheus_instance" {
  //step1) 원하는 region에 내가 원하는 RAM/CPU core 수/가격의 ec2 instance 정하기 from https://instances.vantage.sh/?region=ap-northeast-2&selected=m7g.medium,m7a.medium,c7a.medium,c7gn.medium,t3.small
  //step2) 주의!) pmm/server를 다운받을건데, arm64 architecture는 지원 안함! amd64만 가능함.
  //step3) https://cloud-images.ubuntu.com/locator/ec2/ 에서 
  //step4) AZ(ex. ap-northeast-2)넣고 찾는다. (/ecomemrce/terraform/scalable-ecommerce/providers.tf 에서 region 확인 가능)
  //step5) ubuntu18.04를 찾는다.
  //step6) 내가 원하는 instance의 architecture와(ex. arm64, amd64) 확인한다. 
  //step7) instance type이 hvm:ebs-ssd인지 확인한다. 
  //step8) 해당 조건이 맞는 이미지의 ami-id를 뽑아서 ami 변수에 넣는다. 

  #case1) t2.micro (그냥 한개의 ec2를 docker로 monitoring하기 적합함. 하지만 pmm/server 까지 돌리면 서버 뻥나는 스펙, 1 GiB RAM, 1 CPU-core)
  # ami =  "ami-0419dc605b6dde61f" //ubuntu 18.04
  # instance_type          = "t2.micro"

  #case2) t4g.medium (4 GiB RAM, 2 CPU-core, arm64), 넉넉한 스펙
  ami = "ami-0419dc605b6dde61f"
  instance_type = "t3a.medium" #AMD x86_64 architecture, 2-core 4-GiB RAM
  
  vpc_security_group_ids = [var.sg.prometheus]
  subnet_id              = var.public_subnets[0]
  iam_instance_profile   = var.iam_instance_profile
  # user_data = base64encode(file("${path.module}/user_data.sh"))
  user_data = base64encode(templatefile("${path.module}/user_data.sh",
	  {
		  PRIVATE_IP_ADDRESS=var.PRIVATE_IP_ADDRESS,
      private_ip_address=var.private_ip_address
	  }
  ))
  tags = {
    "Name" = "prometheus_grafana_instance"
  }
}

resource "aws_eip" "prometheus_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.prometheus_instance.id
  allocation_id = aws_eip.prometheus_eip.id
}
