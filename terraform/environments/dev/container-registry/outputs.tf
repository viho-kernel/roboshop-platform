output "repository_names" {
  description = "ECR repository names indexed by application component."
  value       = module.ecr.repository_names
}

output "repository_urls" {
  description = "ECR repository URLs used for image tagging and pushing."
  value       = module.ecr.repository_urls
}

output "repository_arns" {
  description = "ECR repository ARNs used in IAM policies."
  value       = module.ecr.repository_arns
}
