data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f8d264fcd9"
  ]

  tags = var.tags
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

  sub_conditions = [
    for branch in var.github_branches :
    branch == "*" ? "repo:${var.github_repo}:*" : "repo:${var.github_repo}:ref:refs/heads/${branch}"
  ]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.sub_conditions
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "ecr_access" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages"
    ]
    resources = var.ecr_repository_arns
  }
}

resource "aws_iam_policy" "ecr_access" {
  name        = "${var.role_name}-ecr-policy"
  description = "IAM policy allowing GitHub Actions to authenticate and push images to Amazon ECR"
  policy      = data.aws_iam_policy_document.ecr_access.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

data "aws_iam_policy_document" "eks_describe" {
  statement {
    sid    = "EKSDescribeCluster"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = var.eks_cluster_arns
  }
}

resource "aws_iam_policy" "eks_describe" {
  name        = "${var.role_name}-eks-policy"
  description = "IAM policy allowing GitHub Actions to describe EKS cluster"
  policy      = data.aws_iam_policy_document.eks_describe.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_describe" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.eks_describe.arn
}
