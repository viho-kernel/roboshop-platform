# 2. VPC Flow Logs, IAM, CloudWatch and KMS

## Why Flow Logs were the first observability control

Before EKS, applications or databases exist, we still need evidence when networking fails.

VPC Flow Logs answer network-layer questions:

```text
Did traffic reach the VPC network path?
Which source and destination were involved?
Which port/protocol was used?
Did AWS record ACCEPT or REJECT?
```

They do **not** show HTTP request bodies, passwords, SQL queries or packet payloads. They are network metadata, not packet capture.

## What we deployed

```text
VPC traffic
→ aws_flow_log
→ VPC Flow Logs service assumes IAM role
→ CloudWatch Log Group
→ data encrypted with dedicated KMS key
```

Six AWS resources were created:

| Resource | Job |
|---|---|
| KMS key | Encrypt Flow Log data |
| KMS alias | Human-friendly name for the key |
| CloudWatch Log Group | Storage and query destination |
| IAM role | Identity assumed by the Flow Logs service |
| IAM role policy | CloudWatch write permissions |
| VPC Flow Log | Turns collection on for the VPC |

## Capture configuration

`traffic_type = "ALL"` means both accepted and rejected records are captured.

```text
ACCEPT → AWS network controls allowed the flow
REJECT → a network control blocked or rejected the flow
```

The default aggregation interval is up to 10 minutes. So do not expect it to behave like a live packet sniffer.

## IAM: the one distinction you must know

Every role has two different policy ideas.

| Policy | Question |
|---|---|
| Trust policy | Who is allowed to become this role? |
| Permission policy | After becoming it, what can that identity do? |

For Flow Logs:

```text
Trust policy:
vpc-flow-logs.amazonaws.com may assume the role

Permission policy:
the assumed role may create/describe CloudWatch log groups and streams,
then put log events
```

The trust policy is hardened with source-account and source-ARN conditions. This is protection against confused-deputy style misuse: the service must be acting for our account and a Flow Log in our region.

## KMS: encryption needs permission too

A KMS key is not just an encryption switch. Its key policy controls who may use it.

```text
Account root
→ retains administration/recovery control

CloudWatch Logs service in ap-south-1
→ may use the key for the intended Flow Logs log group
```

The encryption-context condition restricts the CloudWatch use to the expected log-group ARN. In plain language:

> This KMS key may encrypt/decrypt logs for this intended log group, not for every random CloudWatch log group.

The KMS key has rotation enabled and a 30-day deletion window. The deletion window protects against immediate loss if a delete action is requested accidentally.

## Live verification performed

After Terraform applied the exact reviewed plan, AWS CLI verification proved:

```text
Flow Log status: ACTIVE
Delivery status: SUCCESS
Traffic type: ALL
CloudWatch retention: 30 days
KMS key: associated with log group
```

A result of `StoredBytes = 0` immediately after deployment is expected because no meaningful workload traffic was running yet.

## Real incident example: Cart cannot reach Redis

Assume Cart reports connection timeouts to Redis on port `6379`.

1. Check application/pod logs: connection refused, timeout or authentication error?
2. Check Kubernetes Service and Endpoints: is Redis reachable through service discovery?
3. Check Security Groups/NACL/NetworkPolicy and route tables.
4. Query Flow Logs for source ENI, Redis destination address and port `6379`.
5. If Flow Logs show `REJECT`, start with AWS/Kubernetes network controls.
6. If they show `ACCEPT`, the network is likely not the root cause; check Redis process, credentials, TLS, max clients, or application configuration.
7. Make the permanent fix through Git/Terraform/Helm—not as an undocumented console change.

## Common mistakes

| Mistake | Why it is wrong |
|---|---|
| Expecting Flow Logs to show request body | They record metadata only |
| Capturing only ACCEPT traffic | You lose direct evidence of blocked traffic |
| No retention policy | Costs can grow indefinitely |
| Reusing unrelated KMS keys without reason | Weakens separation of responsibility |
| Trusting Terraform apply alone | AWS service status/delivery still needs verification |

## What to remember

> Flow Logs tell us whether the network path was allowed or rejected. IAM gives the Flow Logs service a delivery identity. CloudWatch stores the evidence. KMS protects the evidence at rest.
