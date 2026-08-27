# Enterprise AWS DevSecOps Platform

A production-ready cloud-native DevSecOps platform on AWS demonstrating modern engineering practices and enterprise-grade tooling. Features a Spring Boot application deployed on Amazon EKS with full CI/CD automation, security scanning, policy enforcement, monitoring, and centralized logging.

---

## Architecture

```
Developer → GitHub Repository → GitHub Actions CI
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                  ▼
             Application       Security Scan      Kyverno Policy
            Build & Test      (Trivy/Checkov)      Validation
                    │                 │                  │
                    └─────────────────┼──────────────────┘
                                      ▼
                              Docker Build & Scan
                                      │
                                      ▼
                               Amazon ECR Push
                                      │
                                      ▼
                            GitHub Actions CD
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                  ▼
               AWS OIDC        Helm Deploy to      Post-Deploy
            Authentication     Amazon EKS          Verification
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                  ▼
                Kyverno          Prometheus         Fluent Bit
            Policy Engine      & Grafana         → CloudWatch
```

---

## Technology Stack

| Category | Technology |
|---|---|
| **Cloud** | AWS (EKS, ECR, VPC, IAM, CloudWatch, S3, KMS) |
| **IaC** | Terraform with S3 backend and native state locking |
| **Containers** | Docker (multi-stage, non-root, health-checked) |
| **Orchestration** | Amazon EKS with managed node groups |
| **CI/CD** | GitHub Actions (CI + CD pipelines) |
| **Deployment** | Helm 3 with parameterized charts |
| **Monitoring** | Prometheus, Grafana, Alertmanager (kube-prometheus-stack) |
| **Logging** | AWS for Fluent Bit → CloudWatch Logs |
| **Code Quality** | SonarCloud |
| **Security Scanning** | Trivy (FS + Image + IaC), Checkov |
| **Policy Engine** | Kyverno (8 ClusterPolicies) |
| **Authentication** | GitHub OIDC → AWS IAM (zero stored credentials) |
| **Pre-commit** | pre-commit hooks |
| **Dependency Updates** | Dependabot (Maven, Actions, Docker, Terraform) |
| **Ingress** | AWS Load Balancer Controller |

---

## Project Structure

```
enterprise-aws-devsecops-platform/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # CI pipeline
│   │   └── cd.yml                    # CD pipeline
│   └── dependabot.yml                # Dependency update automation
├── application/
│   ├── src/                          # Spring Boot source code
│   ├── Dockerfile                    # Multi-stage container build
│   └── pom.xml                       # Maven dependencies
├── terraform/
│   ├── modules/
│   │   ├── vpc/                      # VPC, subnets, NAT, IGW
│   │   ├── eks/                      # EKS cluster, add-ons, monitoring
│   │   ├── ecr/                      # Container registry
│   │   └── github-oidc/              # GitHub OIDC provider + IAM role
│   ├── environments/
│   │   └── dev/                      # Dev environment configuration
│   └── backend/                      # S3 state backend
├── helm/
│   └── application/                  # Helm chart (Deployment, Service, Ingress, HPA, PDB)
├── kubernetes/
│   ├── kyverno-policies/             # 8 Kyverno ClusterPolicy manifests
│   └── network-policies/             # NetworkPolicy manifests
├── monitoring/
│   └── alerting-rules.yaml           # Custom Prometheus alerting rules
├── docs/                             # Comprehensive documentation
└── plan.md                           # Project plan and phase tracking
```

---

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.10
- kubectl
- Helm 3
- Docker
- Java 21 (for local development)

### 1. Provision Infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### 2. Connect to EKS

```bash
aws eks update-kubeconfig --region us-east-1 --name devsecops-dev-eks
kubectl cluster-info
```

### 3. Deploy Application

```bash
helm upgrade --install devsecops-platform helm/application \
  --namespace devsecops --create-namespace \
  --set image.registry=<ECR_REGISTRY> \
  --set image.tag=<IMAGE_TAG>
```

### 4. Apply Kyverno Policies

```bash
kubectl apply -f kubernetes/kyverno-policies/
```

### 5. Apply Network Policies

```bash
kubectl apply -f kubernetes/network-policies/
```

---

## CI/CD Pipeline

### CI Pipeline (on push/PR to main)

1. **Application Tests & Quality** — Maven build, unit tests, SonarCloud analysis
2. **Security Scanning** — Trivy filesystem/IaC scan, Checkov IaC scan
3. **Kyverno Policy Validation** — Shift-left policy checks against rendered Helm manifests
4. **Docker Build, Scan & ECR Push** — Build image, Trivy container scan, push to ECR

### CD Pipeline (on CI success or manual trigger)

1. **AWS Authentication** — GitHub OIDC → IAM role assumption
2. **EKS Deployment** — Helm upgrade with image tag
3. **Verification** — Rollout status check
4. **Smoke Tests** — Health and readiness endpoint validation
5. **Compliance Check** — Kyverno PolicyReport verification

---

## Security Features

| Feature | Implementation |
|---|---|
| **Zero Stored Credentials** | GitHub OIDC federation with AWS IAM |
| **Pod Security** | Kyverno policies (non-root, no privilege escalation, read-only rootfs) |
| **Image Trust** | Registry restriction to ECR + Docker Hub official only |
| **Network Isolation** | Default-deny NetworkPolicies with explicit allows |
| **Container Scanning** | Trivy image + filesystem scanning in CI |
| **IaC Scanning** | Trivy + Checkov for Terraform/Helm/Dockerfile |
| **Code Quality** | SonarCloud with quality gates |
| **Dependency Updates** | Dependabot for all ecosystems |
| **Least Privilege** | IRSA / EKS Pod Identity for all service accounts |

---

## Monitoring & Observability

- **Prometheus** — Metrics collection with 15-day retention and persistent storage
- **Grafana** — Pre-built dashboards for CPU, memory, network, pods, nodes, deployments
- **Alertmanager** — Alert routing and notification
- **Custom Alerts** — Node health, pod crashes, replica mismatches, disk/PVC capacity
- **CloudWatch Logs** — Centralized container and node logging via Fluent Bit
- **CloudWatch Alarms** — CPU/memory utilization and pod restart frequency

---

## Documentation

| Guide | Description |
|---|---|
| [Deployment Guide](docs/deployment-guide.md) | End-to-end infrastructure and application deployment |
| [Security Guide](docs/security-guide.md) | Security architecture, OIDC flow, policies |
| [Monitoring Guide](docs/monitoring-guide.md) | Grafana access, dashboards, alerting |
| [Terraform Guide](docs/terraform-guide.md) | Module overview, variables, state management |
| [Helm Guide](docs/helm-guide.md) | Chart structure, values reference, upgrades |
| [Troubleshooting Guide](docs/troubleshooting-guide.md) | Common issues and resolutions |
| [Docker Guide](docs/docker.md) | Container build and optimization |

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
