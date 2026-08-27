variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Worker node instance types"
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum worker nodes"
  type        = number
}

variable "node_desired_size" {
  description = "Desired worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum worker nodes"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for EKS resources"
  type        = map(string)
  default     = {}
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN used by the Amazon EBS CSI driver through EKS Pod Identity"
  type        = string
  default     = null
}
variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 30
}

variable "node_capacity_type" {
  description = "Capacity type for worker nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

# -----------------------------------------------------------------------------
# Kyverno Configuration
# -----------------------------------------------------------------------------

variable "kyverno_enabled" {
  description = "Whether to install Kyverno policy engine on the cluster"
  type        = bool
  default     = true
}

variable "kyverno_chart_version" {
  description = "Helm chart version for Kyverno"
  type        = string
  default     = "3.3.4"
}

variable "kyverno_replica_count" {
  description = "Number of Kyverno admission controller replicas (use 3 for HA)"
  type        = number
  default     = 3
}

# -----------------------------------------------------------------------------
# Monitoring Configuration (kube-prometheus-stack)
# -----------------------------------------------------------------------------

variable "monitoring_enabled" {
  description = "Whether to install the kube-prometheus-stack (Prometheus, Grafana, Alertmanager)"
  type        = bool
  default     = true
}

variable "kube_prometheus_stack_version" {
  description = "Helm chart version for kube-prometheus-stack"
  type        = string
  default     = "72.6.2"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "admin"
}

# -----------------------------------------------------------------------------
# Logging Configuration (AWS for Fluent Bit)
# -----------------------------------------------------------------------------

variable "logging_enabled" {
  description = "Whether to install AWS for Fluent Bit for CloudWatch logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}