output "role_arn" {
  description = "IAM Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "IAM Role name for GitHub Actions"
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC Provider"
  value       = local.oidc_provider_arn
}
