# AWS provider configuration
# Hardcoding region for now - should probably make this a variable later
provider "aws" {
  region = "us-west-2"
}

# S3 bucket for storing state files
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = var.state_bucket_name
    Environment = var.environment
    Project     = "terraform-state"
    ManagedBy   = "terraform"
   
  }
}

# Enable versioning 
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Using AWS managed key for now - might want custom KMS key later
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block ALL public access - no exceptions
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  # TODO: evaluate if we really need point in time recovery
  # enabling for now just to be safe
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = var.environment
    Project     = "terraform-state"
    ManagedBy   = "terraform"
    
  }
}

# IAM policy for S3 access
# Breaking this into read and write policies for better granularity
module "iam_policies" {
  source = "./modules/iam"
  
  bucket_name = aws_s3_bucket.terraform_state.id
  table_name  = aws_dynamodb_table.terraform_locks.name
}
