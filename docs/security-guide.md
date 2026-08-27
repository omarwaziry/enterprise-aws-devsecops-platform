# Security Guide

This document describes the security architecture and practices implemented in the Enterprise DevSecOps Platform.

---

## Authentication & Authorization

### GitHub OIDC → AWS IAM

The platform uses **OpenID Connect (OIDC) federation** between GitHub Actions and AWS IAM. This eliminates the need for stored AWS credentials.

```
GitHub Actions Runner
        │
        ▼
GitHub OIDC Token (JWT)
        │
        ▼
AWS STS AssumeRoleWithWebIdentity
        │
        ▼
Temporary AWS Credentials (1 hour)
        │
        ▼
ECR Push / EKS Deploy / CloudWatch
```

**Key properties**:
- No AWS access keys stored in GitHub Secrets
- Temporary credentials scoped to the run
- Trust policy restricts to specific repository and branch
- Role follows least-privilege principle

### IAM Roles for Service Accounts (IRSA) / EKS Pod Identity

Kubernetes workloads authenticate to AWS using **EKS Pod Identity**, eliminating node-level IAM role sharing:

| Service Account | AWS Permissions |
|----------------|-----------------|
| `aws-load-balancer-controller` | ELB management |
| `ebs-csi-controller-sa` | EBS volume management |
| `cluster-autoscaler` | EC2 auto scaling |
| `fluent-bit` | CloudWatch Logs |

Each pod gets only the permissions it needs — no shared node role.

---

## Supply Chain Security

### Container Image Scanning

```
Source Code → Trivy FS Scan → Docker Build → Trivy Image Scan → ECR Push
```

- **Trivy Filesystem Scan** — Detects vulnerabilities in application dependencies and secrets in source code
- **Trivy IaC Scan** — Checks Terraform and Helm for misconfigurations
- **Trivy Image Scan** — Scans the built container image for OS and library vulnerabilities
- **Checkov** — Additional IaC scanning for Terraform, Helm, and Dockerfile

All scans are configured to **fail the CI pipeline** on `CRITICAL` and `HIGH` severity findings.

### Image Registry Restriction

The `restrict-image-registries` Kyverno policy ensures that only images from trusted registries can be deployed:

- `*.dkr.ecr.*.amazonaws.com/*` — Amazon ECR (private)
- `public.ecr.aws/*` — Amazon ECR (public)
- `docker.io/library/*` — Docker Hub official images

### Dependency Updates

Dependabot is configured to automatically create PRs for:
- Maven dependencies (weekly)
- GitHub Actions versions (weekly)
- Docker base images (weekly)
- Terraform providers (monthly)

---

## Kubernetes Security

### Kyverno Policy Engine

Kyverno enforces 8 `ClusterPolicy` rules at admission time:

| Policy | Severity | What It Prevents |
|--------|----------|-----------------|
| `disallow-privileged` | High | Privileged containers |
| `require-non-root` | High | Root user execution, privilege escalation |
| `disallow-host-namespaces` | High | hostNetwork, hostPID, hostIPC |
| `restrict-image-registries` | High | Untrusted image sources |
| `disallow-latest-tag` | Medium | Mutable `:latest` image tag |
| `require-resource-limits` | Medium | Missing CPU/memory requests and limits |
| `require-readonly-rootfs` | Medium | Writable root filesystem |
| `require-labels` | Medium | Missing `app` and `environment` labels |

All policies use `validationFailureAction: Enforce` — non-compliant resources are **rejected**.

### Pod Security Context

The application chart enforces these security settings by default:

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000

securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

### Network Policies

Three NetworkPolicy manifests implement micro-segmentation:

1. **`default-deny`** — Blocks all ingress and egress in the `devsecops` namespace
2. **`allow-application`** — Permits ingress on port 8080 and egress for DNS + HTTPS
3. **`allow-monitoring`** — Permits Prometheus scraping from the monitoring namespace

---

## Infrastructure Security

### VPC Design

- Public subnets for load balancers (internet-facing ALB)
- Private subnets for EKS nodes (no direct internet access)
- NAT Gateway for outbound traffic from private subnets
- Security groups with least-privilege ingress/egress rules

### EKS Cluster Security

- API server endpoint is publicly accessible (with IAM authentication)
- Cluster logging enabled for: API, Audit, Authenticator, Controller Manager, Scheduler
- EKS access entries with `API` authentication mode
- IRSA / Pod Identity enabled for workload-level IAM

### Secrets Management

- AWS Secrets Manager for sensitive configuration
- Kubernetes Secrets for in-cluster secret distribution
- Terraform `sensitive` attribute for Grafana admin password
- No credentials stored in Git or CI/CD secrets (except SONAR_TOKEN)

---

## CI/CD Security

### Shift-Left Policy Validation

Kyverno CLI runs in the CI pipeline to validate rendered Helm manifests **before** they reach the cluster:

```bash
# CI renders Helm templates and validates against all policies
kyverno apply kubernetes/kyverno-policies/ --resource /tmp/rendered-manifests.yaml
```

### Post-Deploy Compliance

The CD pipeline checks Kyverno `PolicyReport` resources after deployment to verify runtime compliance:

```bash
kubectl get policyreport -n devsecops -o jsonpath='{.items[*].summary.fail}'
```

### Pipeline Permissions

GitHub Actions workflows use minimal permissions:

```yaml
permissions:
  id-token: write    # Required for OIDC
  contents: read     # Required for checkout
```

---

## Code Quality

- **SonarCloud** — Static analysis with quality gates on coverage, duplications, code smells
- **Pre-commit hooks** — Local validation before commits
- **Checkov** — Infrastructure-as-Code best practice scanning
