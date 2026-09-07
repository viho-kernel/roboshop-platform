output "vpc_id" {
  description = "ID of the RoboShop VPC."
  value       = aws_vpc.this.id
}

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "IDs of the private data subnets."
  value       = aws_subnet.private_data[*].id
}

output "private_ops_subnet_ids" {
  description = "IDs of the private operations subnets."
  value       = aws_subnet.private_ops[*].id
}

output "nat_gateway_id" {
  description = "ID of the development NAT Gateway."
  value       = aws_nat_gateway.this.id
}
