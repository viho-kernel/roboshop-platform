# 3. OpenVPN Private Access — Building Notes

## The access problem

The platform must be private, but engineers still need controlled access to internal tools and endpoints.

Bad design:

```text
Public SSH + public Jenkins + public Grafana + public EKS endpoint
```

Our design:

```text
Only OpenVPN endpoint is public
→ engineer connects through VPN
→ private endpoints become reachable according to approved rules
```

## Desired traffic flow

```text
Laptop public IP
→ UDP 1194
→ OpenVPN EC2 in public subnet
→ VPN client address from 10.250.0.0/24
→ private application / operations / data subnets
```

There are two separate CIDR ideas:

| Value | Meaning |
|---|---|
| `allowed_vpn_ingress_cidrs` | Your real public internet IP range allowed to start an OpenVPN connection |
| `vpn_client_cidr = 10.250.0.0/24` | Private IP range OpenVPN assigns after clients connect |

Never confuse them.

## Module input contract already created

The OpenVPN module receives:

- project/environment/region for consistent names
- VPC ID
- public subnet for the VPN gateway
- private subnet IDs for return routing
- approved public client CIDRs
- VPN client CIDR
- small development instance type

This keeps the module reusable. The module does not care about a hardcoded VPC ID.

## Security Group already created

Inbound rule:

```text
Protocol: UDP
Port: 1194
Source: approved public client CIDR only
```

There is deliberately **no inbound SSH rule**.

Outbound rule allows IPv4 egress. The VPN server needs outbound connectivity for SSM, package installation, updates, and forwarding traffic.

## SSM IAM design already created

```text
OpenVPN EC2
→ instance profile
→ IAM role
→ AmazonSSMManagedInstanceCore
→ Session Manager
```

Remember:

- **Role**: AWS identity card for the EC2 instance.
- **Trust policy**: `ec2.amazonaws.com` is allowed to use that role.
- **Permission policy**: `AmazonSSMManagedInstanceCore` allows the SSM agent to communicate with Systems Manager.
- **Instance profile**: the attachment box EC2 uses to receive the role.

This gives terminal access without public SSH, SSH keys, or port 22.

## AMI lookup already created

The module asks AWS SSM Parameter Store for the current Amazon Linux 2023 x86_64 AMI.

Why not hardcode an AMI ID?

```text
Hardcoded AMI → can be old or region-specific
SSM public AMI parameter → resolves the current supported image in the chosen region
```

## Remaining implementation and why it matters

### 1. OpenVPN EC2 + Elastic IP

An Elastic IP makes the VPN endpoint stable. Without it, stopping/replacing the instance can change its public IP and break the client profile.

### 2. Disable source/destination check

Normal EC2 expects itself to be the source or destination of its packets. A VPN gateway forwards packets for clients, so AWS must allow forwarding.

```text
VPN client packet
→ VPN EC2
→ private service

Private service response
→ VPN EC2
→ VPN client
```

Therefore the EC2 VPN gateway needs `source_dest_check = false`.

### 3. Private return routes

Private subnets must know how to return traffic to `10.250.0.0/24`.

```text
Destination: 10.250.0.0/24
Target: OpenVPN EC2 network interface
```

Without that path, a private service may receive client traffic but cannot send the response back correctly.

### 4. OpenVPN installation and client profile

The bootstrap will install and configure OpenVPN. Client profiles, certificates, keys and generated `.ovpn` files are secrets and must never be committed to Git.

## Verification plan

1. Confirm EC2 is running and has correct Security Group and Elastic IP.
2. Confirm SSM shows the instance as managed.
3. Start a Session Manager terminal—without SSH.
4. Connect OpenVPN from laptop.
5. Confirm laptop receives a `10.250.0.x` address.
6. Reach an approved private endpoint.
7. Confirm unapproved public SSH remains impossible.
8. Use Flow Logs to investigate any rejected packets.

## What to remember

> OpenVPN is the single controlled front door. The Security Group limits who can knock. IAM+SSM lets us administer the door without exposing SSH. Source/destination check and return routes let the gateway forward private traffic correctly.
