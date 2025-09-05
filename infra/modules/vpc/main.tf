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
  common_tags = {
    Project     = var.name
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
  subnet_tags_public = merge(local.common_tags, {
    "kubernetes.io/role/elb"                         = "1"
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
  })

  subnet_tags_private = merge(local.common_tags, {
    "kubernetes.io/role/internal-elb"                = "1"
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.name
  cidr = var.vpc_cidr

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  enable_vpn_gateway  = false

  public_subnet_tags  = local.subnet_tags_public
  private_subnet_tags = local.subnet_tags_private

  tags = local.common_tags
}
