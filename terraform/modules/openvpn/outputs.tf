output "instance_id" {
  description = "ID of the OpenVPN EC2 instance."
  value       = aws_instance.openvpn.id
}

output "private_ip" {
  description = "Private IP address of the OpenVPN EC2 instance."
  value       = aws_instance.openvpn.private_ip
}

output "elastic_ip" {
  description = "Public Elastic IP address used by OpenVPN clients."
  value       = aws_eip.openvpn.public_ip
}

output "security_group_id" {
  description = "Security Group ID attached to the OpenVPN EC2 instance."
  value       = aws_security_group.openvpn.id
}
