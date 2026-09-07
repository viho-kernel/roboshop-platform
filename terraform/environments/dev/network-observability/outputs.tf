output "flow_log_id" {
  description = "ID of the active development VPC Flow Log."
  value       = module.vpc_flow_logs.flow_log_id
}

output "flow_log_group_name" {
  description = "CloudWatch Log Group name for VPC Flow Logs."
  value       = module.vpc_flow_logs.log_group_name
}

output "flow_log_group_arn" {
  description = "CloudWatch Log Group ARN for VPC Flow Logs."
  value       = module.vpc_flow_logs.log_group_arn
}
