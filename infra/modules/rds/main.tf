# [Phase 0] /infra/modules/rds/main.tf
# This module calls the public RDS module to build our PostgreSQL database.

# 1. Create a Subnet Group for the database
# This tells RDS which subnets it's allowed to live in.
resource "aws_db_subnet_group" "bazaar_db_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

# 2. Create a Security Group for the database
# This acts as a firewall, locking down access.
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow inbound traffic from EKS nodes"
  vpc_id      = var.vpc_id

  # Ingress Rule: Allow PostgreSQL (port 5432)
  # from the EKS cluster's security group.
  ingress {
    description     = "Allow PostgreSQL from EKS"
    from_port       = 5432 # From Network Configuration.txt
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
  }

  # Egress Rule: Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-sg"
  })
}

# 3. Call the public AWS RDS module
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = var.db_name

  engine               = "postgres"
  engine_version       = "15.5" # Use a modern, stable version
  family               = "postgres15"
  instance_class       = "db.t3.micro" # Good for dev/testing
  allocated_storage    = 20            # Start small
  storage_type         = "gp2"
  username             = var.db_username
  password             = var.db_password
  port                 = 5432
  db_name              = "bazaar" # The actual database *inside* the server

  # [Phase 0] "(HA) Provision a Multi-AZ managed database"
  multi_az = true 

  db_subnet_group_name   = aws_db_subnet_group.bazaar_db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # Disable public access
  publicly_accessible = false

  # Enable deletion protection in a real environment
  deletion_protection = false # Set to true for prod

  tags = merge(var.tags, {
    Tier = "Database"
  })
}
