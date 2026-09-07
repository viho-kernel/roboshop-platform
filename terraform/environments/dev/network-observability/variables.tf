variable "aws_region" {
  description = "AWS region for the RoboShop development environment."
  type        = string
  default     = "ap-south-1"
}

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

variable "flow_log_retention_in_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch."
  type        = number
  default     = 30
}
