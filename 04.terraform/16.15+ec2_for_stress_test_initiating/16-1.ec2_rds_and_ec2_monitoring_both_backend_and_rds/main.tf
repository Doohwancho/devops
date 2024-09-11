module "iam_instance_profile" {
  source = "./modules/iam"
  name = "${var.namespace}-iam"
  actions = ["logs:*", "rds:*"]
  resources = ["*"]
}

module "ec2" {
  source      = "./modules/ec2"
  namespace   = var.namespace
  ssh_keypair = var.ssh_keypair

  vpc                        = module.networking.vpc
  sg                         = module.networking.sg
  db_config                  = module.database.db_config
  iam_instance_profile_name  = module.iam_instance_profile.name
}

module "prometheus" {
  source = "./modules/prometheus"

  public_subnets       = module.networking.vpc.public_subnets
  sg                    = module.networking.sg
  iam_instance_profile  = module.iam_instance_profile.monitoring_instance_profile_name
  private_ip_address    = module.ec2.private_endpoint_of_ec2
  PRIVATE_IP_ADDRESS    = module.ec2.private_endpoint_of_ec2

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


