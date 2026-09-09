# RoboShop Network Security Design

## Purpose

Define the permitted network flows for the RoboShop platform before implementing Security Groups, Kubernetes NetworkPolicies, and NACL guardrails.

## Security Layers

| Layer | Responsibility |
|---|---|
| Route table | Determines whether a destination has a network path |
| Network ACL | Stateless subnet-level guardrail |
| Security Group | Stateful firewall attached to AWS resources |
| Kubernetes NetworkPolicy | Controls pod-to-pod and pod-to-destination traffic |
| Application authentication | Verifies whether the caller may use the service |

A route makes communication possible but does not authorize it. Security Groups and NetworkPolicies define which communication is permitted.

## Administrative Access

| Source | Destination | Protocol/Port | Control |
|---|---|---|---|
| VPN clients `10.250.0.0/24` | Internal ALB | TCP 443 | ALB Security Group |
| VPN clients `10.250.0.0/24` | Private EKS API | TCP 443 | EKS API access configuration |
| VPN clients `10.250.0.0/24` | Private operations tools | Required HTTPS ports | Tool Security Groups |
| Jenkins or deployment runners | Private EKS API | TCP 443 | EKS access and Security Groups |
| Administrators | EC2 instances | SSM session | IAM and SSM; no inbound SSH |

## Application Traffic

| Source | Destination | TCP Port |
|---|---|---:|
| Internal ALB | Frontend | 80 |
| Frontend | Catalogue | 8080 |
| Frontend | User | 8080 |
| Frontend | Cart | 8080 |
| Frontend | Shipping | 8080 |
| Frontend | Payment | 8080 |
| Cart | Catalogue | 8080 |
| Shipping | Cart | 8080 |
| Payment | Cart | 8080 |
| Payment | User | 8080 |
| Catalogue | MongoDB | 27017 |
| User | MongoDB | 27017 |
| User | Redis | 6379 |
| Cart | Redis | 6379 |
| Shipping | MySQL | 3306 |
| Payment | RabbitMQ | 5672 |
| Dispatch | RabbitMQ | 5672 |

## Control Placement

- AWS Security Groups will protect the internal ALB, EKS infrastructure, data services, operations tools, and VPC endpoints.
- Kubernetes NetworkPolicies will restrict communication between individual application services.
- Security Group references will be preferred over broad CIDR rules when both resources support them.
- VPN-client access will use `10.250.0.0/24` because routed clients retain their VPN addresses.
- No application or data workload will receive a public IP address.
- EC2 administration will use AWS Systems Manager instead of inbound SSH.

## NACL Decision

The initial implementation will retain the default stateful behavior at the Security Group layer. Custom NACL rules will be introduced only for a documented subnet-level deny requirement because NACLs are stateless and require both request and return traffic rules.

## Open Decisions

- Select the hosting model for MongoDB, Redis, MySQL, and RabbitMQ.
- Confirm whether EKS Security Groups for Pods will be enabled.
- Confirm internal ALB listener, TLS certificate, and private DNS names.
- Confirm exact operations-tool ports.
- Confirm required VPC endpoints after the EKS and operations designs are finalized.
