# -----------------------------------------------------------------------------
# Cluster Autoscaler
# Automatically adjusts the number of nodes in the EKS cluster based on
# pending pod resource requests. Deployed via Helm.
# -----------------------------------------------------------------------------

module "cluster_autoscaler_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.8.1"

  name = "${var.cluster_name}-cluster-autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  associations = {
    controller = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "cluster-autoscaler"
    }
  }

  tags = var.tags
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.46.0"

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = module.eks.cluster_name
      }

      awsRegion = var.aws_region

      rbac = {
        serviceAccount = {
          create = true
          name   = "cluster-autoscaler"
        }
      }

      extraArgs = {
        "balance-similar-node-groups"   = true
        "skip-nodes-with-system-pods"   = false
        "expander"                      = "least-waste"
        "scale-down-delay-after-add"    = "5m"
        "scale-down-unneeded-time"      = "5m"
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          memory = "256Mi"
        }
      }
    })
  ]

  depends_on = [
    module.cluster_autoscaler_pod_identity
  ]
}
