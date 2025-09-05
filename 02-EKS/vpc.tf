# Using a slightly larger CIDR than needed - gives us room to grow
# but not too big to waste IP space
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"  # Latest stable that works with AWS provider 4.x+

  name = "ms-platform-vpc"
  cidr = "10.20.0.0/16"  # Plenty of room for expansion

  azs             = local.azs
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]  # Services go here
  public_subnets  = ["10.20.101.0/24", "10.20.102.0/24"]  # Just for ALBs and NAT
  
  # Route table configuration
  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }
  
  # Enable route table replacement
  create_database_subnet_route_table = false
  create_redshift_subnet_route_table = false
  
  # Manage subnet route table associations explicitly
  manage_default_security_group = true
  default_security_group_tags   = { Name = "ms-platform-default" }

  # NAT Gateway Configuration
  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # Explicit NAT Gateway configuration
  nat_gateway_tags = {
    Name = "ms-platform-nat"
  }

  # Configure EIP for NAT Gateway with proper lifecycle
  reuse_nat_ips          = true # Skip creation of EIPs for NAT Gateways
  external_nat_ip_ids    = aws_eip.nat[*].id # Reference externally created EIPs
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Needed for EKS - don't remove these
  tags = merge(local.common_tags, {
    "kubernetes.io/cluster/ms-platform-eks" = "shared"
  })

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    Tier = "private"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    Tier = "public"
  }
}

# Create EIP separately with proper lifecycle rules
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  lifecycle {
    # Prevent destroy of EIP until all NAT Gateways are destroyed
    create_before_destroy = true
    
    # Prevent replacement of EIP to avoid NAT Gateway issues
    prevent_destroy = false
    
    # If the EIP is changed, create the new one first
    ignore_changes = [tags]
  }

  tags = merge(local.common_tags, {
    Name = "ms-platform-nat-eip"
  })
}

# Variables for NAT Gateway configuration
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}
