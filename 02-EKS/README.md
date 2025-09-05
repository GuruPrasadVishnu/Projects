# Simple EKS Platform

This is a straightforward EKS cluster setup on AWS, focused on simplicity and core functionality. No bells and whistles - just a solid VPC and managed EKS cluster.

## What You Get

1. **VPC Infrastructure**
   - Custom VPC with public and private subnets
   - Multi-AZ deployment (us-west-2a/b)
   - Single NAT Gateway for cost optimization
   - Internet Gateway for public subnet access

2. **EKS Cluster**
   - Managed Kubernetes cluster (version 1.33)
   - Managed node group with 2 t3.medium instances
   - Private subnets for worker nodes
   - CloudWatch logging enabled for control plane

## Why This Approach?

1. **Simplicity**: No complex add-ons or IRSA configurations to debug
2. **Cost-Effective**: Single NAT Gateway saves ~$45/month
3. **Reliable**: Uses AWS managed services wherever possible
4. **Scalable**: Easy to add components later when needed

## Network Design

### VPC Setup
- **CIDR**: 10.20.0.0/16
- **Private subnets**: 10.20.1.0/24, 10.20.2.0/24 (worker nodes)
- **Public subnets**: 10.20.101.0/24, 10.20.102.0/24 (load balancers)
- **Single NAT Gateway** in us-west-2a (cost optimization)

### EKS Configuration
- **Cluster**: ms-platform-eks
- **Version**: Kubernetes 1.33
- **Node Group**: 2-4 t3.medium instances (ON_DEMAND)
- **Networking**: Private subnets only for nodes

## Prerequisites

- AWS CLI v2.x+ (configured with appropriate permissions)
- Terraform >= 1.0
- kubectl >= 1.27

## Getting Started

1. **Deploy the Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
   *Note: EKS cluster creation takes about 10-15 minutes*

2. **Connect to Your Cluster**
   ```bash
   # Update kubeconfig (use the exact command from terraform output)
   aws eks update-kubeconfig --region us-west-2 --name ms-platform-eks
   
   # Verify the cluster is working
   kubectl get nodes
   kubectl cluster-info
   ```

3. **Verify Everything Works**
   ```bash
   # Check node status
   kubectl get nodes -o wide
   
   # Check system pods
   kubectl get pods -n kube-system
   
   # Create a simple test deployment
   kubectl create deployment test-nginx --image=nginx
   kubectl expose deployment test-nginx --port=80 --type=LoadBalancer
   ```

## Terraform Outputs

After deployment, you'll get useful outputs including:
- **Cluster endpoint**: API server URL
- **Kubeconfig command**: Ready-to-use kubectl setup command
- **VPC and subnet IDs**: For reference in other projects
- **Node group ARN**: For monitoring and management

## File Structure

```
├── main.tf              # Common tags and shared locals
├── vpc.tf               # VPC module configuration
├── iam.tf               # IAM roles for EKS cluster and nodes
├── eks-cluster.tf       # EKS cluster configuration
├── eks-nodes.tf         # Managed node group configuration
├── providers.tf         # AWS and Kubernetes provider setup
├── variables.tf         # Input variables
├── outputs.tf           # Useful outputs after deployment
├── init.tf              # Provider requirements
└── README.md            # This file
```

## Next Steps

Once you have the basic cluster running, you might want to add:
- **Metrics Server**: For `kubectl top` commands and HPA
- **Cluster Autoscaler**: For automatic node scaling
- **AWS Load Balancer Controller**: For better ingress management
- **Monitoring**: CloudWatch Container Insights or Prometheus

## Clean Up

```bash
terraform destroy
```
*Warning: This will delete everything including the VPC and cluster*

## Cost Considerations

Monthly costs (approximate, us-west-2):
- **EKS Cluster**: $73/month (fixed)
- **2x t3.medium nodes**: ~$60/month
- **NAT Gateway**: ~$45/month
- **EBS volumes**: ~$10/month
- **Data transfer**: Variable

**Total**: ~$190/month for a basic setup
