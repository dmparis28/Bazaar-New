# [Phase 0] /infra/modules/vpn/outputs.tf
# Exports the VPN connection details

output "vpn_endpoint_id" {
  description = "The ID of the Client VPN Endpoint"
  value       = aws_ec2_client_vpn_endpoint.bazaar_vpn.id
}

# --- FIX ---
# The 'aws_ec2_client_vpn_endpoint' resource does not export the .ovpn
# configuration file. This must be downloaded manually from the AWS Console.
#
# To get the config:
# 1. Go to the AWS VPC console -> Client VPN Endpoints
# 2. Select the endpoint (using the ID from the output above)
# 3. Click "Download Client Configuration"
#
# The 'vpn_client_config' output block below was invalid and has been removed.
#
# output "vpn_client_config" {
#   description = "The configuration file for OpenVPN clients (export and save as .ovpn)"
#   value       = aws_ec2_client_vpn_endpoint.bazaar_vpn.client_connect_options[0].client_configuration
#   sensitive   = true # This contains sensitive connection info
# }
