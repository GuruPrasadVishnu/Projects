# Phase 1: Basic Network Setup

terraform {
  backend "s3" {
    bucket         = "guru-terraform-state-dev-1"
    key            = "vpc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

locals {
  # Starting with 2 AZs to keep costs down
  azs = ["us-west-2a", "us-west-2b"]
  
  # Basic tags - we'll expand these as we grow
  common_tags = {
    Project     = "ms-platform"
    Environment = var.environment
    Owner       = "Guru"
    ManagedBy   = "terraform"
  }
}
