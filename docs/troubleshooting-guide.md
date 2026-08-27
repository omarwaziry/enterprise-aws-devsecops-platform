# Troubleshooting Guide

Common issues and their solutions for the Enterprise DevSecOps Platform.

---

## Pod Issues

### Pod stuck in CrashLoopBackOff

**Symptoms**: Pod continuously restarts, `kubectl get pods` shows `CrashLoopBackOff` status.

```bash
# Check pod logs
kubectl logs <pod-name> -n devsecops --previous

# Check events
kubectl describe pod <pod-name> -n devsecops
```

**Common causes**:
- Application startup failure (check Spring Boot logs)
- Incorrect environment variables in ConfigMap
- Insufficient memory causing OOM kills (increase `resources.limits.memory`)
- Read-only filesystem blocking writes (add emptyDir volumes for writable paths)

### Pod stuck in ImagePullBackOff

**Symptoms**: Pod can't pull the container image.

```bash
kubectl describe pod <pod-name> -n devsecops | grep -A5 "Events"
```

**Solutions**:
- Verify ECR login: `aws ecr get-login-password | docker login --username AWS --password-stdin <registry>`
- Check image tag exists: `aws ecr describe-images --repository-name devsecops-platform`
- Verify node IAM role has ECR pull permissions
- Check if the registry restriction Kyverno policy is blocking the image source

### Pod Rejected by Kyverno

**Symptoms**: `kubectl apply` returns an admission webhook error.

```bash
# Check which policy blocked the resource
kubectl get events --field-selector reason=PolicyViolation -A

# List all Kyverno policies
kubectl get clusterpolicy

# Check policy details
kubectl describe clusterpolicy <policy-name>
```

**Common violations**:
- Missing `app` or `environment` labels
- Using `:latest` image tag
- Missing resource requests/limits
- Running as root or with privileged security context
- Missing `readOnlyRootFilesystem: true`

---

## Helm Issues

### Helm Release Stuck in Pending

```bash
# Check release status
helm status devsecops-platform -n devsecops

# Force upgrade with cleanup
helm upgrade --install devsecops-platform helm/application \
  --namespace devsecops --force --cleanup-on-fail

# If stuck, delete the release and reinstall
helm uninstall devsecops-platform -n devsecops
helm install devsecops-platform helm/application --namespace devsecops
```

### Helm Rollback

```bash
# List release history
helm history devsecops-platform -n devsecops

# Rollback to previous revision
helm rollback devsecops-platform <revision-number> -n devsecops

# Verify rollback
kubectl rollout status deployment/devsecops-platform -n devsecops
```

---

## Terraform Issues

### State Lock Error

**Symptoms**: `Error acquiring the state lock`

```bash
# Check who holds the lock
terraform force-unlock <LOCK_ID>
```

> **Caution**: Only force-unlock if you're sure no other process is running.

### Provider Authentication Error

**Symptoms**: `Error configuring Terraform AWS Provider`

- Ensure AWS CLI is configured: `aws sts get-caller-identity`
- Check IAM permissions for the configured profile
- Verify the region matches `var.aws_region`

### Helm Provider Connection Error

**Symptoms**: `Error: Kubernetes cluster unreachable` during `terraform apply`

- Update kubeconfig: `aws eks update-kubeconfig --name devsecops-dev-eks --region us-east-1`
- Ensure the EKS cluster has been created before Helm providers try to connect
- Check `depends_on` ordering in Terraform modules

---

## CI/CD Pipeline Issues

### CI Pipeline Fails at SonarCloud

- Verify `SONAR_TOKEN` secret is set in the repository
- Check SonarCloud project exists and is configured
- Review SonarCloud quality gate rules

### CD Pipeline Fails at AWS Authentication

- Verify `AWS_ROLE_ARN` variable is set correctly
- Check the GitHub OIDC provider is created in AWS IAM
- Verify the IAM role trust policy allows the correct repository

```bash
# Verify OIDC provider
aws iam list-open-id-connect-providers

# Check role trust policy
aws iam get-role --role-name devsecops-dev-github-actions \
  --query 'Role.AssumeRolePolicyDocument'
```

### CD Pipeline Fails at Helm Upgrade

- Check if the EKS cluster is accessible from the runner
- Verify the image tag exists in ECR
- Review Kyverno policy compliance for the deployed manifests

---

## Monitoring Issues

### Grafana Not Accessible

```bash
# Port-forward Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

# Default credentials
# Username: admin
# Password: admin (or value from grafana_admin_password variable)
```

### Prometheus Not Scraping Application Metrics

- Verify pod annotations are present:
  ```bash
  kubectl get pods -n devsecops -o jsonpath='{.items[*].metadata.annotations}'
  ```
- Check ServiceMonitor or scrape configs in Prometheus
- Test metrics endpoint directly:
  ```bash
  kubectl port-forward <pod-name> 8080:8080 -n devsecops
  curl http://localhost:8080/actuator/prometheus
  ```

### Alerts Not Firing

```bash
# Check PrometheusRule is loaded
kubectl get prometheusrule -n monitoring

# Check Alertmanager status
kubectl port-forward svc/kube-prometheus-stack-alertmanager 9093:9093 -n monitoring
# Visit http://localhost:9093
```

---

## Network Issues

### Application Not Reachable via ALB

```bash
# Check ingress status
kubectl describe ingress devsecops-platform -n devsecops

# Check ALB Controller logs
kubectl logs -l app.kubernetes.io/name=aws-load-balancer-controller \
  -n kube-system --tail=50

# Verify target group health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

### Network Policy Blocking Traffic

```bash
# List network policies
kubectl get networkpolicy -n devsecops

# Temporarily delete to test connectivity
kubectl delete networkpolicy default-deny-all -n devsecops

# Remember to reapply after testing
kubectl apply -f kubernetes/network-policies/
```

---

## Useful Diagnostic Commands

```bash
# Cluster overview
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes
kubectl top pods -n devsecops

# Events (sorted by timestamp)
kubectl get events -n devsecops --sort-by='.lastTimestamp'

# All resources in namespace
kubectl get all -n devsecops

# Kyverno policy reports
kubectl get policyreport -A

# Helm releases
helm list -A

# Fluent Bit logs
kubectl logs -l app.kubernetes.io/name=fluent-bit -n logging --tail=20
```
