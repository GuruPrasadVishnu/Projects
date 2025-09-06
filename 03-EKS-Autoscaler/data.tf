# Data sources for EKS Autoscaler

# Get EKS cluster info from remote state
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "guru-terraform-state-dev-1"
    key    = "02-EKS/terraform.tfstate"
    region = var.region
  }
}

# Get current AWS account
data "aws_caller_identity" "current" {}

# Get the cluster OIDC issuer URL
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# Get TLS certificate for OIDC provider
data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
