# [Phase 0] /infra/modules/vpc/main.tf
# This is the "wrapper" module. It calls the public AWS VPC module
# and uses the variables defined in `variables.tf`.

# 1. Call the public AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr # <-- FIX: Was var.cidr

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # [Phase 0] "(HA) Configure NAT Gateways for private subnets"
  enable_nat_gateway     = true
  single_nat_gateway     = false # We want one NAT gateway per AZ for HA
  one_nat_gateway_per_az = true

  # [Phase 0] "cde-private-subnets"
  # Use the "database" subnet feature as our CDE.
  create_database_subnet_group = true
  database_subnets             = var.cde_subnet_cidrs
  database_subnet_group_name   = "${var.project_name}-cde-subnet-group"

  # --- FIX: Let the module create the isolated route tables ---
  # The module does this by default, so we just remove our
  # conflicting resources and the unsupported arguments.
  # --- END FIX ---

  # Enable DNS support as required by Kubernetes
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Tier = "Networking"
  })
}

# --- FIX: Delete our custom resources that were conflicting ---
# 2. Create Custom CDE Route Tables (No Internet)
# (This is now handled by the module by default)
#
# resource "aws_route_table" "cde_private" {
#   count  = length(var.azs)
#   vpc_id = module.vpc.vpc_id # This is now safe, as module.vpc exists
#
#   # Note: No default route (0.0.0.0/0). This is intentional.
#   # This isolates the CDE from the internet.
#   tags = merge(var.tags, {
#     Name = "${var.project_name}-cde-private-rt-${count.index + 1}"
#   })
# }
#
# 3. Associate CDE Route Tables with CDE Subnets
# (This is also handled by the module now)
#
# resource "aws_route_table_association" "cde_private" {
#   count          = length(var.azs)
#   subnet_id      = module.vpc.database_subnets[count.index] # Get CDE subnets from module
#   route_table_id = aws_route_table.cde_private[count.index].id
# }
# --- END FIX ---

