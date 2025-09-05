terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.9.0, < 7.0.0" 
    }
  }
}



locals {
  common_tags = merge({
    ManagedBy   = "Terraform"
    Environment = "dev"
  }, var.tags)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  
  name               = var.cluster_name            
  kubernetes_version = "1.29"

  
  
  endpoint_public_access       = var.endpoint_public_access
  endpoint_private_access      = var.endpoint_private_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  enable_cluster_creator_admin_permissions = true

  addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns    = {}
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
      disk_size      = 20
      capacity_type  = "ON_DEMAND"
      # 👇 again, variables
      subnet_ids     = var.subnet_ids
      tags           = local.common_tags
    }
  }

  tags = local.common_tags
}

