# AWS Infrastructure Projects

This repository contains a progressive set of Terraform configurations for building AWS infrastructure, from foundational remote state management to a complete EKS cluster setup.

## Project Structure
```
Projects/
├── 00-S3 creation/     # Remote state infrastructure (foundation)
├── 01-VPC/             # VPC infrastructure module
├── 02-EKS/             # EKS cluster on VPC infrastructure
└── README.md           # This file
```

## Architecture Overview

This project follows a layered approach to infrastructure as code:

1. **Foundation Layer** (00-S3 creation) - Remote state management
2. **Network Layer** (01-VPC) - VPC with public/private subnets  
3. **Compute Layer** (02-EKS) - Managed Kubernetes cluster

## Project Details

### 00-S3 Creation - Remote State Infrastructure

**Purpose**: Sets up secure remote state management for all subsequent Terraform projects.

**What it creates**:
- S3 bucket with versioning and encryption for state storage
- DynamoDB table for state locking
- IAM policies for secure access
- Public access blocking and lifecycle policies

**Key Features**:
- AWS KMS encryption for state files
- DynamoDB on-demand pricing for cost optimization
- Versioning enabled for rollback capabilities
- Proper IAM access controls

**Cost**: ~$1-2/month for small projects

### 01-VPC - Network Infrastructure

**Purpose**: Creates a production-ready VPC foundation for AWS workloads.

**What it creates**:
- VPC with 10.20.0.0/16 CIDR block
- 2 Availability Zones (us-west-2a/b)
- 2 Private subnets (10.20.1.0/24, 10.20.2.0/24)
- 2 Public subnets (10.20.101.0/24, 10.20.102.0/24)  
- Single NAT Gateway (cost-optimized)
- Internet Gateway
- Route tables and security groups
- EKS-compatible subnet tagging

**Key Features**:
- Multi-AZ high availability design
- Private subnets for secure workloads
- Single NAT Gateway for cost optimization
- DNS hostname support enabled
- Ready for EKS deployment

**Cost**: ~$45/month (primarily NAT Gateway)

### 02-EKS - Kubernetes Cluster

**Purpose**: Deploys a simple, production-ready EKS cluster on the VPC infrastructure.

**What it creates**:
- Managed EKS cluster (Kubernetes 1.33)
- Managed node group with 2 t3.medium instances
- IAM roles for cluster and worker nodes
- Security groups for cluster access
- CloudWatch logging for control plane

**Key Features**:
- Simplified setup without complex add-ons
- Managed node groups for easier maintenance  
- Private networking for security
- CloudWatch integration for monitoring
- Cost-optimized instance sizing

**Cost**: ~$190/month total (EKS control plane + nodes + networking)
