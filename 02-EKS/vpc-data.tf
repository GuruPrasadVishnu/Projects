# VPC Data Sources - Using outputs from the networking layer (01-VPC)
# This file contains local references to VPC resources created in the networking layer

locals {
  # VPC information from remote state
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  nat_public_ips     = data.terraform_remote_state.vpc.outputs.nat_public_ips
}
