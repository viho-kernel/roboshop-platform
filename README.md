# RoboShop Platform

Production-style AWS DevSecOps platform for the RoboShop microservices application.

## Project Goal

Build and operate a secure, private, observable, GitOps-driven AWS platform from scratch.

## Target Platform

- AWS region: ap-south-1 (Mumbai)
- Access: IAM Identity Center, MFA, VPN, and SSM
- Infrastructure: Terraform
- Configuration management: Ansible and shell automation
- Containers: Docker and Amazon ECR
- Primary runtime: Amazon EKS
- Secondary runtime: Amazon ECS/Fargate
- CI/CD: GitHub Actions and Jenkins
- GitOps: Argo CD
- Security: Trivy, SonarQube, IaC scanning, Secrets Manager, RBAC, NetworkPolicies
- Observability: Prometheus, Grafana, Loki, ELK/Kibana, CloudWatch
- Automation: Python operational tooling

## Security Principles

- No application, database, monitoring, or CI/CD workload receives a public IP.
- VPN is the controlled external entry point.
- AWS IAM and Kubernetes RBAC follow least privilege.
- Secrets never enter Git repositories.
- Infrastructure and configuration changes are reviewed, version-controlled, and automated.

## Status

Project onboarding and workstation setup in progress.
