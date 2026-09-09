variable "aws_region" {
  description = "AWS Region for the EKS platform."
  type        = string
  default     = "ap-south-1"
}

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

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS cluster."
  type        = string
  default     = "1.35"
}

variable "vpn_client_cidr" {
  description = "CIDR allocated to authenticated OpenVPN clients."
  type        = string
  default     = "10.250.0.0/24"
}

variable "administrator_role_arn" {
  description = "Permanent IAM Identity Center role granted EKS administrator access."
  type        = string
  default     = "arn:aws:iam::992989046853:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_884f6e241931c4fb"
}
