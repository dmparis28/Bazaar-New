# [Phase 0] /infra/modules/kafka/variables.tf
# Defines the inputs our local "bazaar-kafka" module accepts.

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "bazaar"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "azs" {
  description = "A list of Availability Zones to deploy the cluster across"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnets for the Kafka brokers"
  type        = list(string)
}

# This is named to match the RDS module for consistency
variable "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster, to allow connections"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

