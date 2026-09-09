output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Private Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security Group protecting the EKS control plane."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security Group attached to the managed worker nodes."
  value       = module.eks.node_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role used by the EKS control plane."
  value       = module.eks.cluster_iam_role_arn
}
