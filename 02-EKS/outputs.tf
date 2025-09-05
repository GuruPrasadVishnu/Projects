# Infrastructure outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways for allowlisting"
  value       = module.vpc.nat_public_ips
}

# EKS cluster outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running in the cluster"
  value       = aws_eks_cluster.main.version
}

output "kubeconfig_command" {
  description = "Command to configure kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
}

output "node_group_arn" {
  description = "ARN of the node group"
  value       = aws_eks_node_group.main.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
