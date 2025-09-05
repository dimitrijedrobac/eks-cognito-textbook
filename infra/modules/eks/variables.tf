variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID for the cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "Subnets for the control plane (usually private)"
  type        = list(string)
}

variable "instance_types" {
  description = "Instance types for the default managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_size" {
  type        = number
  default     = 2
}

variable "min_size" {
  type        = number
  default     = 1
}

variable "max_size" {
  type        = number
  default     = 3
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "Allowed CIDRs for public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"] # tighten later if needed
}

variable "tags" {
  description = "Common tags applied to all EKS resources in this module"
  type        = map(string)
  default     = {}
}

