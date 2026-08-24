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