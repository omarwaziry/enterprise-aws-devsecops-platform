# Helm Guide

This document covers the Helm chart structure, values reference, deployment commands, and upgrade/rollback procedures.

---

## Chart Structure

```
helm/application/
├── Chart.yaml              # Chart metadata (name, version, appVersion)
├── values.yaml             # Default configuration values
├── .helmignore             # Files excluded from chart packaging
└── templates/
    ├── _helpers.tpl         # Template helper functions
    ├── deployment.yaml      # Deployment with security context, probes, rolling updates
    ├── service.yaml         # ClusterIP Service
    ├── ingress.yaml         # ALB Ingress (conditional)
    ├── configmap.yaml       # Environment configuration
    ├── serviceaccount.yaml  # ServiceAccount with IRSA support
    ├── hpa.yaml             # HorizontalPodAutoscaler (conditional)
    └── pdb.yaml             # PodDisruptionBudget (conditional)
```

---

## Values Reference

### Image Configuration

```yaml
image:
  registry: ""                    # ECR registry URL (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com)
  repository: devsecops-platform  # Image name
  tag: "1.0.0"                    # Image tag (use commit SHA in CI/CD)
  pullPolicy: IfNotPresent        # IfNotPresent, Always, or Never
```

### Replicas & Autoscaling

```yaml
replicaCount: 2                   # Static replica count (when HPA disabled)

autoscaling:
  enabled: false                  # Enable HPA
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
```

### Security Context

```yaml
podSecurityContext:
  runAsNonRoot: true              # Pod-level non-root enforcement
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000

securityContext:
  readOnlyRootFilesystem: true    # Immutable container filesystem
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL                       # Drop all Linux capabilities
```

### Resources

```yaml
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Probes

```yaml
probes:
  readiness:
    path: /api/v1/ready
    initialDelaySeconds: 10
    periodSeconds: 10
  liveness:
    path: /actuator/health
    initialDelaySeconds: 20
    periodSeconds: 15
```

### Ingress

```yaml
ingress:
  enabled: true
  className: alb                  # AWS ALB Ingress Class
  scheme: internet-facing         # internet-facing or internal
  targetType: ip                  # ip or instance
```

### Rolling Update Strategy

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1                   # Max pods above desired during update
    maxUnavailable: 0             # Zero-downtime deployments
```

### Pod Disruption Budget

```yaml
pdb:
  enabled: true
  minAvailable: 1                 # Minimum pods during voluntary disruptions
```

---

## Common Commands

### Install

```bash
helm install devsecops-platform helm/application \
  --namespace devsecops \
  --create-namespace \
  --set image.registry=<ECR_REGISTRY> \
  --set image.tag=<TAG>
```

### Upgrade

```bash
helm upgrade devsecops-platform helm/application \
  --namespace devsecops \
  --set image.tag=<NEW_TAG> \
  --wait --timeout 5m
```

### Rollback

```bash
# List revision history
helm history devsecops-platform -n devsecops

# Rollback to previous revision
helm rollback devsecops-platform 1 -n devsecops

# Verify rollback
kubectl rollout status deployment/devsecops-platform -n devsecops
```

### Uninstall

```bash
helm uninstall devsecops-platform -n devsecops
```

### Template Rendering (Dry Run)

```bash
# Render templates without deploying
helm template devsecops-platform helm/application \
  --set image.registry=123456789012.dkr.ecr.us-east-1.amazonaws.com \
  --set image.tag=abc123

# Validate against Kyverno policies
helm template devsecops-platform helm/application \
  --set image.registry=123456789012.dkr.ecr.us-east-1.amazonaws.com \
  --set image.tag=abc123 \
  > /tmp/manifests.yaml

kyverno apply kubernetes/kyverno-policies/ --resource /tmp/manifests.yaml
```

### Override Values

```bash
# Using --set for individual values
helm upgrade --install devsecops-platform helm/application \
  --set replicaCount=3 \
  --set autoscaling.enabled=true

# Using a values file
helm upgrade --install devsecops-platform helm/application \
  -f my-custom-values.yaml
```

---

## Helper Templates

The chart includes reusable template helpers in `_helpers.tpl`:

| Helper | Description |
|--------|-------------|
| `devsecops-platform.name` | Chart name (truncated to 63 chars) |
| `devsecops-platform.fullname` | Release name (truncated to 63 chars) |
| `devsecops-platform.serviceAccountName` | ServiceAccount name resolution |
| `devsecops-platform.image` | Full image reference with optional registry |
