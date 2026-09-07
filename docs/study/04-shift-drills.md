# 4. Shift Drills, Commands and Interview Answers

## Five-minute revision

1. **VPC** is the isolated AWS network address space.
2. **Subnets** separate public, app, data and operations workloads.
3. **Route tables** decide where packets go.
4. **NAT Gateway** gives private workloads outbound internet access.
5. **Terraform remote state** connects stacks without hardcoded resource IDs.
6. **Flow Logs** record network metadata and ACCEPT/REJECT.
7. **IAM trust policy** says who can assume a role.
8. **IAM permission policy** says what the role can do.
9. **KMS key policy** authorizes use of encryption keys.
10. **OpenVPN** will be the only public administrative entry point.

## Useful commands and what they prove

```bash
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform show -no-color tfplan
terraform apply tfplan
```

```text
fmt      → readable consistent code
validate → valid Terraform configuration
plan     → exact intended AWS changes
show     → reviewer sees plan content
apply    → AWS resources are changed
```

Flow Log verification pattern:

```bash
aws ec2 describe-flow-logs --region ap-south-1 --flow-log-ids <id>
aws logs describe-log-groups --region ap-south-1 --log-group-name-prefix <name>
```

Do not paste live IDs, account IDs, plans, state files, certificates, private keys or VPN profiles into public GitHub content.

## Q&A: explain it like an interview

### Why separate network and observability Terraform state?

Because different concerns change at different rates. A Flow Log retention change should not put VPC routes or NAT resources in the same operational plan. Separate state reduces blast radius and makes review clearer.

### What is the difference between a trust policy and a permission policy?

Trust policy answers “who may become this role?” Permission policy answers “after becoming it, what actions are allowed?” Flow Logs trusts the AWS Flow Logs service, then permits CloudWatch log delivery actions.

### Why Flow Logs ALL instead of ACCEPT only?

ACCEPT tells us successful network flows; REJECT gives direct evidence of denied traffic. For incident investigation we need both signals.

### Why does CloudWatch need a KMS policy?

CloudWatch Logs is an AWS service, not automatically an administrator of a customer-managed key. The KMS key policy explicitly permits its regional service principal to use that key for the intended log group.

### Why no public SSH on the VPN server?

SSH exposed to the internet increases attack surface and key-management responsibility. Session Manager provides controlled terminal access without inbound port 22 or SSH keys.

### Why does a VPN router need source/destination check disabled?

A normal EC2 instance only sends/receives its own packets. The VPN gateway forwards packets between VPN clients and private subnets, so AWS must permit it to act as a router.

## Scenario drill: “I cannot open Grafana”

Ask questions in this order:

1. Is the VPN connected and did the laptop get a VPN client IP?
2. Does the route to the operations subnet exist?
3. Is the VPN gateway forwarding?
4. Does the Grafana Security Group permit the required source?
5. Do Flow Logs show ACCEPT or REJECT?
6. If accepted, is Grafana process/load balancer/DNS healthy?

This prevents random troubleshooting. Start at the client, walk the packet path, then check the application.

## Scenario drill: “Terraform says apply succeeded but it does not work”

Terraform success means AWS accepted the API request. It does not prove that an asynchronous AWS service is delivering data or that traffic works.

Always perform live verification:

```text
Terraform state
→ AWS resource status
→ service delivery/health
→ real client test
```

## Interview story to practise

> I built the foundation of a private AWS microservices platform using reusable Terraform. I separated network and observability state to reduce blast radius, then enabled VPC Flow Logs for both accepted and rejected traffic. The logs are stored in CloudWatch with a 30-day development retention policy and customer-managed KMS encryption. I verified that Flow Logs were ACTIVE with successful delivery. For administration, I designed VPN-only access using an OpenVPN EC2 gateway with no public SSH; the server uses an EC2 IAM role and Session Manager for terminal access. This keeps workloads private while giving the operations team controlled access and network evidence for incident investigation.
