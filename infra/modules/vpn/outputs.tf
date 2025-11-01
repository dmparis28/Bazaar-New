# [Phase 0] /infra/modules/vpn/outputs.tf
# Exports the VPN connection details

output "vpn_endpoint_id" {
  description = "The ID of the Client VPN Endpoint"
  value       = aws_ec2_client_vpn_endpoint.bazaar_vpn.id
}

output "vpn_client_config" {
  description = "The configuration file for OpenVPN clients (export and save as .ovpn)"
  value       = aws_ec2_client_vpn_endpoint.bazaar_vpn.client_connect_options[0].client_configuration
  sensitive   = true # This contains sensitive connection info
}
