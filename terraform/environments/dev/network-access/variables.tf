variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
  default     = "roboshop-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the development environment."
  type        = string
  default     = "ap-south-1"
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
