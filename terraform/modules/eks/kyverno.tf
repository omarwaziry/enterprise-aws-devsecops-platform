# -----------------------------------------------------------------------------
# Kyverno — Kubernetes-native Policy Engine
# Deployed via Helm into the "kyverno" namespace.
# Validates, mutates, and generates Kubernetes resources based on policies.
# -----------------------------------------------------------------------------

resource "helm_release" "kyverno" {
  count = var.kyverno_enabled ? 1 : 0

  name       = "kyverno"
  namespace  = "kyverno"
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  version    = var.kyverno_chart_version

  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      admissionController = {
        replicas = var.kyverno_replica_count

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            memory = "512Mi"
          }
        }
      }

      backgroundController = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            memory = "256Mi"
          }
        }
      }

      cleanupController = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            memory = "256Mi"
          }
        }
      }

      reportsController = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            memory = "256Mi"
          }
        }
      }
    })
  ]

  depends_on = [
    module.eks
  ]
}
