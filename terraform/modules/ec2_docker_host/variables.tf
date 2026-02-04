variable "name" {}
variable "ami_id" {}
variable "instance_type" { default = "t3.medium" }
variable "key_name" {}
variable "security_group_ids" { type = list(string) }
