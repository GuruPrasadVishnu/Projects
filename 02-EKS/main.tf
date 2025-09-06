# Terraform Configuration for EKS Setup

locals {
  # Starting with 2 AZs to keep costs down
  azs = ["us-west-2a", "us-west-2b"]
  # EKS cluster name
  cluster_name = "ms-platform-eks"
  # common tags for all resources
  common_tags = {
    Project     = "ms-platform"
    Environment = var.environment
    Owner       = "Guru"
    ManagedBy   = "terraform"
  }
}

# Data source to get VPC outputs from the networking layer
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "guru-terraform-state-dev-1"
    key    = "vpc/terraform.tfstate"
    region = "us-west-2"
  }
}
