# EKS Cluster - Modular Layer

This directory contains Terraform configuration for creating an EKS cluster that consumes VPC infrastructure from the `01-VPC` layer via remote state. This is a modular approach that enables clean separation of concerns and resource reuse.

## Modular Architecture

This EKS layer follows a modular design pattern:

- **Consumes VPC via Remote State**: No duplicate networking resources
- **Independent Lifecycle**: Can be destroyed/recreated without affecting VPC
- **Shared Infrastructure**: VPC can support multiple services (RDS, ALB, etc.)
- **Clean Dependencies**: Clear separation between networking and compute layers

### Remote State Pattern

The module reads VPC outputs from the networking layer:

```hcl
# vpc-data.tf
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "guru-terraform-state-dev-1"
    key    = "vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  nat_public_ips     = data.terraform_remote_state.vpc.outputs.nat_public_ips
}
```

## Dependencies

### Required Infrastructure (Deploy Order)
1. **Remote State** (`00-S3 creation`) - S3 bucket and DynamoDB for state management
2. **VPC Layer** (`01-VPC`) - Shared networking infrastructure
3. **EKS Layer** (`02-EKS`) - This layer

### Remote State Dependencies
This module consumes the following from the VPC layer:
- `vpc_id` - The VPC ID where EKS will be deployed
- `private_subnet_ids` - Private subnets for EKS worker nodes
- `public_subnet_ids` - Public subnets for load balancers  
- `nat_public_ips` - NAT Gateway IPs for allowlisting

**State Location**: `s3://guru-terraform-state-dev-1/eks/terraform.tfstate`

## What This Layer Creates

### EKS Cluster
- **Managed EKS Cluster**: Kubernetes 1.33 in private subnets
- **Managed Node Group**: 2-4 t3.medium instances with auto-scaling
- **CloudWatch Logging**: Control plane logs (API, audit, authenticator)
- **Security Groups**: EKS-specific security rules

### IAM Resources
- **Cluster Service Role**: For EKS control plane operations
- **Node Group Role**: For worker node EC2 instances
- **Minimal Permissions**: Following principle of least privilege

### Key Features
- **Private Networking**: Nodes in private subnets, no direct internet access
- **Cost Optimized**: t3.medium instances, shared NAT Gateway
- **Simplified Setup**: No complex add-ons, focused on core functionality
- **CloudWatch Integration**: Essential logging enabled

## Getting Started

### Prerequisites
- AWS CLI v2.x+ configured with appropriate permissions
- Terraform >= 1.0
- kubectl >= 1.27
- VPC layer must be deployed first

### Deployment Steps

1. **Verify VPC layer is deployed**:
   ```bash
   cd ../01-VPC
   terraform output
   ```

2. **Deploy EKS cluster**:
   ```bash
   cd ../02-EKS
   terraform init
   terraform plan
   terraform apply
   ```
   *Note: EKS cluster creation takes about 10-15 minutes*

3. **Configure kubectl**:
   ```bash
   # Use the exact command from terraform output
   aws eks update-kubeconfig --region us-west-2 --name ms-platform-eks
   
   # Verify connection
   kubectl get nodes
   kubectl cluster-info
   ```

4. **Verify everything works**:
   ```bash
   # Check node status
   kubectl get nodes -o wide
   
   # Check system pods
   kubectl get pods -n kube-system
   
   # Create a simple test
   kubectl create deployment test-nginx --image=nginx
   kubectl expose deployment test-nginx --port=80 --type=LoadBalancer
   ```

## Configuration

### Variables
- `region`: AWS region (default: us-west-2)
- `environment`: Environment name (default: dev)
- `kubernetes_version`: EKS version (default: 1.33)
- `desired_nodes`: Desired number of worker nodes (default: 2)
- `min_nodes`: Minimum number of worker nodes (default: 1)
- `max_nodes`: Maximum number of worker nodes (default: 4)

### Key Outputs
- `cluster_name`: Name of the EKS cluster
- `cluster_endpoint`: EKS cluster API endpoint
- `cluster_version`: Kubernetes version
- `kubeconfig_command`: Ready-to-use kubectl setup command
- `node_group_arn`: ARN of the node group
- VPC outputs (passed through from networking layer)

## File Structure

```
02-EKS/
├── main.tf              # Common tags and backend configuration
├── vpc-data.tf          # Remote state data source for VPC
├── iam.tf               # IAM roles for EKS cluster and nodes
├── eks-cluster.tf       # EKS cluster configuration
├── eks-nodes.tf         # Managed node group configuration
├── providers.tf         # AWS and Kubernetes provider setup
├── variables.tf         # Input variables
├── outputs.tf           # Outputs (EKS + VPC pass-through)
├── init.tf              # Provider requirements
└── README.md            # This file
```

