# Terraform Configuration for EKS Setup
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  
  # Adding Backend as S3 for Remote State Storage and DynamoDB for State Locking
  backend "s3" {
    bucket         = "guru-terraform-state-dev-1"
    key            = "eks/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}

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
