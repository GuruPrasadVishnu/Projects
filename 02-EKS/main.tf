# Terraform Configuration for VPC Setup

# Initialize required providers
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
