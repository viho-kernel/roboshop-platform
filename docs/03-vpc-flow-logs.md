# VPC Flow Logs

## Purpose

VPC Flow Logs provide network-level evidence for RoboShop incident investigation.

They capture accepted and rejected IP traffic for the development VPC and deliver records to CloudWatch Logs.

## Design

- Traffic captured: `ALL` (accepted and rejected)
- Destination: CloudWatch Logs
- Encryption: customer-managed AWS KMS key
- Retention: 30 days in development
- Delivery identity: dedicated IAM role trusted only by the VPC Flow Logs service

## Operational Use

Use VPC Flow Logs when investigating:

- Security group or NACL connectivity blocks
- Failed application-to-database connections
- Missing routes or NAT egress issues
- Unexpected traffic reaching an interface
- Network behaviour during an incident

## Verification

After deployment, verify:

1. Flow Log status is `ACTIVE`.
2. Delivery status is `SUCCESS`.
3. The CloudWatch Log Group has the expected retention period.
4. The Log Group has a KMS key associated.
5. Flow Log records appear after workload network traffic exists.

## Security Rules

- Do not commit live resource IDs, IP addresses, account-specific CLI output, Terraform state, or Terraform plan files.
- Investigate access through approved IAM/SSO roles only.
- Treat Flow Logs as one signal; correlate them with Security Groups, application logs, Kubernetes events, and CloudWatch metrics.
