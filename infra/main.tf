# [Phase 0] /infra/main.tf
# This is the root Terraform file for the entire Bazaar project.
# It composes all our local modules to build the complete infrastructure.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- Global Variables ---
variable "client_vpn_server_cert_arn" {
  type        = string
  description = "ARN of the ACM certificate for the VPN server."
}

variable "client_vpn_client_cert_arn" {
  type        = string
  description = "ARN of the ACM certificate for the VPN client."
}

variable "db_password" {
  type        = string
  description = "Password for the RDS database."
  sensitive   = true # This hides it from Terraform's console output
}

# --- Module Definitions ---

# 1. VPC (The "Bedrock")
module "bazaar_vpc" {
  source = "./modules/vpc"

  project_name         = "bazaar"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  cde_subnet_cidrs     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

# 2. EKS (The "Compute Fabric")
module "bazaar_eks" {
  source = "./modules/eks"

  project_name        = "bazaar"
  vpc_id              = module.bazaar_vpc.vpc_id
  private_subnet_ids  = module.bazaar_vpc.private_subnet_ids
  # --- FIX: Variable is 'cluster_version' in modules/eks/variables.tf ---
  cluster_version     = "1.29"
}

# 3. RDS (The "Primary Database")
module "bazaar_rds" {
  source = "./modules/rds"

  project_name        = "bazaar"
  vpc_id              = module.bazaar_vpc.vpc_id
  private_subnet_ids  = module.bazaar_vpc.private_subnet_ids
  # --- FIX: Variable is 'eks_cluster_security_group_id' in modules/rds/variables.tf ---
  eks_cluster_security_group_id = module.bazaar_eks.cluster_security_group_id
  db_username         = "bazaaradmin"
  db_password         = var.db_password
}

# 4. VPN (Developer Access)
module "bazaar_vpn" {
  source = "./modules/vpn"

  project_name         = "bazaar"
  vpc_id               = module.bazaar_vpc.vpc_id
  # --- FIX: 'vpc_cidr' is not an output of the vpc module ---
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_ids   = module.bazaar_vpc.private_subnet_ids
  # --- FIX: Variable is 'client_vpn_server_cert_arn' in modules/vpn/variables.tf ---
  client_vpn_server_cert_arn = var.client_vpn_server_cert_arn
  # --- FIX: Variable is 'client_vpn_client_cert_arn' in modules/vpn/variables.tf ---
  client_vpn_client_cert_arn = var.client_vpn_client_cert_arn
}

# 5. Redis (Caching)
module "bazaar_redis" {
  source = "./modules/redis"

  project_name      = "bazaar"
  # --- FIX: 'vpc_id' is a required variable in modules/redis/variables.tf ---
  vpc_id             = module.bazaar_vpc.vpc_id
  private_subnet_ids = module.bazaar_vpc.private_subnet_ids
  # --- NO FIX NEEDED: This was correct. 'eks_cluster_sg_id' matches modules/redis/variables.tf ---
  eks_cluster_sg_id  = module.bazaar_eks.cluster_security_group_id
}

# 6. Kafka (Message Broker)
module "bazaar_kafka" {
  source = "./modules/kafka"

  project_name       = "bazaar"
  vpc_id             = module.bazaar_vpc.vpc_id
  # --- FIX: 'azs' is not an output of the vpc module ---
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnet_ids = module.bazaar_vpc.private_subnet_ids
  # --- FIX: Using consistent name 'eks_cluster_security_group_id' ---
  eks_cluster_security_group_id = module.bazaar_eks.cluster_security_group_id
}

