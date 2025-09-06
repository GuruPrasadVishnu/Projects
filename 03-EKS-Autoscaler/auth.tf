# AWS Auth ConfigMap for console access

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-EOT
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ms-platform-eks-node-role
  username: system:node:{{EC2PrivateDNSName}}
  groups:
  - system:bootstrappers
  - system:nodes
EOT
    
    mapUsers = <<-EOT
- userarn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Admin
  username: admin
  groups:
  - system:masters
EOT
  }

  force = true
}