## Network Design

The EKS cluster leverages the shared VPC infrastructure:

### VPC Layout (from 01-VPC layer)
- **CIDR**: 10.20.0.0/16
- **Private subnets**: 10.20.1.0/24, 10.20.2.0/24 (EKS nodes)
- **Public subnets**: 10.20.101.0/24, 10.20.102.0/24 (load balancers)
- **Single NAT Gateway**: Cost-optimized shared networking

### EKS Configuration
- **Cluster**: ms-platform-eks
- **Version**: Kubernetes 1.33
- **Node Group**: 2-4 t3.medium instances (ON_DEMAND)
- **Networking**: Private subnets only for nodes, public for LoadBalancers

## Security Considerations

- **Private Node Placement**: Worker nodes in private subnets only
- **API Endpoint**: Public but can be restricted to specific IPs
- **No Direct Internet**: Nodes use NAT Gateway for outbound traffic
- **Least Privilege IAM**: Minimal required permissions
- **Security Groups**: EKS-specific rules following AWS best practices

## Cost Optimization

This layer's costs (VPC costs are in the networking layer):
- **EKS Control Plane**: ~$73/month (fixed AWS cost)
- **2x t3.medium nodes**: ~$60/month (variable based on usage)
- **EBS volumes**: ~$10/month (20GB per node)
- **Layer Total**: ~$143/month

*Note: VPC/NAT Gateway costs (~$45/month) are in the 01-VPC layer and shared across services*

## Monitoring and Logging

- **Control Plane Logs**: API, audit, and authenticator logs to CloudWatch
- **Node Logs**: Worker node logs available in CloudWatch
- **Metrics**: Basic CloudWatch metrics enabled
- **Ready for Add-ons**: Can add Metrics Server, Prometheus, etc.

## Troubleshooting

### Common Issues
1. **VPC not found**: Ensure `01-VPC` is deployed and state is accessible
2. **Remote state access denied**: Check S3 bucket permissions
3. **Subnet not available**: Verify VPC outputs match expected format

### Validation Commands
```bash
# Check remote state access
terraform console
> data.terraform_remote_state.vpc.outputs

# Verify VPC dependency
terraform plan | grep "data.terraform_remote_state.vpc"

# Check state file location
aws s3 ls s3://guru-terraform-state-dev-1/eks/
```

### Debug Remote State
```bash
# Check VPC state directly
aws s3 cp s3://guru-terraform-state-dev-1/vpc/terraform.tfstate - | jq '.outputs'

# Show current state references
terraform show -json | jq '.values.root_module.resources[] | select(.type == "terraform_remote_state")'
```

## Next Steps

Once the basic cluster is running, consider adding:

### Immediate Add-ons
- **Metrics Server**: For `kubectl top` commands and HPA
- **AWS Load Balancer Controller**: For advanced ingress management
- **Cluster Autoscaler**: For automatic node scaling based on demand

### Advanced Features
- **Monitoring Stack**: Prometheus, Grafana, CloudWatch Container Insights
- **Security**: Pod Security Standards, Network Policies, IRSA
- **GitOps**: ArgoCD or Flux for application deployment
- **Service Mesh**: Istio or App Mesh for advanced traffic management

### Additional Services
Since the VPC is shared, you can add:
- **Database Layer** (`03-RDS`): Use private subnets
- **Application Layer** (`04-Apps`): Reference EKS outputs
- **Monitoring Layer** (`05-Monitoring`): Deploy observability stack

## Clean Up

To destroy this layer without affecting the VPC:

```bash
terraform destroy
```

*Note: This only destroys the EKS cluster. The VPC remains for other services.*

To destroy everything (reverse dependency order):
```bash
# 1. Destroy EKS first
cd 02-EKS && terraform destroy

# 2. Destroy VPC second  
cd ../01-VPC && terraform destroy

# 3. Destroy remote state last (optional)
cd "../00-S3 creation" && terraform destroy
```

## Benefits of This Modular Approach

- **Resource Reuse**: VPC can support multiple services
- **Independent Lifecycles**: Update EKS without touching networking
- **Team Collaboration**: Different teams can own different layers
- **Cost Efficiency**: Shared infrastructure reduces duplicate resources
- **Simplified Troubleshooting**: Clear separation of concerns
- **Scalable Architecture**: Easy to add new services using the same pattern
