terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 6.9.0, < 7.0.0" }
  }
}

locals {
  common_tags = merge({ ManagedBy = "Terraform", Environment = "dev" }, var.tags)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  endpoint_public_access        = var.endpoint_public_access
  endpoint_private_access       = var.endpoint_private_access
  endpoint_public_access_cidrs  = var.endpoint_public_access_cidrs
  enable_cluster_creator_admin_permissions = true
  access_entries = var.access_entries


  addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
  }

  eks_managed_node_groups = {
    example = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = var.instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

    
      bootstrap_extra_args = <<-EOT
        [settings.host-containers.admin]
        enabled = false
        [settings.host-containers.control]
        enabled = true
        [settings.kernel]
        lockdown = "integrity"
      EOT

      subnet_ids = var.subnet_ids
      tags       = local.common_tags
    }
  }

  tags = local.common_tags
}
