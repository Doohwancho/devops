data "aws_availability_zones" "available" {}

module "vpc" { #A
  source                           = "terraform-aws-modules/vpc/aws"
  /* version                          = "2.64.0" */
  version                          = "5.5.0"

  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"

  azs                              = data.aws_availability_zones.available.names
  private_subnets                  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets                   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets                 = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  elasticache_subnets              = ["10.0.31.0/24", "10.0.32.0/24"]

  create_database_subnet_group     = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
}

module "lb_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

module "websvr_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port            = 8080
      security_groups = [module.lb_sg.security_group.id]
    },
    {
      port        = 22 #C
      cidr_blocks = ["10.0.0.0/16"] #C
    }
  ]
}

module "db_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    port            = 3306
    security_groups = [module.websvr_sg.security_group.id]
  }]
}

module "elasticache_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port            = 6379  # Default port for Redis
      security_groups = [module.websvr_sg.security_group.id] # Allow access from your web server security group
    }
  ]
}

module "prometheus_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port        = 9090
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3000
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 80
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
	  cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      port        = 8080
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 9090
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3000
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 80
	  cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
	  cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


# allow prometheus ec2 to get metrics from private ec2's :8080/prometheus/metrics
resource "aws_security_group_rule" "prometheus_to_websvr" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.prometheus_sg.security_group.id
  source_security_group_id = module.websvr_sg.security_group.id
}

resource "aws_security_group_rule" "websvr_from_prometheus" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.websvr_sg.security_group.id
  source_security_group_id = module.prometheus_sg.security_group.id
}

