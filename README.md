# Enterprise AWS DevSecOps Platform

This repository contains a production-ready Spring Boot application and the supporting DevSecOps infrastructure for an AWS-based platform showcase.

## Application

The application lives under the application directory and provides:

- REST API endpoints for health, readiness, and greetings
- Spring Boot Actuator with health and Prometheus metrics
- OpenAPI documentation via Springdoc
- Unit and integration tests

## Run locally

```bash
cd application
./mvnw test
./mvnw spring-boot:run
```

Then visit:

- http://localhost:8080/api/v1/health
- http://localhost:8080/actuator/health
- http://localhost:8080/swagger-ui/index.html

## Container

```bash
cd application
./mvnw package
docker build -t devsecops-app:latest .
```

## Next steps

- Add GitHub Actions CI/CD workflows
- Provision AWS EKS, ECR, and supporting infrastructure with Terraform
- Deploy the app with Helm and Kubernetes manifests
