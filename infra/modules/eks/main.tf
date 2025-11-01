# [Phase 0] /infra/modules/eks/main.tf
# This module calls the public EKS module to build our cluster.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # [Phase 0] "(HA) Provision a managed K8s cluster"
  # This links our EKS cluster to the VPC we just built.
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids # We only deploy nodes to private subnets

  # [Phase 0] "(HA) Configure the node groups to run... across multiple Availability Zones"
  # This creates a "managed node group" for our general microservices.
  eks_managed_node_groups = {
    general_purpose = {
      name           = "${var.project_name}-general-nodes"
      instance_types = ["t3.medium", "t3.large"]
      min_size       = 2 # Start with 2 nodes
      max_size       = 10 # Allow auto-scaling up to 10
      desired_size   = 3 # Run 3 nodes for Multi-AZ HA

      # Place nodes *only* in the private subnets
      subnet_ids = var.private_subnet_ids
    }
  }

  tags = merge(var.tags, {
    Tier       = "Compute"
    "eks:cluster" = var.cluster_name
  })
}
