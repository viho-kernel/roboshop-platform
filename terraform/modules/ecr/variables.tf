variable "project_name" {
  description = "Project name used for ECR repository naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev or prod."
  type        = string
}

variable "repository_names" {
  description = "Names of application container repositories."
  type        = set(string)

  validation {
    condition = alltrue([
      for name in var.repository_names :
      can(regex("^[a-z0-9]+(?:[._/-][a-z0-9]+)*$", name))
    ])
    error_message = "Repository names must use valid lowercase ECR naming characters."
  }
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged images."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days >= 1
    error_message = "Untagged image retention must be at least one day."
  }
}

variable "max_image_count" {
  description = "Maximum number of images retained in each repository."
  type        = number
  default     = 20

  validation {
    condition     = var.max_image_count >= 1
    error_message = "Maximum image count must be at least one."
  }
}
