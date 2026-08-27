# -----------------------------------------------------------------------------
# Logging — AWS for Fluent Bit
# Ships container and node logs to Amazon CloudWatch Logs.
# Uses EKS Pod Identity for IAM authentication.
# -----------------------------------------------------------------------------

module "fluentbit_pod_identity" {
  count = var.logging_enabled ? 1 : 0

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.8.1"

  name = "${var.cluster_name}-fluentbit"

  attach_custom_policy    = true
  source_policy_documents = [data.aws_iam_policy_document.fluentbit[0].json]

  associations = {
    controller = {
      cluster_name    = module.eks.cluster_name
      namespace       = "logging"
      service_account = "fluent-bit"
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "fluentbit" {
  count = var.logging_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:*:log-group:/aws/eks/${var.cluster_name}/*"]
  }
}

resource "helm_release" "fluentbit" {
  count = var.logging_enabled ? 1 : 0

  name       = "fluent-bit"
  namespace  = "logging"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.35"

  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "fluent-bit"
      }

      cloudWatch = {
        enabled   = true
        region    = var.aws_region
        logGroupName  = "/aws/eks/${var.cluster_name}/application"
        logStreamPrefix = "fluentbit-"
        autoCreateGroup = true
        logRetentionDays = var.log_retention_days
      }

      # Ship host-level logs
      hostNetwork = false

      input = {
        enabled = true
        tag     = "kube.*"
      }

      # Additional filter to enrich logs with Kubernetes metadata
      filter = {
        enabled    = true
        mergeLog   = true
        keepLog    = true
        k8sLogging = {
          parser = true
        }
      }

      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          memory = "128Mi"
        }
      }

      tolerations = [
        {
          operator = "Exists"
        }
      ]
    })
  ]

  depends_on = [
    module.fluentbit_pod_identity
  ]
}
