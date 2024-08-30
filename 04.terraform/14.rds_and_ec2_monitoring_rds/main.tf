module "iam_instance_profile" {
  source = "./modules/iam"
  name = "${var.namespace}-iam"
  actions = ["logs:*", "rds:*"]
  resources = ["*"]
}

module "prometheus" {
  source = "./modules/prometheus"

  public_subnets       = module.networking.vpc.public_subnets
  sg                    = module.networking.sg
  iam_instance_profile  = module.iam_instance_profile.monitoring_instance_profile_name
  # private_ip_address    = module.autoscaling.private_endpoint_of_ec2
  # PRIVATE_IP_ADDRESS    = module.autoscaling.private_endpoint_of_ec2

  /* namespace                 = var.namespace */
}

module "database" {
  source    = "./modules/database"
  namespace = var.namespace

  vpc = module.networking.vpc
  sg  = module.networking.sg
  rds_monitoring_role_arn = module.iam_instance_profile.rds_monitoring_role_arn
}

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

# module "autoscaling" {
#   source      = "./modules/autoscaling"
#   namespace   = var.namespace
#   ssh_keypair = var.ssh_keypair

#   vpc                        = module.networking.vpc
#   sg                         = module.networking.sg
#   db_config                  = module.database.db_config
#   redis_endpoint             = module.redis.elasticache_replication_group_primary_endpoint_address 
#   redis_port                 = module.redis.elasticache_port 
#   iam_instance_profile_name  = module.iam_instance_profile.name
# }

