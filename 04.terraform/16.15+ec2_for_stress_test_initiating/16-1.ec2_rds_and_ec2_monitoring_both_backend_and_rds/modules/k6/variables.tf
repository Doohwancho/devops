variable "stress_test_subnets" {
  description = "List of public subnet IDs"
  /* type        = list(string) */
  type        = any
}

variable "iam_instance_profile" {
  description = "The name of the IAM instance profile"
  type        = any
}

variable "sg" {
  type = any
}
