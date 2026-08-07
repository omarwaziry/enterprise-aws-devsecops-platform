# Docker workflow

This document describes how the application container image is built, run, tested, and deployed for this repository.

## 1. Docker architecture in this project

The container workflow uses the standard Docker model:

- Dockerfile: the build definition for the application image, located at [application/Dockerfile](../application/Dockerfile)
- Image: a portable snapshot of the application and its runtime dependencies
- Container: a running instance of that image
- Registry: a remote store for sharing images (for example, Amazon ECR or GitHub Container Registry)
- Orchestrator: Kubernetes or Amazon EKS pulls the image and runs it as a pod

In this repository, the application is a Spring Boot service that exposes port 8080 and exposes health endpoints through Spring Boot Actuator.

## 2. Multi-stage build

The image uses a multi-stage Docker build to keep the runtime image small and reproducible.

### Build stage

- Uses Eclipse Temurin JDK 21
- Runs the Maven wrapper to package the application with tests skipped
- Produces a runnable JAR file

### Runtime stage

- Uses Eclipse Temurin JRE 21
- Creates a non-root system user for better security
- Copies only the built JAR into the final image
- Exposes port 8080
- Adds a health check for the application endpoint

This approach avoids shipping Maven, source code, and build tooling in the final runtime image.

## 3. Build commands

From the repository root, build the image with the application directory as the build context:

```bash
docker build -t devsecops-app:latest -f application/Dockerfile application
```

To inspect the image:

```bash
docker images | grep devsecops-app
```

To build a tagged image for a release or commit:

```bash
docker build -t devsecops-app:1.0.0 -f application/Dockerfile application
```

## 4. Run commands

Run the container locally:

```bash
docker run --rm -p 8080:8080 --name devsecops-app devsecops-app:latest
```

Check the application:

```bash
curl http://localhost:8080/api/v1/health
curl http://localhost:8080/actuator/health
```

Run with a custom port:

```bash
docker run --rm -e SERVER_PORT=9090 -p 9090:9090 --name devsecops-app devsecops-app:latest
```

Stop and remove the container:

```bash
docker rm -f devsecops-app
```

## 5. Common troubleshooting

### Port already in use

If port 8080 is already occupied, either stop the conflicting process or map a different host port:

```bash
docker run --rm -p 9090:8080 devsecops-app:latest
```

### Container exits immediately

Inspect the logs:

```bash
docker logs devsecops-app
```

Common causes include application startup failures, missing environment variables, or a port binding issue.

### Health check fails

The container health check depends on the application being ready on port 8080. Wait a few seconds and verify that the app is listening:

```bash
docker ps
curl http://localhost:8080/actuator/health
```

### Image build fails

If Maven packaging fails, confirm the build context is correct and that the Dockerfile is being passed with the right path:

```bash
docker build -t devsecops-app:latest -f application/Dockerfile application
```

## 6. Docker best practices

- Keep the build context small by using the existing ignore rules in [.dockerignore](../.dockerignore)
- Prefer multi-stage builds to reduce final image size
- Run containers as a non-root user
- Pin base images to known versions instead of using floating tags
- Use health checks so orchestration systems can detect unhealthy containers
- Avoid storing secrets in the image; inject them via environment variables or Kubernetes secrets
- Scan images for vulnerabilities before promotion to higher environments

## 7. How the image is used by GitHub Actions

This repository currently does not include workflow files under [.github/workflows](../.github/workflows), but the intended CI/CD flow is:

1. GitHub Actions checks out the repository
2. The workflow builds the container image from [application/Dockerfile](../application/Dockerfile)
3. The workflow tags the image with the commit SHA and optionally latest
4. The workflow pushes the image to a container registry such as Amazon ECR or GitHub Container Registry
5. A deployment job consumes the pushed image reference and passes it to Helm or Kubernetes

A typical workflow pattern is:

- Build image: docker build -t registry.example.com/devsecops-app:${GITHUB_SHA} -f application/Dockerfile application
- Push image: docker push registry.example.com/devsecops-app:${GITHUB_SHA}
- Deploy: update the image tag in Helm values or a deployment manifest

## 8. How it is deployed to Amazon EKS

The deployment configuration is defined through the Helm chart in [helm/application](../helm/application).

### Helm deployment flow

- The deployment manifest in [helm/application/templates/deployment.yaml](../helm/application/templates/deployment.yaml) references the image repository and tag from [helm/application/values.yaml](../helm/application/values.yaml)
- In EKS, the image is pulled from the registry configured for the cluster
- Kubernetes runs the container as a pod and uses the provided readiness and liveness probes

Example deployment concept:

1. Build and push a versioned image to Amazon ECR
2. Update the Helm values to point to the ECR image URI and tag
3. Deploy with Helm:

```bash
helm upgrade --install devsecops-app helm/application \
  --set image.repository=123456789012.dkr.ecr.us-east-1.amazonaws.com/devsecops-app \
  --set image.tag=1.0.0
```

In practice, the image tag is often injected by CI/CD so that each deployment uses the exact image built for that commit.

## 9. Summary

The Docker workflow for this project is centered on a secure, multi-stage image that packages the Spring Boot application for local testing, CI builds, and Kubernetes deployment. The same image artifact is intended to flow from GitHub Actions into Amazon EKS through the Helm chart and container registry.
