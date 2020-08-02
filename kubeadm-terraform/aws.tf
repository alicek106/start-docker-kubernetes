provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "alicek106-terraform-state"
    key    = "kubernetes/kubeadm.tfstate"
    region = "ap-northeast-2"
  }
}
