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

Production Application

↓

Prometheus + Grafana + CloudWatch

---

# Project Structure

```
enterprise-aws-devsecops-platform/

.github/
    workflows/

application/

terraform/
    modules/
    environments/

helm/
    application/

monitoring/

kubernetes/

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
| Pre-commit | pre-commit |
| Authentication | GitHub OIDC |
| Secrets | AWS Secrets Manager |
| DNS | Route53 |
| CDN | CloudFront |
| Ingress | AWS Load Balancer Controller |

---

# Project Phases

> Current Phase: Phase 8 — GitHub Actions CD (Ready to Start)

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
In Progress

## Goal

Prepare the cluster.

### Install

- [x] Metrics Server
- [x] AWS Load Balancer Controller
- [ ] Cluster Autoscaler
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

## Goal

Automate deployments.

### Tasks

- [ ] GitHub OIDC Authentication
- [ ] Configure GitHub OIDC for EKS authentication (removing local AWS CLI credentials)
- [ ] Configure kubectl
- [ ] Authenticate to EKS
- [ ] Helm Upgrade
- [ ] Verify Rollout
- [ ] Smoke Tests

### Deliverable

Automatic deployments.

---

# Phase 9 — Monitoring

## Goal

Full observability.

Deploy

- [ ] Prometheus
- [ ] Grafana
- [ ] Alertmanager
- [ ] Node Exporter
- [ ] kube-state-metrics

Create Dashboards

- [ ] CPU
- [ ] Memory
- [ ] Network
- [ ] Pods
- [ ] Nodes
- [ ] Deployments

### Deliverable

Operational dashboards.

---

# Phase 10 — Logging

## Goal

Centralized logging.

### Configure

- [ ] CloudWatch Agent
- [ ] Container Logs
- [ ] Node Logs
- [ ] Metrics
- [ ] CloudWatch Alarms

### Deliverable

Centralized logging.

---

# Phase 11 — Security

## Goal

Secure the platform.

### Implement

- [ ] GitHub OIDC
- [ ] IAM Least Privilege
- [ ] IRSA
- [ ] AWS Secrets Manager
- [ ] KMS
- [ ] Kubernetes Secrets
- [ ] Network Policies
- [ ] Security Groups
- [ ] SonarCloud
- [ ] Trivy
- [ ] Kyverno/OPA Policies
- [ ] Dependabot

### Deliverable

Secure deployment platform.

---

# Phase 12 — Production Readiness

## Goal

Enterprise-grade deployment.

### Implement

- [ ] Horizontal Pod Autoscaler
- [ ] Cluster Autoscaler
- [ ] Health Probes
- [ ] Resource Requests/Limits
- [ ] Rolling Updates
- [ ] Rollback Strategy
- [ ] Backup Strategy
- [ ] Disaster Recovery Documentation

### Deliverable

Production-ready platform.

---

# Documentation

Create

- [ ] Architecture Diagram
- [ ] README
- [ ] Deployment Guide
- [ ] Troubleshooting Guide
- [ ] Security Guide
- [ ] Terraform Documentation
- [ ] Helm Documentation
- [ ] Monitoring Guide

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

Terraform Apply (optional for infrastructure changes)

↓

Configure kubectl

↓

Helm Upgrade --install

↓

Verify Rollout

↓

Smoke Test

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