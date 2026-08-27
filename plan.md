# Enterprise AWS DevSecOps Platform
### Project Plan

> **Goal:** Build a production-ready cloud-native DevSecOps platform on AWS using modern engineering practices and enterprise-grade tooling.

---

# Overview

This project demonstrates how to design, build, secure, deploy, monitor, and operate containerized applications on Amazon EKS using Infrastructure as Code, GitHub Actions, Helm, and AWS managed services.

Unlike traditional CI/CD pipelines using Jenkins and ArgoCD, this project leverages GitHub Actions as the unified CI/CD platform while following AWS security best practices such as GitHub OIDC authentication and IAM Roles for Service Accounts (IRSA).

---

# Objectives

- Deploy a production-ready Kubernetes application
- Provision AWS infrastructure using Terraform
- Implement secure CI/CD with GitHub Actions
- Build Docker images automatically
- Push images to Amazon ECR
- Deploy to Amazon EKS using Helm
- Implement monitoring and alerting
- Secure the platform using AWS best practices
- Document the complete architecture

---

# High-Level Architecture

Developer

↓

GitHub Repository

↓

GitHub Actions

↓

SonarCloud

↓

Trivy Security Scan

↓

Docker Build

↓

Amazon ECR

↓

Terraform

↓

Amazon EKS

↓

Helm Deployment

↓

Kyverno Policy Enforcement

↓

Production Application

↓

Prometheus + Grafana + CloudWatch

---

# Project Structure

```
enterprise-aws-devsecops-platform/

.github/
    workflows/
    dependabot.yml

application/

terraform/
    modules/
    environments/

helm/
    application/

monitoring/

kubernetes/
    kyverno-policies/
    network-policies/

docs/

scripts/

README.md

plan.md
```

---

# Technology Stack

| Category | Technology |
|------------|-------------------------|
| Cloud | AWS |
| IaC | Terraform |
| Containers | Docker |
| Kubernetes | Amazon EKS |
| CI/CD | GitHub Actions |
| Registry | Amazon ECR |
| Deployment | Helm |
| Monitoring | Prometheus |
| Dashboards | Grafana |
| Alerts | Alertmanager |
| Logging | CloudWatch |
| Code Quality | SonarCloud |
| Security | Trivy, tfsec, Checkov, Kyverno |
| Logging | AWS for Fluent Bit → CloudWatch |
| Pre-commit | pre-commit |
| Authentication | GitHub OIDC |
| Secrets | AWS Secrets Manager |
| DNS | Route53 |
| CDN | CloudFront |
| Ingress | AWS Load Balancer Controller |

---

# Project Phases

> All Phases Complete ✅

---

# Phase 1 — Project Initialization

## Status
Completed

## Goal

Create the repository structure.

### Tasks

- [x] Create GitHub repository
- [x] Create folder structure
- [x] Create README
- [x] Create Architecture Diagram
- [x] Create LICENSE
- [x] Create CONTRIBUTING
- [x] Create .gitignore

### Deliverable

Repository initialized.

---

# Phase 2 — Build Application

## Status
Completed

## Goal

Develop a production-ready Spring Boot application.

### Tasks

- [x] REST API
- [x] Health Endpoint
- [x] Actuator
- [x] Prometheus Metrics
- [x] Unit Tests
- [x] Integration Tests

### Deliverable

Application runs locally.

---

# Phase 3 — Docker

## Status
Completed

## Goal

Containerize the application.

### Tasks

- [x] Multi-stage Dockerfile
- [x] Non-root user
- [x] Optimize image layers
- [x] Healthcheck
- [x] Local Docker testing

### Deliverable

Docker image.

---

# Phase 4 — Terraform Infrastructure

## Status
Completed (Ready for Deployment)

## Goal

Provision AWS infrastructure.

### Components

- [x] VPC
- [x] Public Subnets
- [x] Private Subnets
- [x] NAT Gateway
- [x] Internet Gateway
- [x] Route Tables
- [x] Security Groups
- [x] IAM Roles
- [x] Amazon ECR
- [x] Amazon EKS
- [x] Managed Node Groups
- [x] CloudWatch
- [x] S3 Backend
- [x] Implement Native S3 State Locking (No DynamoDB)
- [x] Parameterize hardcoded values (disk_size, region, capacity_type)

### Deliverable

Running AWS infrastructure.

---

# Phase 5 — Kubernetes

## Status
Completed

## Goal

Prepare the cluster.

### Install

- [x] Metrics Server
- [x] AWS Load Balancer Controller
- [x] Cluster Autoscaler
- [x] EBS CSI Driver

### Deliverable

Production-ready cluster.

---

# Phase 6 — Helm

## Status
Completed

## Goal

Package the application.

### Create

