# Global tag
locals {
  common_tags = map(
    "kubernetes.io/cluster/${var.cluster_id_tag}", "${var.cluster_id_value}"
  )
}

# You can adjust below variables
variable default_keypair_name {
  default = "mysshkey"
}

variable number_of_worker {
  description = "The number of worker nodes"
  default     = 1
}

variable cluster_id_tag {
  description = "Cluster ID tag for kubeadm"
  default     = "alice"
}

variable cluster_id_value {
  description = "Cluster ID value, it can be shared or owned"
  default     = "owned"
}

variable control_cidr {
  description = "CIDR of security group"
  default     = "0.0.0.0/0"
}

variable owner {
  default = "alicek106"
}

variable region {
  default = "ap-northeast-2"
}

variable zone {
  default = "ap-northeast-2a"
}


# VPC Settings
variable vpc_cidr {
  default = "10.40.0.0/16"
}

variable vpc_name {
  description = "Name of the VPC"
  default     = "kubeadm_vpc"
}

variable subnet_name {
  description = "Name of the Subnet"
  default     = "kubeadm_subnet"
}

# Instance Types
variable master_instance_type {
  default = "t2.medium"
}
variable worker_instance_type {
  default = "t2.medium"
}

variable instance_ami {
  default = "ami-067c32f3d5b9ace91"
}
