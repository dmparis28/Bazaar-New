# [Phase 0] /infra/main.tf
# This is the "root" module. Its only job is to
# call our local, custom-built modules.

module "bazaar_vpc" {
  # This tells Terraform to use our local module
  source = "./modules/vpc" 

  # We can pass in variables here, but for now
  # we'll use the defaults defined in variables.tf
  tags = {
    Project = "Bazaar"
    Owner   = "dmparis28"
  }
}

# [Phase 0] "Compute Fabric"
module "bazaar_eks" {
  source = "./modules/eks"

  # Link to VPC outputs
  vpc_id             = module.bazaar_vpc.vpc_id
  private_subnet_ids = module.bazaar_vpc.private_subnet_ids

  # Pass in our standard tags
  tags = {
    Project = "Bazaar"
    Owner   = "dmparis28"
  }
}


# [Phase 0] "Core Data Stores"
# This block calls our new RDS module and stitches
# it to both the VPC and EKS modules.
module "bazaar_rds" {
  source = "./modules/rds"

  # Link to VPC outputs
  vpc_id             = module.bazaar_vpc.vpc_id
  private_subnet_ids = module.bazaar_vpc.private_subnet_ids

  # Link to EKS output
  eks_cluster_security_group_id = module.bazaar_eks.cluster_security_group_id

  # Pass in our standard tags
  tags = {
    Project = "Bazaar"
    Owner   = "dmparis28"
  }
}

