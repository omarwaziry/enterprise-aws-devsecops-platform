module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.24.0"

  name = var.cluster_name

  kubernetes_version = var.kubernetes_version

  vpc_id = var.vpc_id

  subnet_ids = var.private_subnet_ids

  endpoint_public_access = true

  authentication_mode = "API"

  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
      before_compute = true
    }

    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    main = {
      name = "main"

      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      subnet_ids = var.private_subnet_ids

      capacity_type = "ON_DEMAND"

      disk_size = 30

      labels = {
        Environment = var.environment
      }

      tags = {
        Name = "${var.cluster_name}-worker"
      }
    }
  }

  tags = var.tags
}