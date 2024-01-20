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
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.sg.prometheus]
  subnet_id              = var.public_subnets[0]
  iam_instance_profile   = var.iam_instance_profile.name
  /* user_data              = templatefile("prometheus-install.sh.tftpl", { tfe_tag_name = var.tfe_tag_name, aws_region = var.aws_region }) */
  tags = {
    "Name" = "prometheus_instance"
  }
}

resource "aws_eip" "prometheus_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.prometheus_instance.id
  allocation_id = aws_eip.prometheus_eip.id
}



################

/* module "autoscaling" { */
/*   source      = "./modules/autoscaling" */
/*   namespace   = var.namespace */
/*   ssh_keypair = var.ssh_keypair */

/*   vpc       = module.networking.vpc */
/*   sg        = module.networking.sg */
/*   db_config = module.database.db_config */
/*   iam_instance_profile_name = module.iam_instance_profile.name */
/* } */





/* ################## */
/* data "cloudinit_config" "config" { */
/*   gzip          = true # cloud_init content should be gzip compressed */
/*   base64_encode = true # cloud_init content should be based64_encoded */
/*   part { */
/*     content_type = "text/cloud-config" */
/*     content      = templatefile("${path.module}/cloud_config.yaml", var.db_config) #B <----------- 여기서 git clone해서 프로젝트 실행함. */
/*   } */
/* } */

/* data "aws_ami" "ubuntu" { */
/*   most_recent = true */
/*   filter { */
/*     name   = "name" */
/*     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] */
/*   } */
/*   owners = ["099720109477"] # Restricts the search to AMIs owned by the specified AWS account (commonly used for official images */
/* } */

/* resource "aws_launch_template" "webserver" { */
/*   name_prefix   = var.namespace */
/*   image_id      = data.aws_ami.ubuntu.id */
/*   instance_type = "t2.micro" */
/*   user_data     = data.cloudinit_config.config.rendered #B <----------- 여기서 git clone해서 프로젝트 실행함. */
/*   key_name      = var.ssh_keypair */
/*   iam_instance_profile { */
/*     name = var.iam_instance_profile_name */
/*   } */
/*   vpc_security_group_ids = [var.sg.websvr] */
/* } */

/* resource "aws_autoscaling_group" "webserver" { */
/*   name                = "${var.namespace}-asg" */
/*   min_size            = 1 */
/*   max_size            = 3 */
/*   vpc_zone_identifier = var.vpc.private_subnets */
/*   target_group_arns   = module.alb.target_group_arns */
/*   launch_template { */
/*     id      = aws_launch_template.webserver.id */
/*     version = aws_launch_template.webserver.latest_version */
/*   } */
/* } */

/* module "alb" { */
/*   source             = "terraform-aws-modules/alb/aws" */
/*   version            = "~> 5.0" */
/*   name               = var.namespace */
/*   load_balancer_type = "application" */
/*   vpc_id             = var.vpc.vpc_id */
/*   subnets            = var.vpc.public_subnets */
/*   security_groups    = [var.sg.lb] */

/*   http_tcp_listeners = [ */
/*     { */
/*       port               = 80 */
/*       protocol           = "HTTP" */
/*       target_group_index = 0 */
/*     } */
/*   ] */

/*   target_groups = [ */
/*     { name_prefix      = "websvr" */
/*       backend_protocol = "HTTP" */
/*       backend_port     = 8080 */
/*       target_type      = "instance" */
/*     } */
/*   ] */
/* } */
