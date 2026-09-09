variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "roboshop-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "repository_names" {
  description = "RoboShop application image repositories."
  type        = set(string)

  default = [
    "frontend",
    "catalogue",
    "user",
    "cart",
    "shipping",
    "payment",
    "dispatch"
  ]
}

variable "untagged_image_retention_days" {
  description = "Days after which untagged development images expire."
  type        = number
  default     = 7
}

variable "max_image_count" {
  description = "Maximum images retained per development repository."
  type        = number
  default     = 20
}
