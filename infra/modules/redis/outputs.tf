# [Phase 0] /infra/modules/redis/outputs.tf
# Exports the primary endpoint address for the Redis cluster.

output "redis_address" {
  description = "The primary endpoint address for the Redis replication group."
  value       = module.redis.replication_group_primary_endpoint_address
}

output "redis_port" {
  description = "The port for the Redis replication group."
  value       = 6379
}

