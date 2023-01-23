variable env_name {
  type = string
  description = "The name for this AWS environment"
}

variable owner {
  type = string
  default = "lynx-terraform"
  description = "The user owning this environment"
}

variable orchestrator {
  type = string
  default = "lynx"
  description = "The method used to spin up this environment"
}

variable os {
  type    = string
  default = "rhel-7.7"
  description = "The OS to use for all instances except bastion."
}

variable os_bastion {
  type    = string
  default = "rhel-7.7"
  description = "The OS to use for bastion."
}

variable azs_count {
  type    = number
  default = 2
  description = "Number of Availability Zones to use"
}

variable interface_count {
  type        = number
  default     = 1
  description = "How many network interfaces each node should have"
}

variable vpc_subnet {
  type        = string
  default     = "10.0.0.0/16"
  description = "The subnet to use for the vpc"
}

variable priv_subnets {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "The private subnets to use mod azs_count"
}

variable intra_subnets {
  type        = list(string)
  default     = ["10.0.6.0/24", "10.0.7.0/24"]
  description = "Extra interface subnets to use mod azs_count"
}

variable pub_subnets {
  type        = list
  default     = ["10.0.100.0/24", "10.0.101.0/24"]
  description = "The public subnets to use mod azs_count"
}

variable cloud_provider {
  type    = bool
  default = true
  description = "If IAM roles should be added to nodes for k8s cloud provider integration or not"
}

variable control_instance_count {
  type    = string
  default = 3
}

variable worker_instance_count {
  type    = string
  default = 2
}

variable control_instance_type {
  type    = string
  default = "t3.medium"
}

variable worker_instance_type {
  type    = string
  default = "t3.large"
}

variable worker_root_volume_size {
  type = string
  default = "20"
}

variable control_root_volume_size {
  type = string
  default = "20"
}

variable bastion_extra_volume_size {
  type = string
  default = "0"
  description = "Set to positive value (GBs) to create a second disk for bastion"
}

variable "public_ssh_key" {
  type = string
  description = "The ssh keys to be used for all nodes."
}
