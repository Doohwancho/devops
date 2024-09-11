variable "namespace" {
  type = string
}

variable "vpc" {
  type = any 
}

variable "sg" {
  type = any 
}

variable "rds_monitoring_role_arn" {
  type = string
  description = "ARN of the IAM role for RDS Enhanced Monitoring"
}