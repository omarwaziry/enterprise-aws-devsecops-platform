# Monitoring Guide

This document covers the monitoring and observability stack including Prometheus, Grafana, Alertmanager, and CloudWatch.

---

## Architecture

```
Application Pods ──(metrics)──→ Prometheus ──(queries)──→ Grafana
       │                            │                        │
       │                            ▼                        ▼
       │                      Alertmanager            Dashboards
       │                            │
       ▼                            ▼
  Fluent Bit ──(logs)──→  CloudWatch Logs     Alert Notifications
                                │
                                ▼
                        CloudWatch Alarms
```

---

## Accessing Grafana

### Port-Forward (Development)

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
```

Then open [http://localhost:3000](http://localhost:3000).

**Default credentials**:
- Username: `admin`
- Password: `admin` (or the value of `grafana_admin_password` Terraform variable)

---

## Pre-Built Dashboards

The kube-prometheus-stack includes these dashboards out of the box:

### Cluster-Level

| Dashboard | Metrics |
|-----------|---------|
| Kubernetes / Compute Resources / Cluster | Overall cluster CPU, memory, network |
| Kubernetes / Compute Resources / Namespace (Pods) | Per-namespace pod resource usage |
| Kubernetes / Compute Resources / Node (Pods) | Per-node pod resource usage |

### Workload-Level

| Dashboard | Metrics |
|-----------|---------|
| Kubernetes / Compute Resources / Workload | CPU, memory per deployment/statefulset |
| Kubernetes / Compute Resources / Pod | Per-pod CPU, memory, network |

### Node-Level

| Dashboard | Metrics |
|-----------|---------|
| Node Exporter / USE Method / Node | CPU, memory, disk, network per node |
| Node Exporter / Nodes | Multi-node comparison |

### Network

| Dashboard | Metrics |
|-----------|---------|
| Kubernetes / Networking / Cluster | Cluster network throughput |
| Kubernetes / Networking / Namespace (Pods) | Per-namespace network traffic |

---

## Custom Alerting Rules

Custom alerts are defined in `monitoring/alerting-rules.yaml` and loaded as a `PrometheusRule` resource.

### Node Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| `NodeHighCPUUsage` | CPU > 80% for 5m | Warning |
| `NodeHighMemoryUsage` | Memory > 80% for 5m | Warning |
| `NodeNotReady` | Node not ready for 2m | Critical |
| `NodeDiskAlmostFull` | Disk > 85% for 5m | Warning |

### Pod Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| `PodCrashLoopBackOff` | > 5 restarts in 1h | Critical |
| `PodNotReady` | Not ready for 5m | Warning |
| `ContainerHighCPUThrottling` | Throttling > 0.25 for 5m | Warning |

### Deployment Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| `DeploymentReplicasMismatch` | Desired ≠ Ready for 5m | Warning |
| `DeploymentGenerationMismatch` | Observed ≠ Expected for 5m | Critical |

### PVC Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| `PVCAlmostFull` | Usage > 85% for 5m | Warning |

### Managing Alerts

```bash
# Apply custom alerts
kubectl apply -f monitoring/alerting-rules.yaml

# Verify alerts are loaded
kubectl get prometheusrule -n monitoring

# Access Alertmanager UI
kubectl port-forward svc/kube-prometheus-stack-alertmanager 9093:9093 -n monitoring
# Visit http://localhost:9093
```

---

## Application Metrics

The Spring Boot application exposes Prometheus metrics via Spring Actuator:

```
GET /actuator/prometheus
```

Key application metrics:
- `http_server_requests_seconds_*` — HTTP request latency and count
- `jvm_memory_used_bytes` — JVM heap and non-heap memory
- `jvm_gc_pause_seconds_*` — Garbage collection pauses
- `process_cpu_usage` — Application CPU usage
- `tomcat_sessions_active_current` — Active HTTP sessions

### Prometheus Scraping

Pods are discovered via annotations in the Deployment template:

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/actuator/prometheus"
```

---

## CloudWatch Logging

### Log Groups

Fluent Bit ships logs to the following CloudWatch log groups:

| Log Group | Contents |
|-----------|----------|
| `/aws/eks/<cluster>/application` | Container stdout/stderr logs |

### Viewing Logs

```bash
# Via AWS CLI
aws logs tail /aws/eks/devsecops-dev-eks/application --follow

# Filter for specific pod
aws logs filter-log-events \
  --log-group-name /aws/eks/devsecops-dev-eks/application \
  --filter-pattern "devsecops-platform"
```

### CloudWatch Alarms

| Alarm | Metric | Threshold |
|-------|--------|-----------|
| `<cluster>-high-cpu` | Node CPU utilization | > 80% (3 periods) |
| `<cluster>-high-memory` | Node memory utilization | > 80% (3 periods) |
| `<cluster>-pod-restarts` | Pod container restarts | > 5 (2 periods) |

---

## Prometheus Data Retention

- **Default retention**: 15 days
- **Storage**: 20Gi persistent volume (EBS gp2)
- **Scrape interval**: 30 seconds (global), 15 seconds (application)

To modify retention, update the `monitoring.tf` Terraform configuration:

```hcl
prometheus = {
  prometheusSpec = {
    retention = "30d"  # Change retention period
  }
}
```

---

## Useful PromQL Queries

```promql
# Application request rate
rate(http_server_requests_seconds_count{namespace="devsecops"}[5m])

# Application P95 latency
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket{namespace="devsecops"}[5m]))

# Pod CPU usage
sum(rate(container_cpu_usage_seconds_total{namespace="devsecops"}[5m])) by (pod)

# Pod memory usage
sum(container_memory_working_set_bytes{namespace="devsecops"}) by (pod)

# Node disk usage percentage
100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)
```
