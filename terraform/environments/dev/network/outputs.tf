output "vpc_id" {
  description = "ID of the RoboShop development VPC."
  value       = module.vpc.vpc_id
}

output "availability_zones" {
  description = "Availability Zones selected for the development network."
  value       = module.vpc.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  value       = module.vpc.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "Private data subnet IDs."
  value       = module.vpc.private_data_subnet_ids
}

output "private_ops_subnet_ids" {
  description = "Private operations subnet IDs."
  value       = module.vpc.private_ops_subnet_ids
}
