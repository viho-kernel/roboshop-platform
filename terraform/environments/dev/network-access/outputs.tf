output "openvpn_instance_id" {
  description = "EC2 instance ID for SSM administration."
  value       = module.openvpn.instance_id
}

output "openvpn_private_ip" {
  description = "Private IP address of the OpenVPN gateway."
  value       = module.openvpn.private_ip
}

output "openvpn_elastic_ip" {
  description = "Public Elastic IP address used by OpenVPN clients."
  value       = module.openvpn.elastic_ip
}

output "openvpn_security_group_id" {
  description = "Security Group ID for VPN-based access rules."
  value       = module.openvpn.security_group_id
}
