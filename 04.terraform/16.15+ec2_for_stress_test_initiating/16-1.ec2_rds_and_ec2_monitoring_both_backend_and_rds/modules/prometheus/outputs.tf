output "prometheus_instance_id" {
  value = aws_instance.prometheus_instance.id
}

output "prometheus_eip" {
  value = aws_eip.prometheus_eip.public_ip
  description = "The Elastic IP address (EIP) associated with the EC2 instance."
}

# The IP address of your test EC2 instance will be display in this output after the Terraform apply command completes.
output "prometheus_dashboard_url" {
  description = "Prometheus instance dashboard"
  value       = "http://${aws_instance.prometheus_instance.public_ip}:9090/graph"
}

output "grafana_dashboard_url" {
  description = "Grafana instance dashboard"
  value       = "http://${aws_instance.prometheus_instance.public_ip}:3000"
}
