# Secure AWS Network Architecture

## Purpose

Define the AWS network boundary for RoboShop before Terraform implementation.

## Region and Availability

- Region: `ap-south-1` (Mumbai)
- Availability Zones: two dynamically selected available AZs
- Availability target: workloads spread across two AZs

## VPC and Subnet Plan

| Tier | AZ 1 CIDR | AZ 2 CIDR | Workloads |
|---|---|---|---|
| VPC | `10.20.0.0/16` | - | Entire RoboShop network |
| Public | `10.20.0.0/24` | `10.20.1.0/24` | NAT Gateway and VPN entry only |
| Private application | `10.20.16.0/20` | `10.20.32.0/20` | EKS nodes and pod IP addresses |
| Private data | `10.20.48.0/24` | `10.20.49.0/24` | Databases, caches, and messaging |
| Private operations | `10.20.64.0/24` | `10.20.65.0/24` | Jenkins, private runners, utility hosts |

## Routing Design

| Subnet tier | Default route | Inbound design |
|---|---|---|
| Public | Internet Gateway | Only VPN port/protocol is internet reachable |
| Private application | NAT Gateway | Internal ALB and approved private sources only |
| Private data | No direct internet route | Required application Security Groups only |
| Private operations | NAT Gateway | VPN clients and approved internal sources only |

Production uses one NAT Gateway per AZ for resilient egress. The lab may temporarily use one NAT Gateway to control cost; this must be documented as a non-production trade-off.

## Access Model

```text
Engineer
  → MFA and IAM Identity Center
  → VPN
  → private AWS endpoints

VPN clients
  → internal ALB
  → private EKS services

VPN clients
  → Jenkins, Grafana, Kibana, Argo CD, and SSM access
