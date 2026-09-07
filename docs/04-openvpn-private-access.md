# OpenVPN Private Access

## Purpose

OpenVPN provides the only public administrative entry point into the RoboShop development VPC.

Application workloads, EKS, Jenkins, Grafana, Argo CD, databases, and internal load balancers remain private.

## Access Model

```text
Engineer laptop
→ OpenVPN endpoint in public subnet
→ private application, operations, and data subnets

Design
VPN platform: self-managed OpenVPN on Amazon EC2
Region: ap-south-1
Placement: public subnet
Public exposure: UDP port 1194 only
SSH: not publicly exposed
Administration: AWS Systems Manager Session Manager
Client VPN CIDR: 10.250.0.0/24
VPC CIDR: 10.20.0.0/16
Public IP: Elastic IP attached to the VPN instance
High availability: single instance for development; production would require a managed or highly available design
Security Rules
Do not allow public SSH access.
Restrict VPN ingress to known client public IP ranges where practical.
Permit access from the VPN client CIDR only to approved private services.
Use security-group references for workload-to-workload communication.
Keep OpenVPN client profiles and private keys outside Git.
Use SSM Session Manager for break-glass administration and troubleshooting.
Operational Use

VPN access is required for private administrative endpoints such as:

EKS private API access
Internal application load balancers
Jenkins
Argo CD
Grafana and Kibana
Private EC2 instances
Database troubleshooting through approved access paths
