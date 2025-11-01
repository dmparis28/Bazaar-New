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
#
# --- FIX ---
# Updated 'source' to 'msk-kafka-cluster' based on the module README.
# Updated all arguments (e.g., 'subnet_ids' -> 'broker_node_client_subnets')
# to match the new module's inputs.
#
module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "~> 2.13" # Use the modern version from the README you found

  name = "${var.project_name}-kafka-cluster"

  # Use settings from Network Configuration.txt
  kafka_version = "3.5.1" # Use a modern, stable version

  # --- Argument Changes ---
  # 'broker_per_zone' & 'zone_ids' are replaced by 'number_of_broker_nodes'
  # We have 3 private subnets, so we want 3 nodes.
  number_of_broker_nodes = 3
  # --- FIX: Renamed 'broker_instance_type' to 'broker_node_instance_type' ---
  broker_node_instance_type   = "kafka.t3.small" # Good for dev/testing

  # 'subnet_ids' is replaced by 'broker_node_client_subnets'
  broker_node_client_subnets = var.private_subnet_ids
  # 'security_groups' is replaced by 'broker_node_security_groups'
  broker_node_security_groups = [aws_security_group.kafka_sg.id]

  # --- Security (from PROJECT SCOPE.txt and Network Config) ---
  # 'authentication_mode = "iam"' is replaced by this block
  client_authentication = {
    sasl = {
      iam = true
    }
  }

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true
  encryption_at_rest_kms_key_arn      = null # Use AWS-managed key by default

  # Enable logging (good for production)
  cloudwatch_logs_enabled = true
  s3_logs_enabled         = false

  tags = merge(var.tags, {
    Tier = "DataStore"
  })
}


