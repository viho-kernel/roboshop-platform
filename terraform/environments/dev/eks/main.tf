locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  name                = local.cluster_name
  kubernetes_version  = var.kubernetes_version
  authentication_mode = "API"

  endpoint_private_access = true
  endpoint_public_access  = false

  vpc_id                   = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.network.outputs.private_app_subnet_ids
  control_plane_subnet_ids = data.terraform_remote_state.network.outputs.private_app_subnet_ids

  enabled_log_types                      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = 30

  addons = {
    coredns = {}

    eks-pod-identity-agent = {
      before_compute = true
    }

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }
  }

  access_entries = {
    platform_administrator = {
      principal_arn = var.administrator_role_arn

      policy_associations = {
        cluster_administrator = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  security_group_additional_rules = {
    vpn_https = {
      description = "Allow authenticated VPN clients to reach the private EKS API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [var.vpn_client_cidr]
    }
  }

  eks_managed_node_groups = {
    application = {
      name = "application"

      subnet_ids = data.terraform_remote_state.network.outputs.private_app_subnet_ids

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      desired_size = 2
      max_size     = 4

      disk_size = 30

      labels = {
        workload = "application"
      }

      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }
}
