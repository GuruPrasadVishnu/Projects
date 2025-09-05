variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  
  # Adding validation to prevent obviously wrong names
  validation {
    condition     = length(var.state_bucket_name) > 3 && length(var.state_bucket_name) < 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

variable "environment" {
  description = "Environment name - dev/staging/prod"
  type        = string
  default     = "dev" # defaulting to dev - remember to override in prod
}


