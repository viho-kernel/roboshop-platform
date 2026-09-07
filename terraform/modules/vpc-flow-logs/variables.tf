variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region containing the VPC and CloudWatch Log Group."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC for which Flow Logs are enabled."
  type        = string
}

variable "log_retention_in_days" {
  description = "Number of days to retain Flow Logs in CloudWatch."
  type        = number
}
