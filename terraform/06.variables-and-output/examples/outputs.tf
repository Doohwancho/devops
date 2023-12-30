# main.tf가 실행된 이후 output으로 뱉어낼 정보들. 이게 chain되어 다른 테라폼 실행도 가능.

output "instance_ip_addr" {
  value = aws_instance.instance.private_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}
