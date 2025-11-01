# [Phase 0] /infra/modules/redis/main.tf
# This module provisions the AWS ElastiCache (Redis) cluster.
# It uses the public module and configures it for HA and security.

module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.1"

  description = "Bazaar Redis cluster for caching"
  subnet_ids  = var.private_subnet_ids

  # --- High Availability (from PROJECT SCOPE.txt) ---
  create_replication_group = true # This is what gives us a primary/replica setup
  replication_group_id     = "${var.project_name}-redis" # e.g., "bazaar-redis"
  multi_az_enabled         = true
  # ERROR FIX: This is essential for a Multi-AZ replication group
  automatic_failover_enabled = true

  # --- Security (Zero Trust) ---
  # This is the key: only allow connections from our EKS cluster.
  security_group_ids = [var.eks_cluster_sg_id]

  # --- Instance Sizing ---
  node_type = "cache.t3.small"
  # ERROR FIX: The argument is `num_cache_clusters`, not `number_cache_clusters`
  num_cache_clusters = 2 # 1 primary, 1 replica for HA
  port               = 6379

  tags = merge(var.tags, {
    Tier = "DataStore"
  })
}

