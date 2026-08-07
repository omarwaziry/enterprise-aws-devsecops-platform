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
| Security | Trivy |
| Authentication | GitHub OIDC |
| Secrets | AWS Secrets Manager |
| DNS | Route53 |
| CDN | CloudFront |
| Ingress | AWS Load Balancer Controller |

---

# Project Phases

> Current Phase: Phase 3 — Docker (In Progress)

---

# Phase 1 — Project Initialization

## Goal

Create the repository structure.

### Tasks

- [ ] Create GitHub repository
- [ ] Create folder structure
- [ ] Create README
- [ ] Create Architecture Diagram
- [ ] Create LICENSE
- [ ] Create CONTRIBUTING
- [ ] Create .gitignore

### Deliverable

Repository initialized.

---

# Phase 2 — Build Application

## Status
Completed

## Goal

Develop a production-ready Spring Boot application.

### Tasks

- [ ] REST API
- [ ] Health Endpoint
- [ ] Actuator
- [ ] Prometheus Metrics
- [ ] Unit Tests
- [ ] Integration Tests

### Deliverable

Application runs locally.

---

# Phase 3 — Docker

## Status
In Progress

## Goal

Containerize the application.

### Tasks

- [ ] Multi-stage Dockerfile
- [ ] Non-root user
- [ ] Optimize image layers
- [ ] Healthcheck
- [ ] Local Docker testing

### Deliverable

Docker image.

---

# Phase 4 — Terraform Infrastructure

## Goal

Provision AWS infrastructure.

### Components

- [ ] VPC
- [ ] Public Subnets
- [ ] Private Subnets
- [ ] NAT Gateway
- [ ] Internet Gateway
- [ ] Route Tables
- [ ] Security Groups
- [ ] IAM Roles
- [ ] Amazon ECR
- [ ] Amazon EKS
- [ ] Managed Node Groups
- [ ] CloudWatch
- [ ] S3 Backend

### Deliverable

Running AWS infrastructure.

---

# Phase 5 — Kubernetes

## Goal

Prepare the cluster.

### Install

- [ ] Metrics Server
- [ ] AWS Load Balancer Controller
- [ ] Cluster Autoscaler
- [ ] EBS CSI Driver

### Deliverable

Production-ready cluster.

---

# Phase 6 — Helm

## Goal

Package the application.

### Create

- [ ] Deployment
- [ ] Service
- [ ] Ingress
- [ ] ConfigMap
- [ ] Secret
- [ ] HPA

### Deliverable

Reusable Helm Chart.

---

# Phase 7 — GitHub Actions CI

## Goal

Automate Continuous Integration.

Pipeline

- [ ] Checkout
- [ ] Setup Java
- [ ] Cache Maven
- [ ] Build
- [ ] Unit Tests
- [ ] SonarCloud Analysis
- [ ] Quality Gate
- [ ] Trivy Filesystem Scan
- [ ] Docker Build
- [ ] Trivy Image Scan
- [ ] Push Image to ECR

### Deliverable

Automated CI.

---

# Phase 8 — GitHub Actions CD

## Goal

Automate deployments.

### Tasks

- [ ] GitHub OIDC Authentication
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
- [ ] Kyverno Policies
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