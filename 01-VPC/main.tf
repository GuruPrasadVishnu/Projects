# Terraform Configuration for VPC Setup

# Setting up AWS Provider
provider "aws" {
  region = var.region
}

# Adding Backend as S3 for Remote State Storage and DynamoDB for State Locking
terraform {
  backend "s3" {
    bucket         = "guru-terraform-state-dev-1"
    key            = "vpc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}

locals {
  # Starting with 2 AZs to keep costs down
  azs = ["us-west-2a", "us-west-2b"]
  
  # common tags for all resources
  common_tags = {
    Project     = "ms-platform"
    Environment = var.environment
    Owner       = "Guru"
    ManagedBy   = "terraform"
  }
}
