data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
    preserve_hostname: false
    fqdn: "bastion.${var.env_name}.lynx.tigera.fr"
    hostname: "bastion"
    users:
      - default
      - name: lynx
        ssh_authorized_keys:
          - "${var.public_ssh_key}"
        sudo: ALL=(ALL) NOPASSWD:ALL
EOF
  }
}

resource "aws_network_interface" "bastion" {
  count             = 1
  subnet_id         = var.azs_count > 1 ? module.vpc.private_subnets[count.index % var.azs_count] : module.vpc.private_subnets[0]
  private_ips       = [cidrhost((var.azs_count > 1 ? var.priv_subnets[count.index % var.azs_count] : var.priv_subnets[0]), 10 + count.index)]
  source_dest_check = false
  security_groups   = [aws_security_group.bastion.id]

  tags = {
    "Name"                  = "${var.env_name}-bastion-${count.index + 1}",
    "tigera.fr/environment" = var.env_name,
    "tigera.fr/owner"       = var.owner
  }
}

resource "aws_network_interface" "bastion-extra" {
  count             = var.interface_count - 1
  subnet_id         = var.azs_count > 1 ? module.vpc.intra_subnets[count.index % var.azs_count] : module.vpc.intra_subnets[0]
  private_ips       = [cidrhost((var.azs_count > 1 ? var.intra_subnets[count.index % var.azs_count] : var.intra_subnets[0]), 10 + count.index)]
  source_dest_check = false
  security_groups   = [aws_security_group.bastion.id]

  tags = {
    "Name"                  = "${var.env_name}-bastion-extra-${count.index + 1}",
    "tigera.fr/environment" = var.env_name,
    "tigera.fr/owner"       = var.owner
  }
}

resource "aws_network_interface_attachment" "bastion-attachment" {
  count                = var.interface_count - 1
  instance_id          = element(aws_instance.bastion.*.id, count.index)
  network_interface_id = element(aws_network_interface.bastion-extra.*.id, count.index)
  device_index         = 1
}


resource "aws_instance" "bastion" {
  count = 1
  ami   = module.ami_search_bastion.ami_id

  instance_type = "t3.micro"
  key_name      = var.env_name

  root_block_device {
    volume_size = 10
  }

  network_interface {
    network_interface_id = aws_network_interface.bastion[count.index].id
    device_index         = 0
  }
  
  user_data = data.template_cloudinit_config.bastion.rendered

  tags = {
    "Name"                  = "${var.env_name}-bastion",
    "tigera.fr/role"        = "bastion",
    "tigera.fr/cloudOps"    = var.orchestrator,
    "tigera.fr/environment" = var.env_name,
    "tigera.fr/owner"       = var.owner,
  }

  volume_tags = {
    "Name"                  = "${var.env_name}-bastion-vol",
    "tigera.fr/environment" = var.env_name,
    "tigera.fr/cloudOps"    = var.orchestrator,
    "tigera.fr/name"        = "${var.env_name}-bastion-vol",
    "tigera.fr/owner"       = var.owner
  }
}

resource "aws_ebs_volume" "bastion_extra_volume" {
  count             = var.bastion_extra_volume_size > 0 ? 1 : 0
  size              = var.bastion_extra_volume_size
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_volume_attachment" "bastion_extra_attachement" {
  count         = var.bastion_extra_volume_size > 0 ? 1 : 0
  volume_id     = aws_ebs_volume.bastion_extra_volume[count.index].id
  instance_id   = aws_instance.bastion[count.index].id
  device_name   = "/dev/sdf"
}
