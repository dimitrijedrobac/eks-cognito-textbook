# Global settings
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name prefix for tagging and naming resources"
  type        = string
  default     = "eks-cognito-guestbook"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-cognito-guestbook-dev"
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
}
