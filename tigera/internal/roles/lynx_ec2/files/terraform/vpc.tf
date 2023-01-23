module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = var.env_name
  cidr                 = var.vpc_subnet
  azs                  = slice(data.aws_availability_zones.available.names, 0, var.azs_count)

  private_subnets      = slice(var.priv_subnets, 0, var.azs_count)
  public_subnets       = slice(var.pub_subnets, 0, var.azs_count)
  intra_subnets        = var.interface_count > 1 ? slice(var.intra_subnets, 0, var.azs_count) : []

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.env_name}" = "shared",
    "tigera.fr/name"                        = "${var.env_name}-vpc",
    "tigera.fr/cloudOps"                    = var.orchestrator,
    "tigera.fr/environment"                 = var.env_name,
    "tigera.fr/owner"                       = var.owner
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.env_name}" = "shared",
    "kubernetes.io/role/elb"                = "1",
    "tigera.fr/cloudOps"                    = var.orchestrator,
    "tigera.fr/environment"                 = var.env_name,
    "tigera.fr/owner"                       = var.owner
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.env_name}" = "shared",
    "tigera.fr/cloudOps"                    = var.orchestrator,
    "kubernetes.io/role/internal-elb"       = "1",
    "tigera.fr/environment"                 = var.env_name,
    "tigera.fr/owner"                       = var.owner
  }
}

resource "aws_security_group" "control" {
  name   = "${var.env_name}-control-security-group"
  vpc_id = module.vpc.vpc_id

  tags = {
    "kubernetes.io/cluster/${var.env_name}" = "owned",
    "tigera.fr/environment"                 = var.env_name,
    "tigera.fr/cloudOps"                    = var.orchestrator,
    "tigera.fr/owner"                       = var.owner,
    "tigera.fr/name"                        = "${var.env_name}-control-sg",
  }
  ingress {
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port   = 0
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "worker" {
  name   = "${var.env_name}-worker-security-group"
  vpc_id = module.vpc.vpc_id

  tags = {
    "tigera.fr/environment"                 = var.env_name
    "tigera.fr/owner"                       = var.owner
    "tigera.fr/name"                        = "${var.env_name}-worker-sg",
  }
  ingress {
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port   = 0
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.env_name}-bastion-group"
  vpc_id = module.vpc.vpc_id

  tags = {
    "kubernetes.io/cluster/${var.env_name}" = "owned",
    "tigera.fr/environment"                 = var.env_name,
    "tigera.fr/owner"                       = var.owner,
    "tigera.fr/cloudOps"                    = var.orchestrator,
    "tigera.fr/name"                        = "${var.env_name}-bastion-sg"
  }
  ingress {
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port   = 0
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
