# -----------------------------------------------------------------------------
# Monitoring — kube-prometheus-stack
# Deploys Prometheus, Grafana, Alertmanager, Node Exporter, and
# kube-state-metrics as a single integrated monitoring stack.
# Includes pre-built dashboards for CPU, Memory, Network, Pods, Nodes,
# and Deployments.
# -----------------------------------------------------------------------------

resource "helm_release" "kube_prometheus_stack" {
  count = var.monitoring_enabled ? 1 : 0

  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_version

  create_namespace = true
  wait             = true
  timeout          = 900

  values = [
    yamlencode({
      # -- Prometheus ----------------------------------------------------------
      prometheus = {
        prometheusSpec = {
          retention         = "15d"
          scrapeInterval    = "30s"
          evaluationInterval = "30s"

          resources = {
            requests = {
              cpu    = "200m"
              memory = "512Mi"
            }
            limits = {
              memory = "1Gi"
            }
          }

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }

          # Scrape application pods with prometheus.io annotations
          additionalScrapeConfigs = [
            {
              job_name        = "devsecops-application"
              scrape_interval = "15s"
              kubernetes_sd_configs = [
                {
                  role = "pod"
                  namespaces = {
                    names = ["devsecops"]
                  }
                }
              ]
              relabel_configs = [
                {
                  source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
                  action        = "keep"
                  regex         = "true"
                },
                {
                  source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
                  action        = "replace"
                  target_label  = "__metrics_path__"
                  regex         = "(.+)"
                },
                {
                  source_labels = ["__address__", "__meta_kubernetes_pod_annotation_prometheus_io_port"]
                  action        = "replace"
                  regex         = "([^:]+)(?::\\d+)?;(\\d+)"
                  replacement   = "$1:$2"
                  target_label  = "__address__"
                }
              ]
            }
          ]
        }
      }

      # -- Grafana -------------------------------------------------------------
      grafana = {
        enabled = true

        adminPassword = var.grafana_admin_password

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            memory = "512Mi"
          }
        }

        persistence = {
          enabled          = true
          storageClassName = "gp2"
          size             = "10Gi"
        }

        service = {
          type = "ClusterIP"
        }

        # Default dashboards are included via the chart
        defaultDashboardsEnabled    = true
        defaultDashboardsTimezone   = "UTC"
      }

      # -- Alertmanager --------------------------------------------------------
      alertmanager = {
        enabled = true

        alertmanagerSpec = {
          resources = {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              memory = "128Mi"
            }
          }
        }
      }

      # -- Node Exporter -------------------------------------------------------
      nodeExporter = {
        enabled = true
      }

      # -- kube-state-metrics --------------------------------------------------
      kubeStateMetrics = {
        enabled = true
      }
    })
  ]

  depends_on = [
    module.eks
  ]
}
