# should specify optional vs required

# default value 적어두고, terraform.tfvars 비워두면 그렇게 세팅되고,
# default value 없는 상태이면, 여기는 타입, description, sensitive만 정의하고, actual 값은 terraform.tfvars에서 적어놓는다.

variable "instance_name" {
  description = "Name of ec2 instance"
  type        = string
}

variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_user" {
  description = "username for database"
  type        = string
  default     = "foo"
}

variable "db_pass" {
  description = "password for database"
  type        = string
  sensitive   = true # true로 해두면 비밀번호같은 정보를 console에 log하지 않는다.
}
