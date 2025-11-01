# [Phase 0] /infra/modules/kafka/main.tf
# This module builds the AWS MSK (Kafka) cluster.

# 1. Create a Security Group for Kafka
resource "aws_security_group" "kafka_sg" {
  name        = "${var.project_name}-kafka-sg"
  description = "Allow inbound traffic from EKS nodes to Kafka"
  vpc_id      = var.vpc_id

  # Ingress Rule: Allow all Kafka traffic from the EKS cluster
  # MSK uses multiple ports (e.g., 9092, 9094, 2181)
  ingress {
    description     = "Allow Kafka from EKS"
    from_port       = 0 # Allow all ports for simplicity
    to_port         = 0
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
    Name = "${var.project_name}-kafka-sg"
  })
}

# 2. Call the public AWS MSK module
module "msk" {
  source  = "terraform-aws-modules/msk/aws"
  version = "~> 2.0" # Use a stable version

  name = "${var.project_name}-kafka-cluster"
  
  # Use settings from Network Configuration.txt
  kafka_version        = "3.5.1" # Use a modern, stable version
  broker_per_zone      = 1       # 1 broker per AZ, for 3 total (HA)
  broker_instance_type = "kafka.t3.small" # Good for dev/testing
  
  vpc_id         = var.vpc_id
  subnet_ids     = var.private_subnet_ids
  zone_ids       = var.azs
  
  security_groups = [aws_security_group.kafka_sg.id]

  # --- Security (from PROJECT SCOPE.txt and Network Config) ---
  # We will use IAM auth, as per msk_bootstrap_brokers_iam
  authentication_mode = "iam"
  
  encryption_in_transit_protocol = "TLS"
  encryption_at_rest_kms_key_arn = null # Use AWS-managed key by default

  # Enable logging (good for production)
  logs_cloudwatch_enabled = true
  logs_s3_enabled         = false
  
  tags = merge(var.tags, {
    Tier = "DataStore"
  })
}

