

output "private_endpoint_of_ec2" {
  value = aws_instance.webserver.private_ip
}

output "webserver_public_ip" {
  value = aws_eip.webserver.public_ip
}

/* used for alb + autoscaling group setting*/
# output "lb_dns_name" {
#    value = module.alb.this_lb_dns_name
# }
# output "private_endpoint_of_ec2" {
# 	value = data.aws_instances.webserver.private_ips[0]
# }