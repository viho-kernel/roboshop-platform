# RoboShop Platform — Detailed Shift Study Notes

This is the detailed notebook for the platform we are building. Read one section during shift time; each section explains **why**, **what Terraform creates**, **how traffic or permissions move**, and **how a DevOps engineer investigates failures**.

## Study order

1. [Platform foundation, VPC and Terraform state](study/01-foundation-and-network.md)
2. [VPC Flow Logs, IAM, CloudWatch and KMS](study/02-flow-logs-and-investigation.md)
3. [OpenVPN private access — implementation in progress](study/03-openvpn-private-access.md)
4. [Shift drills, commands and interview answers](study/04-shift-drills.md)

## Current delivery status

| Area | Status |
|---|---|
| Application discovery | Complete |
| Two-AZ VPC and subnet architecture | Complete |
| Network remote state | Complete |
| Encrypted VPC Flow Logs | Deployed and verified |
| OpenVPN design | Complete |
| OpenVPN Terraform module | In progress |
| EKS, CI/CD, GitOps, application deployment, monitoring | Planned next |

Do not treat a design document as proof that a service is deployed. The source of truth for a deployed resource is: reviewed Terraform state plus live AWS verification.
