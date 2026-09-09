output "repository_names" {
  description = "ECR repository names indexed by application component."
  value = {
    for component, repository in aws_ecr_repository.this :
    component => repository.name
  }
}

output "repository_urls" {
  description = "ECR repository URLs indexed by application component."
  value = {
    for component, repository in aws_ecr_repository.this :
    component => repository.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs indexed by application component."
  value = {
    for component, repository in aws_ecr_repository.this :
    component => repository.arn
  }
}
