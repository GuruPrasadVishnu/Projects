# This module depends on the VPC infrastructure from 01-VPC
# It uses terraform remote state to access VPC outputs

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"  # Hardcoded for now - will make dynamic later
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"  # Using dev as default to prevent accidents
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version to use for EKS cluster"
  type        = string
  default     = "1.33"  # Default version as of Sept 2025, supports extended features
}

# Node group configuration
variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2  # Starting small to save costs
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1  # Need at least one for high availability
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4  # Can go higher but watching costs for now
}