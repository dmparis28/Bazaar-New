# [Phase 0] /infra/modules/eks/outputs.tf
# Exports the critical endpoint and config for kubectl

output "cluster_endpoint" {
  description = "The EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_security_group_id" {
  description = "The security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the cluster, used for IAM roles for pods"
  value       = module.eks.cluster_oidc_issuer_url
}
