# Terraform Guide

This document covers the Terraform infrastructure modules, variables, state management, and operational procedures.

---

## Module Architecture

```
terraform/
├── backend/              # S3 backend for state storage
├── environments/
│   └── dev/              # Dev environment root module
│       ├── main.tf       # Module compositions
│       ├── variables.tf  # Environment variables
│       ├── outputs.tf    # Environment outputs
│       ├── provider.tf   # AWS + Helm provider config
│       ├── versions.tf   # Provider version constraints
│       └── backend.tf    # Remote state configuration
└── modules/
    ├── vpc/              # VPC, subnets, NAT, routes
    ├── eks/              # EKS cluster + all add-ons
    ├── ecr/              # Container registry
    └── github-oidc/      # GitHub OIDC IAM integration
```

---

## Modules

### VPC Module (`modules/vpc/`)

Creates the network foundation:
- VPC with configurable CIDR
- 2 public subnets (across 2 AZs)
- 2 private subnets (across 2 AZs)
- Internet Gateway
- NAT Gateway (single)
- Route tables with appropriate associations

### EKS Module (`modules/eks/`)

Creates the Kubernetes cluster and all cluster add-ons:

| Component | File | Description |
|-----------|------|-------------|
| EKS Cluster | `main.tf` | Cluster, node groups, core add-ons |
| ALB Controller | `aws-load-balancer-controller.tf` | Ingress controller with Pod Identity |
| EBS CSI | `ebs-csi.tf` | Persistent volume driver |
| Cluster Autoscaler | `cluster-autoscaler.tf` | Node auto-scaling with Pod Identity |
| Kyverno | `kyverno.tf` | Policy engine |
| Monitoring | `monitoring.tf` | kube-prometheus-stack (Prometheus, Grafana, Alertmanager) |
| Logging | `logging.tf` | AWS for Fluent Bit → CloudWatch |
| CloudWatch Alarms | `cloudwatch-alarms.tf` | CPU, memory, pod restart alerts |

### ECR Module (`modules/ecr/`)

Creates the container image registry with lifecycle policies.

### GitHub OIDC Module (`modules/github-oidc/`)

Creates the IAM OIDC provider and role for GitHub Actions CI/CD.

---

## Variables Reference

### Environment Variables (`environments/dev/variables.tf`)

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `project_name` | string | Project identifier | `devsecops` |
| `environment` | string | Environment name | `dev` |
| `aws_region` | string | AWS region | `us-east-1` |
| `vpc_cidr` | string | VPC CIDR block | `10.0.0.0/16` |
| `cluster_name` | string | EKS cluster name | `devsecops-dev-eks` |
| `kubernetes_version` | string | K8s version | `1.31` |
| `node_instance_types` | list(string) | EC2 types | `["t3.medium"]` |
| `node_min_size` | number | Min nodes | `1` |
| `node_desired_size` | number | Desired nodes | `2` |
| `node_max_size` | number | Max nodes | `5` |
| `node_disk_size` | number | Disk in GiB | `30` |
| `node_capacity_type` | string | ON_DEMAND/SPOT | `ON_DEMAND` |

### EKS Module Toggle Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `kyverno_enabled` | bool | `true` | Install Kyverno |
| `kyverno_chart_version` | string | `3.3.4` | Kyverno Helm chart version |
| `kyverno_replica_count` | number | `3` | Kyverno HA replicas |
| `monitoring_enabled` | bool | `true` | Install kube-prometheus-stack |
| `kube_prometheus_stack_version` | string | `72.6.2` | Monitoring chart version |
| `grafana_admin_password` | string | `admin` | Grafana admin password (sensitive) |
| `logging_enabled` | bool | `true` | Install Fluent Bit |
| `log_retention_days` | number | `30` | CloudWatch log retention |

---

## State Management

### Backend Configuration

State is stored in S3 with native state locking (no DynamoDB required):

```hcl
terraform {
  backend "s3" {
    bucket = "devsecops-terraform-state"
    key    = "environments/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### State Operations

```bash
# View current state
terraform state list

# Show a specific resource
terraform state show module.eks.module.eks.aws_eks_cluster.this[0]

# Import an existing resource
terraform import module.ecr.aws_ecr_repository.this devsecops-platform

# Remove a resource from state (without destroying)
terraform state rm module.eks.helm_release.kyverno[0]
```

---

## Common Operations

### Plan and Apply

```bash
cd terraform/environments/dev
terraform plan -out=tfplan
terraform apply tfplan
```

### Targeted Apply

Apply only specific modules to speed up deployments:

```bash
# Only update EKS monitoring
terraform apply -target=module.eks.helm_release.kube_prometheus_stack

# Only update the VPC
terraform apply -target=module.vpc
```

### Destroying Resources

```bash
# Destroy everything
terraform destroy

# Destroy specific module
terraform destroy -target=module.eks
```

### Output Values

```bash
terraform output                    # All outputs
terraform output eks_cluster_name   # Specific output
terraform output -json              # JSON format
```

---

## Adding a New Environment

1. Copy `environments/dev/` to `environments/<env>/`
2. Update `backend.tf` with a unique state key
3. Update `variables.tf` defaults or create a `terraform.tfvars`
4. Run `terraform init` and `terraform apply`
