# OpenVPN Private Access

## Purpose

OpenVPN is the only public administrative entry point into the RoboShop development VPC.

Application workloads, EKS, internal load balancers, Jenkins, Grafana, Argo CD, and databases remain private. Engineers connect to the VPN first, then access approved private services.

## Architecture

```text
Engineer laptop
→ Internet
→ OpenVPN Elastic IP on UDP 1194
→ OpenVPN EC2 instance in a public subnet
→ private application, operations, and data subnets

The VPN server is a self-managed OpenVPN instance on Amazon EC2. It is a development environment baseline, not a highly available production VPN platform.

Security Design
VPN protocol: OpenVPN over UDP port 1194
Client network: 10.250.0.0/24
VPC network: 10.20.0.0/16
Public endpoint: Elastic IP associated with the VPN instance
Public SSH: disabled
Instance administration: AWS Systems Manager Session Manager
VPN ingress: restricted to approved public client CIDRs
VPN instance profile: AmazonSSMManagedInstanceCore
EC2 source/destination check: disabled so the instance can route VPN-client traffic
Return routes: private route tables send VPN-client traffic back through the OpenVPN instance
Server secrets: CA, server key, client keys, and TLS keys remain on the server or approved engineer devices only
Terraform Layout
terraform/modules/openvpn/
  → reusable OpenVPN infrastructure module

terraform/environments/dev/network-access/
  → development deployment, remote-state integration, and local client-IP input

The network-access state reads the VPC outputs from the network state. It passes the VPC ID, a public subnet, and private route table IDs to the OpenVPN module.

This separation prevents an access-control change from modifying the VPC, NAT gateways, or subnets.

Components
Component	Responsibility
Security Group	Allows only approved client CIDRs to reach UDP 1194
EC2 instance	Runs the OpenVPN server and routes client traffic
Elastic IP	Gives the VPN endpoint a stable public address
IAM role and instance profile	Lets the instance register with Systems Manager
SSM Session Manager	Provides administrator access without public SSH
OpenVPN server configuration	Defines the client CIDR and pushes the VPC route
Private route-table routes	Return traffic from private subnets to VPN clients
Client .ovpn profile	Contains endpoint, CA certificate, client certificate, private key, and TLS protection key
Validation Performed

The deployed development VPN was verified with the following checks:

The EC2 instance is running with source/destination check disabled.
The Elastic IP is associated with the VPN instance.
The instance appears as Online in Systems Manager.
OpenVPN is installed and openvpn-server@server is active.
IPv4 forwarding is enabled.
The tun0 interface is available on the VPN client network.
The server listens on UDP port 1194.
The Security Group permits UDP 1194 only from the approved client public CIDR.
An OpenVPN Connect client successfully establishes a VPN connection.
Daily Operation

Normal daily access requires no Terraform, SSM session, certificate generation, or profile download.

OpenVPN Connect
→ select the imported client profile
→ Connect
→ access approved private services

The client profile points to the Elastic IP. Stopping and starting the same EC2 instance does not change that Elastic IP, so the existing profile continues to work after the OpenVPN service starts.

For lab cost control, stop the VPN EC2 instance when it is not needed. Start it again before connecting and allow a short time for cloud-init and OpenVPN to become ready.

Do not run terraform destroy as a daily shutdown action.

Client Public-IP Changes

The Security Group intentionally restricts VPN ingress to the engineer's current public IP as a /32.

If the home, office, or mobile-network public IP changes:

Find the current public IP.
Update the ignored local terraform.tfvars.
Run terraform plan.
Confirm the plan changes only the UDP 1194 ingress rule.
Apply the reviewed plan.
Reconnect using OpenVPN Connect.

The local terraform.tfvars file must never be committed because it contains environment-specific client access data.

Client Profile Lifecycle

A client profile is created once per engineer/device and imported into OpenVPN Connect.

Treat every .ovpn profile as a secret because it includes a client private key.

Do not commit profiles, private keys, certificates, or generated PKI files.
Do not paste profile contents into tickets, pull requests, chat, or GitHub.
Create a separate identity for each laptop or engineer.
Revoke and replace a profile if a device is lost or compromised.
Generate a new profile after a VPN server replacement if its TLS material has changed.
Troubleshooting
Symptom	Likely Cause	First Check
Connection timeout	Current public IP is not allowed by the Security Group	Compare the current public IP with local terraform.tfvars and live SG ingress
Server receives no connection log entries	UDP traffic is blocked before reaching EC2	Confirm Security Group CIDR, port, protocol, EIP, and local network policy
tls-crypt authentication error	Client profile belongs to a different VPN server or TLS key	Generate a new client profile from the current server
Certificate/private-key mismatch in OpenVPN Connect	Invalid or mixed client profile contents	Verify that certificate and private-key public-key fingerprints match before importing
VPN connects but private access fails	Missing return route, Security Group rule, NACL rule, or target-service issue	Check VPN route tables, workload SG rules, and Flow Logs
Cannot open an SSM session	Session Manager plugin missing or instance not online	Confirm the instance profile, SSM agent, and Session Manager plugin
Development Limitations and Production Direction

This development implementation uses one VPN instance and one Availability Zone. It is acceptable for a learning environment but has a single point of failure.

A production design should use a managed or highly available VPN solution, formal client lifecycle management, centralized logging, monitoring, alerting, certificate rotation, and documented access approvals.
