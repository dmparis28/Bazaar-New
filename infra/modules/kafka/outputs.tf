# [Phase 0] /infra/modules/kafka/outputs.tf
# Exports the Kafka cluster's ARN and connection string.

output "msk_cluster_arn" {
  description = "The ARN of the MSK cluster."
  # --- FIX: The new module output is named 'arn' ---
  value       = module.msk.arn
}

output "bootstrap_brokers_iam" {
  description = "The connection string for IAM-authenticated clients."
  # --- FIX: The new module output for IAM is 'bootstrap_brokers_sasl_iam' ---
  value       = module.msk.bootstrap_brokers_sasl_iam
  sensitive   = true
}
# ... existing code ...
