# OIDC Identity Provider for EKS IRSA

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = merge(local.common_tags, {
    Name = "${data.terraform_remote_state.eks.outputs.cluster_name}-oidc"
  })
}
