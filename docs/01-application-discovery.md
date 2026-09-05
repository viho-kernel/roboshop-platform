# RoboShop Application Discovery

## Purpose

This document records the initial technical understanding of RoboShop before infrastructure, containers, or Kubernetes resources are created.

## Service Dependency Matrix

| Component | Runtime | Default Port | Dependencies | Stateful |
|---|---:|---:|---|---|
| Frontend | Nginx | 80 | Backend microservices | No |
| Catalogue | Node.js | 8080 | MongoDB | No |
| User | Node.js | 8080 | MongoDB, Redis | No |
| Cart | Node.js | 8080 | Redis, Catalogue | No |
| Shipping | Java / Maven | 8080 | MySQL, Cart | No |
| Payment | Python / uWSGI | 8080 | Cart, User, RabbitMQ | No |
| Dispatch | Go | 8080 | RabbitMQ | No |
| MongoDB | MongoDB | 27017 | - | Yes |
| Redis | Redis | 6379 | - | Yes |
| MySQL | MySQL | 3306 | - | Yes |
| RabbitMQ | RabbitMQ | 5672 | - | Yes |

## Startup Dependency Order

1. MongoDB, Redis, MySQL, RabbitMQ
2. Catalogue and User
3. Cart
4. Shipping, Payment, and Dispatch
5. Frontend

## Initial Platform Direction

- Stateless services will run on Amazon EKS in private application subnets.
- Data and messaging services will remain private and have no public IP address.
- Users and engineers will reach internal services only after VPN authentication.
- Application configuration and secrets will not be hardcoded in images or committed to Git.
- Terraform, Helm, GitOps, CI/CD, and observability design decisions will be documented before implementation.

## Open Decisions

- Decide the managed-service versus Kubernetes StatefulSet strategy for each data component.
- Confirm application health endpoints and required environment variables.
- Confirm service resource requirements and scaling expectations.
- Confirm data backup, retention, and recovery objectives.
