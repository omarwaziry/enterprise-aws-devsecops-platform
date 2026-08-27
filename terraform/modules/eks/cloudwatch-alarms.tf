# -----------------------------------------------------------------------------
# CloudWatch Alarms
# Monitors EKS cluster health and triggers alerts when thresholds are exceeded.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_cluster_cpu" {
  count = var.logging_enabled ? 1 : 0

  alarm_name          = "${var.cluster_name}-high-cpu"
  alarm_description   = "EKS cluster CPU utilization exceeds 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_memory" {
  count = var.logging_enabled ? 1 : 0

  alarm_name          = "${var.cluster_name}-high-memory"
  alarm_description   = "EKS cluster memory utilization exceeds 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "eks_pod_restart" {
  count = var.logging_enabled ? 1 : 0

  alarm_name          = "${var.cluster_name}-pod-restarts"
  alarm_description   = "EKS pods restarting frequently — possible CrashLoopBackOff"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Maximum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}
