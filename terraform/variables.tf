variable "aws_region" { default = "ap-southeast-1" }
variable "ami_id" {}
variable "key_name" {}
variable "security_group_ids" { type = list(string) }
