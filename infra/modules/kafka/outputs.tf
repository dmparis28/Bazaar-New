# [Phase 0] /infra/modules/kafka/outputs.tf
# Exports the Kafka cluster's ARN and connection string.

output "msk_cluster_arn" {
  description = "The ARN of the MSK cluster."
  value       = module.msk.msk_cluster_arn
}

output "bootstrap_brokers_iam" {
  description = "The connection string for IAM-authenticated clients."
  value       = module.msk.bootstrap_brokers_iam
  sensitive   = true
}

output "bootstrap_brokers_tls" {
  description = "The connection string for TLS-authenticated clients."
  value       = module.msk.bootstrap_brokers_tls
  sensitive   = true
}

