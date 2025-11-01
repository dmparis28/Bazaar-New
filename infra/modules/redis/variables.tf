# [Phase 0] /infra/modules/redis/variables.tf
# Defines the inputs for our Redis (ElastiCache) module.

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the Redis cluster."
  type        = list(string)
}

variable "eks_cluster_sg_id" {
  description = "The security group ID of the EKS cluster to allow access."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

