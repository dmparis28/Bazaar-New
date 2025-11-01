# [Phase 0] /infra/modules/vpc/outputs.tf
# Exposes the outputs from the public module so the
# "root" module (that calls this) can access them.

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "cde_subnet_ids" {
  description = "List of CDE (database) subnet IDs"
  value       = module.vpc.database_subnets
}

output "public_nat_gateway_ips" {
  description = "List of public IPs of the NAT gateways"
  value       = module.vpc.nat_public_ips
}
