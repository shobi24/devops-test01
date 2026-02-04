module "monitoring_host" {
  source            = "./modules/ec2_docker_host"
  name              = "monitoring-server"
  ami_id            = var.ami_id
  key_name          = var.key_name
  security_group_ids = var.security_group_ids
}
