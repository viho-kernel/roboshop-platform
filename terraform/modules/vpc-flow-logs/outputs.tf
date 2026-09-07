output "flow_log_id" {
  description = "ID of the VPC Flow Log."
  value       = aws_flow_log.vpc.id
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group receiving VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group receiving VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting Flow Logs."
  value       = aws_kms_key.flow_logs.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by the VPC Flow Logs service."
  value       = aws_iam_role.flow_logs.arn
}
