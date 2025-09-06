# Local values for the autoscaler module

locals {
  # Extract OIDC issuer URL without https://
  oidc_issuer_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  
  # Common tags
  common_tags = {
    Project     = "EKS-Autoscaler"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}