- [x] Deployment
- [x] Service
- [x] Ingress
- [x] ConfigMap
- [x] Secret / ServiceAccount
- [x] HPA
- [x] Parameterize ECR URI to remove hardcoded AWS account IDs

### Deliverable

Reusable Helm Chart.

---

# Phase 7 — GitHub Actions CI

## Status
Completed

## Goal

Automate Continuous Integration.

Pipeline

- [x] Pre-commit hooks configuration
- [x] Checkout
- [x] Setup Java
- [x] Cache Maven
- [x] Build
- [x] Unit Tests
- [x] SonarCloud Analysis
- [x] Quality Gate
- [x] IaC Security Scanning (tfsec/checkov/trivy)
- [x] Trivy Filesystem Scan
- [x] Docker Build
- [x] Trivy Image Scan
- [x] Push Image to ECR

### Deliverable

Automated CI.

---

# Phase 8 — GitHub Actions CD

## Status
Completed

## Goal

Automate deployments.

### Tasks

- [x] GitHub OIDC Authentication
- [x] Configure GitHub OIDC for EKS authentication (removing local AWS CLI credentials)
- [x] Configure kubectl
- [x] Authenticate to EKS
- [x] Helm Upgrade
- [x] Verify Rollout
- [x] Smoke Tests

### Deliverable

Automatic deployments.

---

# Phase 9 — Monitoring

## Status
Completed

## Goal

Full observability.

Deploy

- [x] Prometheus
- [x] Grafana
- [x] Alertmanager
- [x] Node Exporter
- [x] kube-state-metrics

Create Dashboards

- [x] CPU
- [x] Memory
- [x] Network
- [x] Pods
- [x] Nodes
- [x] Deployments

### Deliverable

Operational dashboards.

---

# Phase 10 — Logging

## Status
Completed

## Goal

Centralized logging.

### Configure

- [x] AWS for Fluent Bit
- [x] Container Logs
- [x] Node Logs
- [x] Metrics
- [x] CloudWatch Alarms

### Deliverable

Centralized logging.

---

# Phase 11 — Security

## Status
Completed

## Goal

Secure the platform.

### Implement

- [x] GitHub OIDC
- [x] IAM Least Privilege
- [x] IRSA
- [x] AWS Secrets Manager
- [x] KMS
- [x] Kubernetes Secrets
- [x] Network Policies
- [x] Security Groups
- [x] SonarCloud
- [x] Trivy
- [x] Kyverno/OPA Policies
- [x] Dependabot

### Deliverable

Secure deployment platform.

---

# Phase 12 — Production Readiness

## Status
Completed

## Goal

Enterprise-grade deployment.

### Implement

- [x] Horizontal Pod Autoscaler
- [x] Cluster Autoscaler
- [x] Health Probes
- [x] Resource Requests/Limits
- [x] Rolling Updates
- [x] Rollback Strategy
- [x] PodDisruptionBudget
- [x] Disaster Recovery Documentation

### Deliverable

Production-ready platform.

---

# Documentation

## Status
Completed

Create

- [x] Architecture Diagram
- [x] README
- [x] Deployment Guide
- [x] Troubleshooting Guide
- [x] Security Guide
- [x] Terraform Documentation
- [x] Helm Documentation
- [x] Monitoring Guide

---

# GitHub Actions Pipeline

```
Push

↓

Checkout

↓

Setup Java

↓

Maven Build

↓

Unit Tests

↓

SonarCloud

↓

Quality Gate

↓

Kyverno Policy Validation (shift-left)

↓

Trivy Filesystem Scan

↓

Docker Build

↓

Trivy Image Scan

↓

Login to AWS using GitHub OIDC

↓

Push to Amazon ECR

↓

Configure kubectl

↓

Helm Upgrade --install

↓

Verify Rollout

↓

Smoke Test

↓

Kyverno Compliance Check

↓

Deployment Successful
```

---

# Stretch Goals

- [ ] Blue/Green Deployment
- [ ] Canary Deployment
- [ ] GitHub Environments
- [ ] Slack Notifications
- [ ] Amazon SNS Alerts
- [ ] OpenTelemetry
- [ ] Karpenter
- [ ] External Secrets Operator
- [ ] Falco Runtime Security
- [ ] Multi-Environment (Dev/Staging/Prod)
- [ ] Multi-Region Deployment

---

# Success Criteria

- Infrastructure fully provisioned with Terraform
- Application automatically deployed through GitHub Actions
- Secure authentication using GitHub OIDC
- Zero hardcoded AWS credentials
- Production-ready Helm deployment
- Monitoring dashboards operational
- CloudWatch logging enabled
- Security scanning integrated into CI
- Complete documentation with architecture diagrams and screenshots
- Suitable as a portfolio project for DevOps, Platform Engineering, and Cloud Engineering roles