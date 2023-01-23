resource "aws_network_interface" "control" {
  count             = var.control_instance_count
  subnet_id         = var.azs_count > 1 ? module.vpc.private_subnets[count.index % var.azs_count] : module.vpc.private_subnets[0]
  private_ips       = [cidrhost((var.azs_count > 1 ? var.priv_subnets[count.index % var.azs_count] : var.priv_subnets[0]), 20 + count.index)]
  source_dest_check = false
  security_groups   = [aws_security_group.control.id]

  tags = {
    "Name"                  = "${var.env_name}-control-${count.index + 1}",
    "tigera.fr/environment" = var.env_name,
    "tigera.fr/owner"       = var.owner
  }
}

resource "aws_network_interface" "control-extra" {
  count             = var.control_instance_count * (var.interface_count - 1)
  subnet_id         = var.azs_count > 1 ? module.vpc.intra_subnets[count.index % var.azs_count] : module.vpc.intra_subnets[0]
  private_ips       = [cidrhost((var.azs_count > 1 ? var.intra_subnets[count.index % var.azs_count] : var.intra_subnets[0]), 20 + count.index)]
  source_dest_check = false
  security_groups   = [aws_security_group.control.id]

  tags = {
    "Name"                  = "${var.env_name}-control-extra-${count.index + 1}",
    "tigera.fr/environment" = var.env_name,
    "tigera.fr/owner"       = var.owner
  }
}

resource "aws_network_interface_attachment" "control-attachment" {
  count                = var.control_instance_count * (var.interface_count - 1)
  instance_id          = element(aws_instance.control.*.id, count.index)
  network_interface_id = element(aws_network_interface.control-extra.*.id, count.index)
  device_index         = 1
}

resource "aws_instance" "control" {
  count                  = var.control_instance_count
  #ami                    = "ami-0a8f1768d392eee9b" # if need to use specific AMI - Region dependant
  ami                    = module.ami_search.ami_id

  instance_type          = var.control_instance_type
  key_name               = var.env_name

  iam_instance_profile   = var.cloud_provider == true ? aws_iam_instance_profile.control[0].name : null

  network_interface {
    network_interface_id = aws_network_interface.control[count.index].id
    device_index         = 0
  }
  root_block_device {
    volume_size = var.control_root_volume_size
  }

  tags = {
    "Name"                                  = "${var.env_name}-control${count.index + 1}",
    "tigera.fr/role"                        = "control",
    "tigera.fr/cloudOps"                    = var.orchestrator,
    "tigera.fr/environment"                 = var.env_name,
    "tigera.fr/owner"                       = var.owner,
    "kubernetes.io/cluster/${var.env_name}" = "owned"
  }

  volume_tags = {
    "Name"                  = "${var.env_name}-control${count.index + 1}-vol",
    "tigera.fr/environment" = var.env_name
    "tigera.fr/cloudOps"    = var.orchestrator,
    "tigera.fr/name"        = "${var.env_name}-control-${count.index + 1}-vol"
    "tigera.fr/owner"       = var.owner
  }
}
