# RoboShop Private EKS Platform Design

## Purpose

Define the Kubernetes control plane, compute, access, networking, security, and operational decisions before provisioning the RoboShop development EKS cluster.

## Architecture

| Area | Development decision |
|---|---|
| AWS Region | `ap-south-1` |
| Kubernetes version | `1.35` |
| Cluster endpoint | Private only |
| Administrative network path | Laptop → OpenVPN → VPC → private EKS API |
| Administrator identity | IAM Identity Center AdministratorAccess role |
| Authentication mode | EKS API access entries |
| Worker placement | Private application subnets across two Availability Zones |
| Worker management | EKS managed node group |
| Worker instance type | `t3.medium` |
| Capacity type | On-Demand |
| Initial node count | Minimum 1, desired 2, maximum 4 |
| Worker operating system | Amazon Linux 2023 EKS-optimized image |
| Node administration | SSM and Kubernetes diagnostics; no inbound SSH |
| Workload exposure | Internal load balancers only |
| Container registry | Private Amazon ECR repositories |
| Infrastructure management | Terraform with independently managed EKS state |

## Access Model

The Kubernetes API public endpoint will be disabled. Administrators must authenticate through AWS IAM Identity Center and have a working network path through OpenVPN to reach the private endpoint.

The permanent IAM Identity Center role will be registered using an EKS access entry and associated with the Amazon EKS cluster-administrator access policy.

Temporary STS assumed-role session ARNs will not be stored in Terraform.

## Network Model

- EKS control-plane network interfaces will use the private application subnets.
- Managed nodes will run in both private application subnets.
- Nodes will not receive public IPv4 addresses.
- Existing NAT routing will provide controlled outbound access for image pulls and AWS APIs.
- Private application subnets carry the `kubernetes.io/role/internal-elb = 1` discovery tag.
- The EKS API Security Group will allow TCP 443 from the routed VPN client CIDR `10.250.0.0/24`.
- Public internet-facing Kubernetes load balancers are outside the development design.

## Managed Node Group

The initial managed node group uses two `t3.medium` instances distributed across the available private application subnets.

Scaling boundaries:

- Minimum: 1
- Desired: 2
- Maximum: 4

The minimum permits development cost reduction, while the desired count demonstrates multi-AZ scheduling. Production would use capacity and availability requirements derived from workload requests, disruption budgets, and scaling tests.

## Cluster Add-ons

The initial AWS-managed add-ons are:

- Amazon VPC CNI
- CoreDNS
- kube-proxy
- EKS Pod Identity Agent

Additional components such as the EBS CSI driver, AWS Load Balancer Controller, metrics-server, ExternalDNS, and observability agents will be installed when their IAM and workload requirements are implemented.

## Terraform Module Strategy

The environment will consume a pinned release of the community `terraform-aws-modules/eks/aws` module.

The version will be pinned rather than automatically following the newest release. Module inputs, generated IAM resources, Security Groups, node groups, add-ons, and upgrade notes must be reviewed before adoption.

This reflects a common enterprise model in which application or platform teams consume approved reusable modules rather than rebuilding every AWS resource from the lowest-level primitives.

## Availability and Cost

The development environment uses one NAT Gateway and a managed node group that spans two Availability Zones. This provides useful multi-AZ workload practice but does not make every network component highly available.

The EKS control plane, EC2 nodes, NAT Gateway, storage, and load balancers incur ongoing charges. Compute will be scaled down or destroyed when not required, according to the documented recovery procedure.

## Current Deployment Blocker

The account's Running On-Demand Standard instance quota is currently 1 vCPU. The planned OpenVPN instance and two EKS nodes require approximately 6 vCPUs.

Terraform design and validation may continue, but cluster deployment will wait until the quota increase is approved so that private API access and worker registration can be tested end to end.

## Validation Criteria

The platform is complete only when:

1. The EKS API has no public endpoint.
2. The administrator can access the cluster through OpenVPN and IAM Identity Center.
3. Access fails without the approved network path.
4. Managed nodes register from both private application subnets.
5. Core add-ons become healthy.
6. Nodes can pull an image from the private ECR registry.
7. No node exposes inbound SSH or receives a public IP.
8. A clean Terraform follow-up plan reports no drift.
