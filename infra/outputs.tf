# [Phase 0] /infra/outputs.tf
# This file exposes the important connection details from our modules
# so they are printed in the terminal after an `apply`.

output "bazaar_db_address" {
  description = "The connection endpoint for the RDS (PostgreSQL) database."
  value       = module.bazaar_rds.db_address
  sensitive   = true
}

output "bazaar_redis_address" {
  description = "The connection endpoint for the ElastiCache (Redis) cluster."
  value       = module.bazaar_redis.redis_address
  sensitive   = true
}

output "bazaar_kafka_bootstrap_brokers_iam" {
  description = "The IAM-authenticated bootstrap broker string for Kafka (MSK)."
  value       = module.bazaar_kafka.bootstrap_brokers_iam
  sensitive   = true
}
