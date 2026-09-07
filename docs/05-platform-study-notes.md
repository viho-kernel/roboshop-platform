# RoboShop Platform — Shift Study Notes

These notes explain the platform we are building, why each layer exists, and how to use it during a real incident. They cover only implemented or explicitly designed work; planned items are marked **Next**.

## 1. The platform goal

RoboShop is a private, AWS-based microservices platform. We are building it as a DevOps engineer would: reusable Terraform, separate state per concern, pull-request change control, secure access, monitoring, and verified deployment.

```text
Engineer laptop
→ VPN-only administrative access
→ private platform services
→ EKS workloads and supporting services
```

The application is a group of services with dependencies such as databases, message queues, APIs, and a web frontend. DevOps ownership is not only “deploy pods”; it includes secure network foundations, reliable delivery, observability, cost awareness, and incident investigation.

## 2. Delivery discipline we are following

Every meaningful change follows this pattern:

```text
Feature branch
→ Terraform format and validation
→ reviewed plan
→ apply exact reviewed plan
→ verify with AWS CLI
→ PR review and squash merge
```

Why this matters in a real team:

- A feature branch prevents unfinished work from changing the shared baseline.
- A plan shows what AWS resources will change before cost or risk is introduced.
- Post-apply CLI checks prove AWS accepted and activated the configuration.
- A PR provides review history and an auditable decision trail.

## 3. Network foundation — completed

The development VPC is in Mumbai (`ap-south-1`) and uses `10.20.0.0/16` across two Availability Zones.

| Layer | CIDRs | Purpose |
|---|---|---|
| Public | `10.20.0.0/24`, `10.20.1.0/24` | NAT and VPN entry only |
| Private application | `10.20.16.0/20`, `10.20.32.0/20` | EKS application workloads |
| Private data | `10.20.48.0/24`, `10.20.49.0/24` | Databases and stateful services |
| Private operations | `10.20.64.0/24`, `10.20.65.0/24` | Jenkins, Grafana, Argo CD and operational tools |

Route intent:

```text
Public subnet       → Internet Gateway
Private app / ops   → NAT Gateway for controlled outbound access
Private data        → no direct internet path
```

### Real-time example

A Cart pod cannot reach Redis.

1. Check the pod logs and Kubernetes Service/Endpoints.
2. Check the relevant Security Group, NetworkPolicy, routes, and DNS.
3. Check VPC Flow Logs for traffic to port `6379`.
4. `REJECT` means investigate the network path.
5. `ACCEPT` means the VPC path likely works; investigate Redis, authentication, application configuration, or capacity.

## 4. Terraform state design — completed

Network resources and network observability use separate Terraform roots and separate remote state:

```text
dev/network
→ VPC, subnets, route tables, NAT

dev/network-observability
→ VPC Flow Logs, CloudWatch Log Group, KMS, IAM
```

The observability stack reads the VPC ID from the network stack’s remote-state output. We do not copy a live VPC ID into Terraform code.

**Why separate state?** Changing log retention should not cause Terraform to evaluate or alter VPC, NAT, or route resources.

## 5. VPC Flow Logs — completed and verified

VPC Flow Logs record network metadata, not packet contents. They help answer:

```text
Did traffic reach the AWS network?
Was it ACCEPT or REJECT?
Which source, destination, port, and interface were involved?
```

The implemented chain is:

```text
VPC traffic
→ VPC Flow Logs
→ dedicated IAM delivery role
→ encrypted CloudWatch Log Group
```

Controls implemented:

- Capture type: `ALL` (accepted and rejected traffic)
- Destination: CloudWatch Logs
- Retention: 30 days for development
- Encryption: dedicated customer-managed KMS key
- Delivery identity: dedicated VPC Flow Logs IAM role
- Trust-policy hardening: source account and regional Flow Log ARN conditions

### IAM concept to remember

```text
Trust policy       → who may assume this role?
Permission policy  → what may the assumed role do?
```

For Flow Logs:

```text
VPC Flow Logs service
→ assumes the delivery role
→ role writes log streams/events to CloudWatch
→ CloudWatch Logs uses the KMS key for this log group
```

### Live verification already completed

The deployed Flow Log was verified as:

- status: `ACTIVE`
- delivery: `SUCCESS`
- traffic type: `ALL`
- CloudWatch Log Group: KMS key attached
- retention: 30 days

Zero stored bytes immediately after creation is normal: meaningful workload network traffic had not begun yet.

## 6. OpenVPN private access — in progress

Security rule for the platform:

```text
Only the VPN endpoint is public.
No public SSH.
EKS, Jenkins, Grafana, Argo CD, databases, and internal load balancers stay private.
```

Planned access flow:

```text
Laptop
→ OpenVPN UDP 1194
→ OpenVPN EC2 in a public subnet
→ private app, operations, and data networks
```

OpenVPN Terraform module work started:

- Module inputs define VPC, public subnet, private subnets, client CIDR, and approved public client CIDRs.
- Security Group allows only UDP `1194` inbound from approved client CIDRs.
- There is no inbound TCP `22` rule.
- Static/default outbound IPv4 access remains enabled.
- An EC2 IAM role is created with the AWS-managed `AmazonSSMManagedInstanceCore` policy.
- An instance profile will attach that role to the OpenVPN EC2.
- Amazon Linux 2023 AMI is looked up through AWS’s SSM public parameter rather than hardcoding an AMI ID.

### SSM explanation

```text
OpenVPN EC2
→ instance profile
→ IAM role
→ AmazonSSMManagedInstanceCore
→ Session Manager terminal
```

This means we can administer the server through AWS Session Manager without opening public SSH.

### Next OpenVPN work

1. Create the EC2 gateway and attach Elastic IP, Security Group, and instance profile.
2. Disable EC2 source/destination check so it can route client traffic.
3. Configure OpenVPN and the client profile without committing keys or profiles.
4. Add private route-table return routes for the VPN client CIDR.
5. Verify VPN client access to approved private endpoints.

## 7. Shift revision checklist

Before the next build session, be able to answer:

1. Why do we use a separate Terraform state for observability?
2. What is the difference between a trust policy and a permission policy?
3. Why does CloudWatch Logs need a KMS key policy?
4. What does `ACCEPT` versus `REJECT` tell us in Flow Logs?
5. Why is public SSH intentionally absent from the VPN server?
6. Why does an EC2 instance need an instance profile to receive a role?
7. Why must a VPN gateway have return routes and source/destination check disabled?

## 8. Interview story

> I built a private AWS platform foundation using reusable Terraform modules and separate remote state for network and observability. I enabled encrypted VPC Flow Logs with 30-day retention and verified active, successful delivery to CloudWatch. I then designed VPN-only administrative access using an OpenVPN EC2 gateway with no public SSH and Session Manager-based administration. The goal was to keep workloads private while retaining controlled access and network-level incident evidence.
