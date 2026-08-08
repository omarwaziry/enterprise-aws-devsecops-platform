locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

module "vpc" {
  source = "../../modules/vpc"

  name = "${var.project_name}-${var.environment}"

  vpc_cidr = var.vpc_cidr

  availability_zones = local.availability_zones

  public_subnets = local.public_subnets

  private_subnets = local.private_subnets

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "devsecops-platform"

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name

  kubernetes_version = var.kubernetes_version

  aws_region         = var.aws_region
  
  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.node_instance_types

  node_min_size = var.node_min_size

  node_desired_size = var.node_desired_size

  node_max_size = var.node_max_size

  environment = var.environment

  tags = local.common_tags
}