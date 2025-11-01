# [Phase 0] /infra/modules/vpn/main.tf
# This module provisions the AWS Client VPN Endpoint.

# 1. Security Group for the VPN
resource "aws_security_group" "vpn_sg" {
  name        = "${var.project_name}-vpn-sg"
  description = "Allow VPN clients"
  vpc_id      = var.vpc_id

  # Allow all internal traffic from VPN clients
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] # Adjust this to your VPN client CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpn-sg"
  })
}

# 2. Create the Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "bazaar_vpn" {
  description            = "${var.project_name} Client VPN"
  server_certificate_arn = var.client_vpn_server_cert_arn
  client_cidr_block      = "10.0.0.0/16" # IP range to assign to clients

  # Use mutual authentication (client + server certs)
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_vpn_client_cert_arn
  }

  # Log connections (optional but recommended)
  connection_log_options {
    enabled = false
  }

  # Use UDP for best performance
  transport_protocol = "udp"
  security_group_ids = [aws_security_group.vpn_sg.id]
  vpc_id             = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-vpn"
    Tier = "Networking"
  })
}

# 3. Associate VPN with Private Subnets
# This is what gives you access to the EKS/RDS subnets
resource "aws_ec2_client_vpn_network_association" "vpn_assoc" {
  count                     = length(var.private_subnet_ids)
  client_vpn_endpoint_id    = aws_ec2_client_vpn_endpoint.bazaar_vpn.id
  subnet_id                 = var.private_subnet_ids[count.index]
 
}

# 4. Authorize clients to access the VPC
# This rule allows connected VPN clients to access all resources in the VPC.
resource "aws_ec2_client_vpn_authorization_rule" "bazaar_vpn_auth" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.bazaar_vpn.id
  
  target_network_cidr    = var.vpc_cidr # Use the variable, not the module

  authorize_all_groups   = true
  description            = "Allow all clients to access the VPC"
}

