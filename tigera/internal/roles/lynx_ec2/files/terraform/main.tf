data "aws_availability_zones" "available" {}

module "ami_search" {
  source = "./ami-search"
  os     = var.os
}

module "ami_search_bastion" {
  source = "./ami-search"
  os     = var.os_bastion
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.env_name
  public_key = var.public_ssh_key
}
