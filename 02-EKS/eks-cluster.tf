# Main EKS Cluster Configuration

# Security group for cluster - restricting to 443 only
resource "aws_security_group" "eks_cluster" {
  name        = "${local.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = local.vpc_id

  # Outbound all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Only 443 inbound for k8s API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # TODO: Lock this down to VPN/office IPs
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-cluster-sg"
  })
}

# The actual EKS cluster
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster.arn

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator"
  ]

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = local.private_subnet_ids
    
    # Keeping endpoint private for now - we can expose it later if needed
    endpoint_private_access = true
    endpoint_public_access  = true  # TODO: Make this false once VPN is set up
  }

  # Force proper IAM role/policy attachment before creating cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_cluster_cloudwatch_policy
  ]

  tags = local.common_tags
}
