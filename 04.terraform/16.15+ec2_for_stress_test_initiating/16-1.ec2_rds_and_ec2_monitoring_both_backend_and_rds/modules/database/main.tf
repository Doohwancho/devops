# 임의로 database connections 숫자 조절할 때 사용(권장하지 않음)
resource "aws_db_parameter_group" "my-rds-parameter-group" { 
  name        = "${var.namespace}-mysql-parameters" 
  family      = "mysql8.0"  # Ensure this matches your database engine version */
  description = "Custom parameter group for ${var.namespace}" 

  parameter {
    name  = "performance_schema"
    value = "1"
    apply_method = "pending-reboot" # performance_schema 활성화는 database instance reboot to take effect

  # Connections 숫자 조절은 manual하게 하기 보다는 RDS 스펙업을 하는게 recommended
  #   name  = "max_connections" 
  #   value = 75 
  }

  lifecycle {
    create_before_destroy = true
  }
} 

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  /*
  # https://instances.vantage.sh/rds/?region=ap-northeast-2&selected=m7g.medium,m7a.medium,c7a.medium,c7gn.medium,t3.small
    // 100 RPS:
    // EC2: t3.micro (1 vCPU, 1 GB RAM) 또는 t3.small (1 vCPU, 2 GB RAM)
    // RDS: db.t3.micro (1 vCPU, 1 GB RAM) 또는 db.t3.small (1 vCPU, 2 GB RAM)

    // 1,000 RPS:
    // EC2: t3.medium (2 vCPU, 4 GB RAM) 또는 c5.xlarge (4 vCPU, 8 GB RAM)
    // RDS: db.m5.large (2 vCPU, 8 GB RAM) 또는 db.m5.xlarge (4 vCPU, 16 GB RAM)

    // 3,000 RPS:
    // EC2: c5.2xlarge (8 vCPU, 16 GB RAM) 또는 c5.4xlarge (16 vCPU, 32 GB RAM)
    // RDS: db.m5.2xlarge (8 vCPU, 32 GB RAM) 또는 db.m5.4xlarge (16 vCPU, 64 GB RAM)
  */
  instance_class         = "db.m5.large" # intel 64x, 2 vCPU core, 8 GiB RAM, 원래는 최대 1000RPS까지 견뎌야 하나, 현 프로젝트에 stress_test 1000 RPS 테스트 결과, cpu 100% 찍고 사망
                                         # "db.m6g.2xlarge" # AWS Graviton2 processor, 8 vCPU core, 32 GiB RAM, 1000RPS까지 견딤 
  identifier             = "${var.namespace}-db-instance"
  db_name                = "ecommerce"
  username               = "admin"
  /* password               = random_password.password.result */
  password               = "adminPassword"
  db_subnet_group_name   = var.vpc.database_subnet_group 
  vpc_security_group_ids = [var.sg.db, var.sg.prometheus] 
  skip_final_snapshot    = true

  # Enable Enhanced Monitoring for PMM monitoring
  monitoring_interval = 60  # Collect metrics every 60 seconds
  monitoring_role_arn = var.rds_monitoring_role_arn

  # Associate the custom parameter group with the RDS instance
  parameter_group_name = aws_db_parameter_group.my-rds-parameter-group.name

  # This will force a reboot when the parameter group is changed
  apply_immediately = true

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# error나서 수동으로 직접 session manager로 prometheus ec2 server에 접속하고, 거기서 rds로 접속해서 직접 만들어야 함
# 에러 원인은 permission setting을 해줘야 하는데 거기서 막힘. 
# rds를 public access 가능으로 바꾸면 된다곤 하는데, 그러면 보안상 문제가 생기기 때문에 그 방법을 쓰면 안된다.
# resource "null_resource" "db_setup" {
#   depends_on = [aws_db_instance.database]

#   provisioner "local-exec" {
#     command = <<EOT
#       mysql -h ${aws_db_instance.database.endpoint} -P 3306 -u ${aws_db_instance.database.username} -p${aws_db_instance.database.password} <<EOF
#       CREATE USER 'pmm'@'%' IDENTIFIED BY 'pass';
#       GRANT SELECT, PROCESS, REPLICATION CLIENT ON *.* TO 'pmm'@'%';
#       ALTER USER 'pmm'@'%' WITH MAX_USER_CONNECTIONS 10;
#       GRANT SELECT, UPDATE, DELETE, DROP ON performance_schema.* TO 'pmm'@'%';
# EOF
#     EOT
#   }
# }