variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider (set to false if already created in the AWS account)"
  type        = bool
  default     = true
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format (e.g. omarwaziry/enterprise-aws-devsecops-platform)"
  type        = string
}

variable "github_branches" {
  description = "List of allowed GitHub branches or wildcard patterns (e.g. ['main'] or ['*'])"
  type        = list(string)
  default     = ["*"]
}

variable "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-ci-cd"
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs that GitHub Actions can push to"
  type        = list(string)
  default     = ["*"]
}

variable "eks_cluster_arns" {
  description = "List of EKS cluster ARNs that GitHub Actions can describe"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags for IAM resources"
  type        = map(string)
  default     = {}
}
