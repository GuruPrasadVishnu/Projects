# Node Group Configuration

locals {
  instance_types = ["t3.medium"]  # Using t3.medium to keep costs reasonable
  capacity_type  = "ON_DEMAND"    # SPOT would be cheaper but less stable
}

# Node group - starting small and will scale up as needed
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.private_subnets
  instance_types  = local.instance_types
  capacity_type   = local.capacity_type

  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  # This helps with graceful updates/destroys but makes CI/CD slower
  update_config {
    max_unavailable = 1
  }

  # Let's not make modifying the launch template too easy
  lifecycle {
    ignore_changes = [launch_template]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]

  tags = local.common_tags
}
