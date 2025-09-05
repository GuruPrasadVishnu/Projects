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
