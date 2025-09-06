# AWS Infrastructure Projects - Modular Architecture

This repository contains a progressive set of Terraform configurations for building AWS infrastructure using a modular, layered approach. Each layer builds upon the previous one using remote state sharing for clean separation of concerns.

## Project Structure

```
Projects/
├── 00-S3 creation/           # Remote state infrastructure (foundation)
├── 01-VPC/                   # VPC infrastructure module  
├── 02-EKS/                   # EKS cluster consuming VPC via remote state
├── 03-EKS-Autoscaler/        # Cluster and Pod autoscaling (modular)
└── README.md                 # This file
```

## Modular Architecture Overview

This project follows a **layered, modular approach** to infrastructure as code:

1. **Foundation Layer** (`00-S3 creation`) - Remote state management
2. **Network Layer** (`01-VPC`) - Shared VPC infrastructure  
3. **Compute Layer** (`02-EKS`) - EKS cluster consuming network layer via remote state
4. **Autoscaling Layer** (`03-EKS-Autoscaler`) - Cluster and pod autoscaling with HPA

### Key Benefits of This Approach

- **Separation of Concerns**: Each layer has a single responsibility
- **Resource Reuse**: VPC can be shared across multiple services
- **Independent Lifecycles**: Destroy/recreate components without affecting dependencies
- **Smaller State Files**: Better performance and reduced blast radius
- **Team Collaboration**: Different teams can own different layers
- **Modular Functionality**: Add features like autoscaling without modifying core infrastructure

## Remote State Sharing Pattern

Each layer consumes outputs from previous layers using Terraform remote state:

```hcl
# Example: 03-EKS-Autoscaler consuming EKS cluster
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "guru-terraform-state-dev-1"
    key    = "02-EKS/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
}
```

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

### 01-VPC - Shared Network Infrastructure

**Purpose**: Creates a reusable VPC foundation that can be shared across multiple services.

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
- **Shared Infrastructure**: Can support multiple services (EKS, RDS, ALB, etc.)
- Multi-AZ high availability design
- Cost-optimized with single NAT Gateway
- DNS hostname support enabled
- Comprehensive outputs for consumption by other layers

**Cost**: ~$45/month (primarily NAT Gateway)  
**State Location**: `s3://guru-terraform-state-dev-1/vpc/terraform.tfstate`

### 02-EKS - Kubernetes Cluster (Modular)

**Purpose**: Deploys EKS cluster that consumes shared VPC infrastructure via remote state.

**What it creates**:
- Managed EKS cluster (Kubernetes 1.33)
- Managed node group with 2 t3.medium instances
- IAM roles for cluster and worker nodes
- Security groups for cluster access
- CloudWatch logging for control plane

**Key Features**:
- **Modular Design**: Consumes VPC via remote state, no duplicate networking
- **Independent Lifecycle**: Can be destroyed/recreated without affecting VPC
- Simplified setup without complex add-ons
- Private networking for security
- CloudWatch integration for monitoring

**Dependencies**: Requires `01-VPC` to be deployed first  
**Cost**: ~$145/month (EKS control plane + nodes, VPC costs separate)  
**State Location**: `s3://guru-terraform-state-dev-1/02-EKS/terraform.tfstate`

### 03-EKS-Autoscaler - Cluster and Pod Autoscaling (Modular)

**Purpose**: Adds comprehensive autoscaling capabilities to the EKS cluster via modular components.

**What it creates**:
- **Cluster Autoscaler**: Automatically scales EKS worker nodes based on pod demand
- **Horizontal Pod Autoscaler (HPA)**: Scales pods based on CPU/memory metrics
- **Metrics Server**: Provides resource metrics for HPA functionality
- **OIDC Identity Provider**: Enables IAM Roles for Service Accounts (IRSA)
- **IAM Roles & Policies**: Secure permissions for autoscaling operations
- **Sample Application**: Demo app with HPA configuration for testing
- **AWS Console Access**: ConfigMap for EKS console integration

**Key Features**:
- **Modular Architecture**: Clean separation across 10 terraform files
- **Security Best Practices**: IRSA for secure AWS API access
- **Cost Optimization**: Automatic scaling prevents over-provisioning
- **Production Ready**: Comprehensive IAM permissions and error handling
- **Demo Friendly**: Includes sample app and load testing commands

**File Structure**:
```
03-EKS-Autoscaler/
├── main.tf                 # Core terraform config and providers
├── data.tf                 # Data sources and remote state
├── locals.tf               # Local values and common tags
├── variables.tf            # Input variables
├── oidc.tf                 # OIDC identity provider for IRSA
├── iam.tf                  # IAM roles and policies
├── cluster-autoscaler.tf   # Cluster autoscaler deployment
├── hpa.tf                  # HPA, metrics server, and sample app
├── auth.tf                 # AWS auth ConfigMap
└── outputs.tf              # Useful commands and status checks
```

**Dependencies**: Requires `02-EKS` to be deployed first  
**Cost**: ~$5-10/month additional (varies with scaling activity)  
**State Location**: `s3://guru-terraform-state-dev-1/03-eks-autoscaler/terraform.tfstate`

## Getting Started

### Prerequisites

- AWS CLI v2.x+ configured with appropriate permissions
- Terraform >= 1.0
- kubectl >= 1.27 (for EKS projects)
- Helm >= 3.0 (for autoscaler project)

### Deployment Order

**Critical**: These projects must be deployed in strict sequence due to remote state dependencies.

#### 1. Deploy Remote State Infrastructure
```bash
cd "00-S3 creation"
terraform init
terraform plan
terraform apply
```

#### 2. Deploy Shared VPC Infrastructure
```bash
cd "../01-VPC"  
terraform init
terraform plan
terraform apply
# Verify outputs are available
terraform output
```

#### 3. Deploy EKS Cluster (Modular)
```bash
cd "../02-EKS"
terraform init
terraform plan  
terraform apply
# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name ms-platform-eks
kubectl get nodes
```

#### 4. Deploy Autoscaling (Modular)
```bash
cd "../03-EKS-Autoscaler"
terraform init
terraform plan
terraform apply

# Verify autoscaling components
kubectl get pods -n kube-system | grep -E "(autoscaler|metrics)"
kubectl get hpa -n default
```

### Validation

Verify the modular architecture is working:

```bash
# Check remote state access
cd 03-EKS-Autoscaler
terraform console
> data.terraform_remote_state.eks.outputs

# Test cluster autoscaler
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-scale
spec:
  replicas: 10
  selector:
    matchLabels:
      app: test-scale
  template:
    metadata:
      labels:
        app: test-scale
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
