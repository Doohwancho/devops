output "name" {
  description = "Name of create instance profile"
  value       = aws_iam_instance_profile.iam_instance_profile.name
}

output "rds_monitoring_role_arn" {
  description = "ARN of the IAM role for RDS Enhanced Monitoring"
  value       = aws_iam_role.monitoring_role.arn
}

# Output for monitoring role
output "monitoring_instance_profile_name" {
  description = "Name of created monitoring instance profile"
  value       = aws_iam_instance_profile.monitoring_profile.name
}