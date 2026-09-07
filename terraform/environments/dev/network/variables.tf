variable "project_name" {
  description = "Project name used in resource tags."
  type        = string
  default     = "roboshop-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR range for the RoboShop VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zone_count" {
  description = "Number of available AWS Availability Zones to use."
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets; NAT Gateway only in this design."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for EKS nodes and pod networking."
  type        = list(string)
  default     = ["10.20.16.0/20", "10.20.32.0/20"]
}

variable "private_data_subnet_cidrs" {
  description = "CIDRs for private database, cache, and messaging workloads."
  type        = list(string)
  default     = ["10.20.48.0/24", "10.20.49.0/24"]
}

variable "private_ops_subnet_cidrs" {
  description = "CIDRs for Jenkins, runners, and utility hosts."
  type        = list(string)
  default     = ["10.20.64.0/24", "10.20.65.0/24"]
}
