variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev or prod."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones in which subnets will be created."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private application subnets."
  type        = list(string)
}

variable "private_data_subnet_cidrs" {
  description = "CIDRs for private data subnets."
  type        = list(string)
}

variable "private_ops_subnet_cidrs" {
  description = "CIDRs for private operations subnets."
  type        = list(string)
}
