# Deployment Guide

This guide walks through provisioning the complete infrastructure and deploying the application from scratch.

---

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|-----------------|---------|
| AWS CLI | 2.x | AWS API access |
| Terraform | >= 1.10 | Infrastructure provisioning |
| kubectl | v1.30+ | Kubernetes management |
| Helm | v3.15+ | Application deployment |
| Docker | 24+ | Local container builds |
| Java | 21 | Local development (optional) |

### AWS Configuration

Ensure your AWS CLI is configured with credentials that have permissions to:
- Create VPCs, subnets, NAT gateways
- Create EKS clusters and managed node groups
- Create ECR repositories
- Create IAM roles and OIDC providers
- Create CloudWatch log groups and alarms

---

## Step 1: Initialize Terraform Backend

The project uses S3 for remote state storage with native state locking.

```bash
cd terraform/backend
terraform init
terraform apply
```

This creates the S3 bucket for Terraform state.

---

## Step 2: Provision Infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

This provisions:
- **VPC** — 2 public subnets, 2 private subnets, NAT gateway, internet gateway
- **EKS** — Kubernetes cluster with managed node groups, IRSA enabled
- **ECR** — Container image registry
- **GitHub OIDC** — IAM role for GitHub Actions authentication
- **Add-ons** — AWS Load Balancer Controller, EBS CSI Driver, Metrics Server, Cluster Autoscaler
- **Kyverno** — Policy engine with admission webhooks
- **Monitoring** — Prometheus, Grafana, Alertmanager (kube-prometheus-stack)
- **Logging** — Fluent Bit → CloudWatch Logs
- **CloudWatch Alarms** — CPU, memory, pod restart alerts

### Key Outputs

After `terraform apply`, note these outputs:

```bash
terraform output eks_cluster_name
terraform output ecr_repository_url
terraform output github_actions_role_arn
```

---

## Step 3: Configure kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name devsecops-dev-eks

kubectl cluster-info
kubectl get nodes
```

---

## Step 4: Deploy Application

### Using Helm directly

```bash
# Get ECR registry URL
ECR_REGISTRY=$(aws ecr describe-repositories \
  --repository-names devsecops-platform \
  --query 'repositories[0].repositoryUri' \
  --output text | sed 's|/devsecops-platform||')

# Deploy
helm upgrade --install devsecops-platform helm/application \
  --namespace devsecops \
  --create-namespace \
  --set image.registry=$ECR_REGISTRY \
  --set image.tag=latest \
  --wait --timeout 5m
```

### Using GitHub Actions CD

The CD pipeline triggers automatically after a successful CI run, or manually via workflow dispatch:

1. Go to **Actions** → **DevSecOps CD Pipeline**
2. Click **Run workflow**
3. Select the environment and optionally specify an image tag

---

## Step 5: Apply Kubernetes Policies

### Kyverno Policies

```bash
kubectl apply -f kubernetes/kyverno-policies/
kubectl get clusterpolicy
```

### Network Policies

```bash
kubectl apply -f kubernetes/network-policies/
kubectl get networkpolicy -n devsecops
```

---

## Step 6: Apply Custom Alerting Rules

```bash
kubectl apply -f monitoring/alerting-rules.yaml
kubectl get prometheusrule -n monitoring
```

---

## Step 7: Verify Deployment

```bash
# Check pods
kubectl get pods -n devsecops

# Check services and ingress
kubectl get svc,ingress -n devsecops

# Port-forward for local access
kubectl port-forward svc/devsecops-platform 8080:8080 -n devsecops

# Test endpoints
curl http://localhost:8080/api/v1/health
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/prometheus
```

---

## Step 8: Configure GitHub Repository

### Required Repository Variables

Set these under **Settings → Secrets and variables → Actions → Variables**:

| Variable | Value |
|----------|-------|
| `AWS_REGION` | `us-east-1` |
| `AWS_ROLE_ARN` | Output from `terraform output github_actions_role_arn` |
| `EKS_CLUSTER_NAME` | `devsecops-dev-eks` |
| `ECR_REPOSITORY` | `devsecops-platform` |

### Required Secrets

| Secret | Value |
|--------|-------|
| `SONAR_TOKEN` | SonarCloud authentication token |

---

## Tear Down

To destroy all resources:

```bash
# Remove Helm releases first
helm uninstall devsecops-platform -n devsecops

# Remove Kubernetes resources
kubectl delete -f kubernetes/kyverno-policies/
kubectl delete -f kubernetes/network-policies/
kubectl delete -f monitoring/alerting-rules.yaml

# Destroy infrastructure
cd terraform/environments/dev
terraform destroy
```

> **Warning**: This will destroy all AWS resources including the EKS cluster, VPC, and ECR images.
