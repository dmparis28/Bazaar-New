# [Phase 0] /infra/modules/rds/variables.tf
# Defines the inputs our local "bazaar-rds" module accepts.

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "bazaar"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "bazaar-db"
}

variable "db_username" {
  description = "The admin username for the database"
  type        = string
  default     = "bazaaradmin" # From Network Configuration.txt
}

variable "db_password" {
  description = "The admin password for the database. THIS WILL BE VISIBLE IN STATE."
  type        = string
  default     = "BazaarPassword123!" # !! In a real project, use Vault or AWS Secrets Manager
  sensitive   = true
}

# --- VPC Inputs ---
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnets for the database"
  type        = list(string)
}

# --- EKS Input ---
variable "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster, to allow connections"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
