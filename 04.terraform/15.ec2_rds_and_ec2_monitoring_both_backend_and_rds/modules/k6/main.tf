/*
resource "aws_instance" "stress_test_instance" {
  ami = "ami-0419dc605b6dde61f"
  instance_type = "t3a.small" #AMD x86_64 architecture, 2-core 2-GiB RAM
  
  vpc_security_group_ids = [var.sg.prometheus]
  subnet_id              = var.stress_test_subnets[0]
  iam_instance_profile   = var.iam_instance_profile
  user_data = base64encode(file("${path.module}/user_data.sh"))
  tags = {
    "Name" = "prometheus_grafana_instance"
  }
}
*/
