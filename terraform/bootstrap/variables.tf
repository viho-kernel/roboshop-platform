variable "aws_region" {
  description = "AWS region for the Terraform remote state backend."
  type        = string
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for RoboShop Terraform state."
  type        = string
  default     = "roboshop-platform-tfstate-992989046853-ap-south-1"
}

variable "project_name" {
  description = "Project tag applied to bootstrap resources."
  type        = string
  default     = "roboshop-platform"
}
