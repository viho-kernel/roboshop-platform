variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region where OpenVPN is deployed."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC hosting the OpenVPN instance."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where the OpenVPN instance is deployed."
  type        = string
}

variable "private_route_table_ids" {
  description = "Route table IDs that need return routes to VPN clients."
  type        = list(string)
}

variable "vpn_client_cidr" {
  description = "CIDR block assigned to connected OpenVPN clients."
  type        = string
  default     = "10.250.0.0/24"
}

variable "allowed_vpn_ingress_cidrs" {
  description = "Public client CIDRs permitted to initiate OpenVPN connections."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the development OpenVPN server."
  type        = string
  default     = "t3.micro"
}
