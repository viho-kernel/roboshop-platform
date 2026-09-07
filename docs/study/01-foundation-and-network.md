# 1. Platform Foundation, VPC and Terraform State

## The problem before we created anything

RoboShop will eventually have application services, EKS nodes, databases, CI/CD and monitoring. If every service is public, the platform is easy to reach but difficult to secure. If every service is private without an approved access path, engineers cannot operate it.

Our foundation therefore has two rules:

```text
1. Workloads are private by default.
2. Administrative access is deliberate, auditable and later VPN-only.
```

## Network layout

The development VPC uses `10.20.0.0/16` in Mumbai (`ap-south-1`) across two Availability Zones.

| Layer | CIDRs | Why it exists |
|---|---|---|
| Public | `10.20.0.0/24`, `10.20.1.0/24` | NAT Gateway and the future VPN gateway |
| Private application | `10.20.16.0/20`, `10.20.32.0/20` | EKS workloads and internal application services |
| Private data | `10.20.48.0/24`, `10.20.49.0/24` | Databases/stateful services; no direct internet path |
| Private operations | `10.20.64.0/24`, `10.20.65.0/24` | Jenkins, Grafana, Argo CD and operational tools |

Two AZs are not decoration. If one AZ has a problem, a workload designed across both can continue from the other. In a lab we still control cost, but the topology teaches the production pattern.

## Route tables: the traffic decision makers

A subnet does not decide where traffic goes; its **route table** does.

```text
Public subnet:
0.0.0.0/0 → Internet Gateway

Private application/operations subnet:
0.0.0.0/0 → NAT Gateway → Internet Gateway

Private data subnet:
no default route to the internet
```

Important: a NAT Gateway allows private servers to start outbound connections—for package updates, ECR image pulls or AWS APIs—without accepting unsolicited inbound connections from the internet.

### Example: EKS node pulling an image

```text
Private EKS node
→ NAT Gateway
→ Internet Gateway
→ ECR public/API endpoint
→ image download returns through the established connection
```

The node remains private. Nobody on the internet can create a new connection to it.

## Why not put everything in one Terraform folder?

We separate state by ownership and blast radius.

```text
terraform/environments/dev/network
→ VPC, subnets, route tables, NAT

terraform/environments/dev/network-observability
→ Flow Logs, CloudWatch Logs, KMS, IAM
```

A Terraform state file is the record Terraform uses to map code to real AWS resources. If observability and networking share one huge state, a simple retention-policy change forces Terraform to load and evaluate the VPC, routes and NAT configuration too.

Separate state means:

- smaller plans
- clearer ownership
- less accidental change risk
- easier incident rollback reasoning

The observability stack uses remote state to read only the required VPC output:

```text
network state output: vpc_id
→ network-observability module input: vpc_id
→ aws_flow_log attaches to that VPC
```

We do not hardcode a real VPC ID in source code.

## Terraform commands: what each one really does

| Command | Meaning | Changes AWS? |
|---|---|---|
| `terraform fmt` | Formats HCL consistently | No |
| `terraform init` | Configures backend/downloads providers/modules | No |
| `terraform validate` | Checks Terraform syntax and internal references | No |
| `terraform plan -out=tfplan` | Calculates and saves proposed AWS changes | No |
| `terraform show tfplan` | Lets a reviewer inspect the exact saved plan | No |
| `terraform apply tfplan` | Applies the reviewed plan artifact | Yes |

We deliberately applied a saved plan, rather than typing `terraform apply` after review. In a real team this is similar to approving a specific change artifact instead of approving a moving target.

## PR workflow

```text
feature branch
→ code + fmt + validate
→ plan review
→ apply + live verification
→ push branch
→ second-account PR approval
→ squash merge into main
```

The repository rules block direct pushes to `main`. That is not an error; it is a guardrail. It makes every shared change pass through a PR.

## What to remember

> VPC is the private address space. Subnets divide it by purpose. Route tables decide how packets leave. NAT gives private workloads controlled outbound access. Terraform state separates operational ownership and blast radius.
