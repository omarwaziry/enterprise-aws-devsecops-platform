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