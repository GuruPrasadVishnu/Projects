# Phase 1: Only VPC outputs for now
# Will add service endpoints as we create them

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
