# Cluster Autoscaler deployment using Helm

# Service account for cluster autoscaler
resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}

# Deploy cluster autoscaler using Helm
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.29.0"
  namespace  = "kube-system"

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = "cluster-autoscaler"
      }
      autoDiscovery = {
        clusterName = data.terraform_remote_state.eks.outputs.cluster_name
        enabled     = true
      }
      awsRegion = var.region
    })
  ]

  depends_on = [kubernetes_service_account.cluster_autoscaler]
}
