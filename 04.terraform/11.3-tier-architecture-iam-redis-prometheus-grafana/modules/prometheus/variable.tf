variable "public_subnets" {
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

/* variable "iam_instance_profile_name" { */
/*   description = "The name of the IAM instance profile" */
/*   type        = string */
/* } */


/* variable "namespace" { */
/*   description = "The namespace for naming resources" */
/*   type        = string */
/* } */



/* variable "namespace" { */
/*   type = string */
/* } */

/* variable "ssh_keypair" { */
/*   type = string */
/* } */

/* variable "vpc" { */
/*   type = any */
/* } */


/* variable "iam_instance_profile_name" { */
/*   description = "The name of the IAM instance profile to be used by the EC2 instances" */
/*   type        = string */
/* } */

/* variable "db_config" { */
/*   type = object( #A */
/*     { #A */
/*       user     = string #A */
/*       password = string #A */
/*       database = string #A */
/*       hostname = string #A */
/*       port     = string #A */
/*     } #A */
/*   ) #A */
/* } */
