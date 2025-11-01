# [Phase 0] /infra/modules/eks/variables.tf
# Defines the inputs our local "bazaar-eks" module accepts.

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "bazaar"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "bazaar-cluster"
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29" # Use a modern, stable version
}

# --- VPC Inputs ---
# These will be fed from our root module's outputs

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the K8s node groups"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
