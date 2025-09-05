variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "azs" {
  description = "List of 2 availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of 2 public subnet CIDRs (match AZ count)"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of 2 private subnet CIDRs (match AZ count)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT for all private subnets (save cost)"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name (used only for subnet autodiscovery tags)"
  type        = string
}
