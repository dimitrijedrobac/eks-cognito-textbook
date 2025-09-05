module "vpc" {
  source = "./modules/vpc"

  name            = var.project_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # cost-aware defaults
  enable_nat_gateway = true
  single_nat_gateway = true

  cluster_name = var.cluster_name
}

# We'll output useful bits for later modules (EKS, etc.)
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

module "eks" {
  source = "./modules/eks"

  cluster_name               = var.cluster_name
  cluster_version            = "1.29"

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnets
  control_plane_subnet_ids   = module.vpc.private_subnets

  # Cost-conscious defaults; restrict CIDRs later if you want
  endpoint_public_access          = true
  endpoint_private_access         = true
  endpoint_public_access_cidrs    = ["0.0.0.0/0"]

  instance_types = ["t3.small"]
  desired_size   = 2
  min_size       = 1
  max_size       = 3

 tags = { Project = var.project_name }
}

# Handy outputs to use later (Helm providers, etc.)
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_ca_certificate
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  value = module.eks.oidc_issuer_url
}
