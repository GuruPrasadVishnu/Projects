# VPC Infrastructure Module

This module creates a production-ready VPC infrastructure on AWS using Terraform.

## What it Creates

- A VPC with CIDR block 10.20.0.0/16
- 2 Availability Zones setup for high availability
- 2 Private Subnets (10.20.1.0/24, 10.20.2.0/24)
- 2 Public Subnets (10.20.101.0/24, 10.20.102.0/24)
- Single NAT Gateway (cost-optimized)
- Internet Gateway
- Route Tables for both public and private subnets
- EKS-compatible subnet tagging

## Features

- DNS hostnames and support enabled
- Properly configured for EKS deployment
- Cost-optimized with single NAT Gateway
- Managed default security group
- No unnecessary route tables (database/redshift disabled)

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- AWS provider >= 6.0

## Usage

```bash
# Initialize Terraform
terraform init

# Review the changes
terraform plan

# Apply the infrastructure
terraform apply

# When you need to destroy
terraform destroy
```

### Note

This VPC is configured with EKS in mind and includes all necessary tagging for Kubernetes integration.
