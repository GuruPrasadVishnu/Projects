# Phase 1: Basic Network Setup
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
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}
