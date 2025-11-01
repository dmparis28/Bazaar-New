# [Phase 0] /infra/modules/vpn/variables.tf
# Defines the inputs our local "bazaar-vpn" module accepts.

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "bazaar"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# --- ADD THIS VARIABLE ---
variable "vpc_cidr" {
  description = "The CIDR block of the VPC (e.g., 10.0.0.0/16)"
  type        = string
}
# --- END ADD ---

variable "private_subnet_ids" {
  description = "List of private subnets to associate the VPN with for access"
  type        = list(string)
}

variable "client_vpn_server_cert_arn" {
  description = "ARN of the server certificate from AWS Certificate Manager (ACM)"
  type        = string
  # NOTE: You must create this certificate in ACM first!
  # This is a one-time manual step.
}

variable "client_vpn_client_cert_arn" {
  description = "ARN of the client certificate from AWS Certificate Manager (ACM)"
  type        = string
  # NOTE: You must create this certificate in ACM first!
}


variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

