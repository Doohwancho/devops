module "iam_instance_profile" {
  source = "./modules/iam"
  name = "${var.namespace}-iam"
  actions = ["logs:*", "rds:*"]
  resources = ["*"]
}

module "autoscaling" {
  source      = "./modules/autoscaling"
  namespace   = var.namespace
  ssh_keypair = var.ssh_keypair

  vpc       = module.networking.vpc
  sg        = module.networking.sg
  db_config = module.database.db_config
  iam_instance_profile_name = module.iam_instance_profile.name
}

module "database" {
  source    = "./modules/database"
  namespace = var.namespace

  vpc = module.networking.vpc
  sg  = module.networking.sg

}

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "prometheus" {
  source = "./modules/prometheus"

  public_subnets       = module.networking.vpc.public_subnets
  sg                    = module.networking.sg
  iam_instance_profile  = module.iam_instance_profile
  /* namespace                 = var.namespace */
}


module "redis" {
  source = "./modules/elasticache"

  name_prefix        = "redis-basic-example"
  num_cache_clusters = 2
  node_type          = "cache.t4g.small"

  engine_version           = "7.0"
  port                     = 6379
  maintenance_window       = "mon:03:00-mon:04:00"
  snapshot_window          = "04:00-06:00"
  snapshot_retention_limit = 7

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = false //encryption을 true로 할 경우, private ec2에서 redis-cli로 접속 불가능하다.
  transit_encryption_enabled = false //set to 'Yes'. This meant my database endpoint needed to be accessed through an SSL tunnel, which redis-cli does not do

  apply_immediately = true
  family            = "redis7"
  description       = "Test elasticache redis."

  vpc_id     = module.networking.vpc.vpc_id
  subnet_ids = module.networking.vpc.elasticache_subnets

  allowed_security_groups = [module.networking.sg.elasticache]

  ingress_cidr_blocks = ["0.0.0.0/0"]

  parameter = [
    {
      name  = "repl-backlog-size"
      value = "16384"
    }
  ]

  log_delivery_configuration = [
    {
      destination_type = "cloudwatch-logs"
      destination      = "aws_cloudwatch_log_group.henrique.name"
      log_format       = "json"
      log_type         = "engine-log"
    }
  ]

  tags = {
    Project     = "Github"
    Environment = "test"
  }
}


